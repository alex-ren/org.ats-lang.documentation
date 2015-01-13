.. Document for Model Checking ATS

.. include:: conats.hrst

Model Checking ATS
=====================================

In this project, we focus on integrating model checking techniques seamlessly into
the development of ATS program and ultimately build a practical system for 
verifying concurrent ATS program.

.. _tutorial_label:

Tutorial
-----------

Before going to the details, let's have a quick look of how the methodology looks like.
The producer-consumer problem is a classic one in field of concurrent programming. A recommanded
implementation is described in the documentation of ATS [1]_, which exploits the type system of
ATS to better ensure the correctness of the program. Certain mistakes, as stated below, can
be avoided, which is great.
However, a well-typed implementation for producer-consumer problem in ATS may still cause
deadlock. And it's very difficult to soly rely on type system to capture such errors. Therefore, we
start seeking help from other techniques, among which model checking is our pick here. It
can help detect bugs related to temporal properties in concurrent systems and provide 
corresponding counterexamples. To apply the model checking technique, we need to form up
the precise semantics of ATS programs, which in turn requires the precise semantics of those
concurrency primitives related to communication and synchronization. We form up a collection 
of such primitives, based on which programers can build concurrent program in ATS with semantics
meanful to the model checking techniques we employ here. Such collection is given 
in the file |conats.sats|_. It also contains some other primitives used
for model checking, which we shall explain as we see more examples.

The complete implementation for producer-consumer problem can be found here 
:download:`16_reader_writer.dats`. 
You can also read, modify, and verify the implementation via our website |mcats|_. 
We illustrate some of the code snippets below.

As indicated in [1]_, a shared object contains a linear object, which in this example is
a linear buffer. The primitives provided in |conats.sats|_ do not support such type.
Therefore we define a linear type *lin_buffer* as well as corresponding functions for
manupulating objects of such type, which is given below.

.. code-block:: text
  :linenos:

    // Define linear buffer to prevent resource leak.
    absviewtype lin_buffer (a:t@ype)
    
    local
      assume lin_buffer (a) = atomref (a)
    in
      fun lin_buffer_create {a:t@ype} (
        data: a): lin_buffer a = let
        val ref = conats_atomref_create (data)
      in
        ref
      end
      
      fun lin_buffer_update {a:t@ype} (
        lref: lin_buffer a, data: a): lin_buffer a = let
        val () = conats_atomref_update (lref, data)
      in
        lref
      end
      
      fun lin_buffer_get {a:t@ype} (
        lref: lin_buffer a): (lin_buffer a, a) = let
        val v = conats_atomref_get lref
      in
        (lref, v)
      end
    end

Three functions *conats_atomref_create*, *conats_atomref_update*, and
*conats_atomref_get* are declared in |conats.sats|_. Intuitively, they are used for
creating a mutable object whose content can be accessed in an atomic manner.

In our example, we only need a linear buffer whose content is an integer. The following
code defines the type *demo_buffer* for such linear buffer and some auxiliary functions
for accessing it.

.. code-block:: text
  :linenos:

    // Define linear integer buffer for demonstration.
    viewtypedef demo_buffer = lin_buffer int
    
    fun demo_buffer_isful (buf: demo_buffer): (demo_buffer, bool) = let
      val (buf, len) = lin_buffer_get (buf)
    in
      (buf, len > 0)  // Assume the buffer can only hold 1 elements.
    end
    
    fun demo_buffer_isnil (buf: demo_buffer): (demo_buffer, bool) = let
      val (buf, len) = lin_buffer_get (buf)
    in
      (buf, len <= 0)
    end
    
    fun demo_buffer_insert (buf: demo_buffer): demo_buffer = let
      val (buf, len) = lin_buffer_get (buf)
      val buf = lin_buffer_update (buf, len + 1)
    in 
      buf
    end
    
    fun demo_buffer_takeout (buf: demo_buffer): demo_buffer = let
      val (buf, len) = lin_buffer_get (buf)
      val buf = lin_buffer_update (buf, len - 1)
    in 
      buf
    end

One thing worth mentioning is the number 1 we choose as the capacity of the virtual
buffer shared by producer and consumer. In reality, a shared buffer may have a large
capacity. But a big number may cause model checking not to be able to detect the
potential bugs. Arguably, if our implementation is correct for a small capacity of
shared buffer, it has better chances to be correct as well for large capacity.
    
Now we can create the linear buffer holding integer and then put it into a shared object
which can be accessed by multiple threads. The corresponding code is shown below.
    
.. code-block:: text
  :linenos:

    // Create a buffer for model construction.
    val db: demo_buffer = lin_buffer_create (0)
    
    // Turn a linear buffer into a shared buffer.
    val s = conats_shared_create {demo_buffer}(db)
    
*conats_shared_create* is a function declared in |conats.sats|_, whose semantics is about
creating an shared object protecting its content via mutex and condition variables.

We now give out the code for producer and consumer. For the purpose of model
checking, *producer* is actually a function which keeps increasing the
counter inside the linear buffer whenever possible. If the capacity is reached, 
the producer would wait until the consumer takes out (by decreasing the counter)
something out of the buffer. The same idea applies to the *consumer* functions.
Notably, both *producer* and *consumer* would wake up the potentially waiting counterpart by
sending a signal.

