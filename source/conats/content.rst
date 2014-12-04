.. Document for Model Checking ATS

Model Checking ATS
=====================================

In this project, we focus on integrating model checking techniques seamlessly into
the development of ATS program. Before going to the details, let's have a quick look
of the process of verifying a concurrent ATS program.

The Producer-consumer problem is a classic one in concurrent programming. A recommanded
implementation is described in the documentation of ATS [1]_. It involves usage of
mutex and condition. The type system of ATS can help eliminate some common mistakes.
However, a well-typed implementation can still have deadlock. Model checking technique
can then help detect such bug and provide the corresponding counterexample.

The code snippets for Producer-consumer problem are given below. First, we create the
shared buffer for producer and consumer to communicate with each other. To simplify
the problem without losing generosity, the buffer we use is represented by a 
reference to an integer. To produce one item means to increase the number stored in 
the buffer. We call the function *conats_atomref_create* to create such reference.
We use the unsafe feature of ATS to cast such reference into a linear object, which
is then included by a shared object *s* created by function *conats_shared_create*.


.. code-block:: text

    val gref = conats_atomref_create (0)
    absviewtype lin_atomref (a:t@ype)
    
    val lin_ref: lin_atomref int = $UN.castvwtp0 (gref)
    
    val s = conats_shared_create {lin_atomref (int)}(lin_ref)



First of all, we provide a library with support for concurrent programming such
as creating new threads, synchronization primitives (mutex, condition), and etc. 
All these supports are given appropriate types in ATS to reduce the possibilities
of ill usage. 


.. literalinclude:: 16_reader_writer.dats
  :language: text
  :linenos:




Bibliography
=====================

.. [1] http://ats-lang.sourceforge.net/EXAMPLE/EFFECTIVATS/Producer-Consumer/main.html

