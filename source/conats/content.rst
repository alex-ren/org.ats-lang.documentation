.. Document for Model Checking ATS

Model Checking ATS
=====================================

In this project, we focus on integrating model checking techniques seamlessly into
the development of ATS program and ultimately build a practical system for 
verifying concurrent ATS program.

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
in the file `conats.sats <https://github.com/alex-ren/org.ats-lang.postiats.jats/blob/master/
utfpl/src/jats/utfpl/stfpl/test/conats.sats>`_. It also contains some other primitives used
for model checking, which we shall explain as we see more examples.

The complete implementation for producer-consumer problem can be found here todo. 
You can also read, modify, and verify the implementation via our website for model 
checking todo. We illustrate some of the code snippets below.

As indicated in [1]_, a shared object contains a linear object, which in this example is
a linear buffer. The primitives provided in *conats.sats* do not support such type.
Therefore we define a linear type *lin_buffer* as well as corresponding functions for
manupulating objects of such type, which is given below.

.. code-block:: text
  :linenos:

    // Define linear buffer to prevent resource leak.
    absviewtype lin_buffer (a:t@ype)
    
    fun lin_buffer_create {a:t@ype} (
      data: a): lin_buffer a = let
      val ref = conats_atomref_create (data)
      val lref = $UN.castvwtp0 {lin_buffer a} (ref)
    in
      lref
    end
    
    fun lin_buffer_update {a:t@ype} (
      lref: lin_buffer a, data: a): lin_buffer a = let
      val ref = $UN.castvwtp0 {atomref a} (lref)
      val () = conats_atomref_update (ref, data)
      val lref = $UN.castvwtp0 (ref)
    in
      lref
    end
    
    fun lin_buffer_get {a:t@ype} (
      lref: lin_buffer a): (lin_buffer a, a) = let
      val ref = $UN.castvwtp0 {atomref a} (lref)
      val v = conats_atomref_get ref
      val lref = $UN.castvwtp0 (ref)
    in
      (lref, v)
    end

Three functions *conats_atomref_create*, *conats_atomref_update*, and
*conats_atomref_get* are declared in *conats.sats*. Intuitively, they are used for
creating a mutable object whose content can be accessed in an atomic manner.

In our example, we only need a linear buffer whose content is an integer. The following
code defines the type for such linear buffer *demo_buffer* and some auxiliary functions
for accessing it.

.. code-block:: text
  :linenos:

    // Define linear integer buffer for demonstration.
    viewtypedef demo_buffer = lin_buffer int
    
    fun demo_buffer_isful (buf: demo_buffer): (demo_buffer, bool) = let
      val (buf, len) = lin_buffer_get (buf)
    in
      (buf, len > 2)  // Assume the buffer can only hold 2 elements.
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

One thing worth mentioning is the number 2 we choose as the capacity of the virtual
buffer shared by producer and consumer. In reality, a shared buffer may have a large
capacity. But a big number may cause model checking not to be able to detect the
potential bugs. Arguably, if our implementation is correct for a small capacity of
shared buffer, it has better chances to be correct as well for large capacity.
    
Now we can create the linear buffer holding integer and then put it into a shared object
which can be accessed by multiple threads.
    
.. code-block:: text
  :linenos:

    // Create a buffer for model construction.
    val db: demo_buffer = lin_buffer_create (0)
    
    // Turn a linear buffer into a shared buffer.
    val s = conats_shared_create {demo_buffer}(db)
    
*conats_shared_create* is a function declared in *conats.sats*, whose semantics is about
creating an shared object protecting its content via mutex and condition variables.

todo
In the following code, *producer* is a function which keeps increasing the
counter inside the linear buffer until it reaches 2, and then wait there
until the counter gets decreased. *consumer* is a function which keeps decreasing
the counter inside the linear buffer until it reaches 0, and then wait there
until the counter gets increased. 

.. code-block:: text
  :linenos:
    
    fun producer (x: int):<fun1> void = let
      val ref = conats_shared_acquire (s)
    
      fun loop (ref: lin_buffer int):<cloref1> void = let
        val (ref, v) = lin_buffer_get (ref)
      in
        if v = 2 then let
          val ref = conats_shared_condwait (s, ref)
        in
          loop (ref)
        end else let 
          val (ref, v) = lin_buffer_get (ref)
          val ref = lin_buffer_update (ref, v + 1)
          val ref = conats_shared_signal (s, ref)
        in
          loop (ref)
        end
      end
    in
      loop (ref)
    end
    
    fun consumer (x: int):<fun1> void = let
      val ref = conats_shared_acquire (s)
    
      fun loop (ref: lin_buffer int):<cloref1> void = let
        val (ref, v) = lin_buffer_get (ref)
      in
        if v = 0 then let
          val ref = conats_shared_condwait (s, ref)
        in
          loop (ref)
        end else let
          val (ref, v) = lin_buffer_get (ref)
          val ref = lin_buffer_update (ref, v - 1)
          val ref = conats_shared_signal (s, ref)
        in
          loop (ref)
        end
      end
    in
      loop (ref)
    end

Due to the usage of linear type of ATS, ATS compiler would complain if a programmer forgets
to acquire the mutex before updating the counter. However, the type checking won't be
able to detect the potential deadlock if the producer or consumer doesn't call the
*conats_shared_signal* function.

To be able to detect such bug, we need to set up the environment in which we can model
checking the implemenation of producer and consumer. In the following code, we simply
create two threads in the program, one for producer and one for consumer.

.. code-block:: text
  :linenos:

    val tid1 = conats_tid_allocate ()
    val tid2 = conats_tid_allocate ()
    
    val () = conats_thread_create(producer, 0, tid1)
    val () = conats_thread_create(consumer, 0, tid2)

We build a tool, which is able to extract a model from the ATS program given above. The
model is encoded in a modeling langauge CSP#. We then use the state-of-art model checker
`PAT <http://www.comp.nus.edu.sg/~pat/>`_ to check the generated model. To inform PAT
that we want to check there's no deadlock, we add the following code to the ATS program.

.. code-block:: text
  :linenos:

    %{$
    #assert main deadlockfree;
    %}

Example of Four-Slot

.. literalinclude:: 20_four_slot.dats
 :language: text
 :linenos:

Bibliography
=====================

.. [1] http://ats-lang.sourceforge.net/EXAMPLE/EFFECTIVATS/Producer-Consumer/main.html

