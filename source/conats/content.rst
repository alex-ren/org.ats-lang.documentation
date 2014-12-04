.. Document for Model Checking ATS

Model Checking ATS
=====================================

In this project, we focus on integrating model checking techniques seamlessly into
the development of ATS program. Before going to the details, let's have a quick look
of the process of verifying a concurrent ATS program.

The Producer-consumer problem is a classic one in concurrent programming. A recommanded
implementation is described in the documentation of ATS [1]_. It involves usage of
mutex and condition variable. The type system of ATS can help eliminate some common mistakes.
However, a well-typed implementation can still have deadlock. Model checking technique
can then help detect such bug and provide the corresponding counterexample.

The code snippets for Producer-consumer problem are given below. First, we create the
shared object for producer and consumer to communicate with each other. To simplify
the problem without losing generosity, the shared object just contains a linear buffer
holding one integer. To produce one item means to increase the number stored in 
the buffer. We give out the definition of the linear buffer 

A shared object is similar to the concept of monitor in the field of concurrent 
programming. It contains a mutex and a condition variable, which are used to protect
the resource, which in the example is of linear type *lin_buffer int*.

We use three functions in the definitions of those operations of the linear buffer,
which are *conats_atomref_create*, *conats_atomref_get*, and *conats_atomref_update*.
They are library functions which have special semantics to the model checker we build.
In short, to be able to model check the ATS program, we have to use such library
functions to build the linear buffer. The types for these library functions can be found
in `conats.sats <https://github.com/alex-ren/org.ats-lang.postiats.jats/blob/master/
utfpl/src/jats/utfpl/stfpl/test/conats.sats>`_.


.. code-block:: text
  :linenos:

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
    
    val lin_ref: lin_buffer int = lin_buffer_create (0)
    
    val s = conats_shared_create {lin_buffer (int)}(lin_ref)
        
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


Bibliography
=====================

.. [1] http://ats-lang.sourceforge.net/EXAMPLE/EFFECTIVATS/Producer-Consumer/main.html