.. code-block:: text
  :linenos:

    // Keep adding elements into buffer.
    fun producer (x: int):<fun1> void = let
      val db = conats_shared_acquire (s)
    
      fun insert (db: demo_buffer):<cloref1> demo_buffer = let
        val (db, isful) = demo_buffer_isful (db)
      in
        if isful then let
          val db = conats_shared_condwait (s, db)
        in
          insert (db)
        end else let 
          val (db, isnil) = demo_buffer_isnil (db)
          val db = demo_buffer_insert (db)
        in
          if isnil then conats_shared_signal (s, db)
          else db
        end
      end
      
      val db = insert (db)
      val () = conats_shared_release (s, db); 
    in
      producer (x)
    end
    
    // Keep removing elements from buffer.
    fun consumer (x: int):<fun1> void = let
      val db = conats_shared_acquire (s)
    
      fun takeout (db: demo_buffer):<cloref1> demo_buffer = let
        val (db, isnil) = demo_buffer_isnil (db)
      in
        if isnil then let
          val db = conats_shared_condwait (s, db)
        in
          takeout (db)
        end else let
          val (db, isful) = demo_buffer_isful (db)
          val db = demo_buffer_takeout (db)
        in
          if isful then let
            // Omitting the following would cause deadlock
            // val db = conats_shared_signal (s, db)
          in db end
          else db
        end
      end
    
      val db = takeout (db)
      val () = conats_shared_release (s, db); 
    in
      consumer (x)
    end

Due to the usage of linear type of ATS, ATS compiler would complain if a programmer forgets
to call *conats_shared_acquire* to acquire the mutex (which is inside the shared object)
before updating the counter, or *conats_shared_release* to release the mutex. 
However, type checking won't be
able to detect the potential deadlock if the producer or consumer doesn't call the
*conats_shared_signal* function.

Model checking can help detect the aforementioned bug. However, unlike type checking,
model checking can only be applied to a runable program instead of a collection of functions.
Therefore we set up the environment as follows so that we have a complete model. The
model consists of two threads, one for producer and one for consumer. The
*conats_tid_allocate* and *conats_thread_create* functions are provided by
|conats.sats|_. Intuitively, they are used for allocating thread id and creating new
thread with a given function.

.. code-block:: text
  :linenos:

    val tid1 = conats_tid_allocate ()
    val tid2 = conats_tid_allocate ()
    
    val () = conats_thread_create(producer, 0, tid1)
    val () = conats_thread_create(consumer, 0, tid2)

Since model checking allows us to verify various properties of a program, we specify as
follows that we want to verify that our program does not have deadlock.

.. code-block:: text
  :linenos:

    %{$
    #assert main deadlockfree;
    %}

So far we have implemented the producer-consumer problem. With the appropriate
implementations of functions from |conats.sats|_, we can compile and run the ATS program.
Due to the nondeterminism caused by concurrency, the potential deadlock may not happen
during several runnings. But with model checking, we are guaranteed that there is no
deadlock if our implementation can pass the model checking.

The model checking process goes as follows.  We build a tool, which is able to 
extract a model from the ATS program given above.  Currently, the extracted model is 
in the modeling langauge CSP#. We then use the state-of-art model checker
`PAT <http://www.comp.nus.edu.sg/~pat/>`_ to check the generated model. To ease the
whole process, we set up a website for readers to try this methodology on-line:
|mcats|_. The aforementioned example can be found under the
name "16_reader_writer.dats" in the dropdown list "Select ATS Example". We are working
on building tools to better relate the model checking result (counterexample) to the original ATS
program. However, it's still quite informative just by inspecting the current result of
the model checker since the extracted model in CSP# is quite readable. As for the
example, if we omit *conats_shared_signal* in *consumer*, model checking would give out
the following result including the trace leading to the deadlock. (We omit the detail
of the trace here for clarity purpose.)

.. code-block:: text

  =======================================================
  Assertion: main() deadlockfree
  ********Verification Result********
  The Assertion (main() deadlockfree) is NOT valid.
  The following trace leads to a deadlock situation.
  <init -> main_init -> main61_id_s1.0 -> lin_buffer_create_63_s1.0 -> main61_id_s2.0 -> ......
  
  ********Verification Setting********
  Admissible Behavior: All
  Search Engine: Shortest Witness Trace using Breadth First Search
  System Abstraction: False
  
  
  ********Verification Statistics********
  Visited States:2392
  Total Transitions:4588
  Time Used:0.3925891s
  Estimated Memory Used:24059.904KB

Next we will illustrate more features of this methodology of combining type checking of ATS
programming langauge with model checking technique to verify properties of concurrent programs.

Table of Contents
--------------------

.. toctree::
   :maxdepth: 2

   sec01/content
   sec02/content
   sec03/content
   sec04/content
   sec05/content
   sec06/content
   sec07/content
   sec08/content

.. Example of Four-Slot
.. 
.. .. literalinclude:: 20_four_slot.dats
..  :language: text
..  :linenos:

Bibliography
--------------------------

.. [1] http://ats-lang.sourceforge.net/EXAMPLE/EFFECTIVATS/Producer-Consumer/main.html

