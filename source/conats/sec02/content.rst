

.. include:: ../conats.hrst


Towards Concurrent Program
=====================================

The type system of ATS consists of both dependent types and linear types. Please refer
to ATS' documentation for its application in constructing verifiably correct sequential
progarm. Linear types are of help to certain extent in ensuring safety properties about
mutual exclusion. However, in general, the type system of ATS has difficulty in
specifying properties of concurrent programs, e.g. invariants of objects across threads, 
absence of deadlock, liveness properties, and etc. Such incapability triggers our
research in corporating model checking techniques into the verification process of ATS
program.

Primitives for Concurrent Programming
-----------------------------------------

But first of all, programmers have to be able to write concurrent programs in ATS.
Currently, we add a set of primitives into ATS programming language to support concurrent
programming in a style similar to using pthead. In the near future, we will add more 
primitives (e.g. channel, future) supporting different styles of concurrent programming.

The declarations of these primitives can be found in |conats.sats|_. In the
:ref:`tutorial_label`, we already use *conats_shared_create*, *conats_shared_acquire*,
*conats_shared_condwait*, *conats_shared_signal*, and *conats_shared_release*, whose
types are declared as follows:

.. code-block:: text
  :linenos:

    abstype shared_t (viewt@ype, int)
    typedef shared (a:viewt@ype) = shared_t (a, 1)
    
    fun conats_shared_create {a: viewt@ype} (ele: a): shared (a)
    
    fun conats_shared_acquire {a: viewt@ype} {n:pos} (s: shared_t (a, n)): a
    fun conats_shared_release {a: viewt@ype} {n:pos} (s: shared_t (a, n), ele: a): void
    
    fun conats_shared_signal {a: viewt@ype} (s: shared (a), ele: a): a
    fun conats_shared_condwait {a: viewt@ype} (s: shared (a), ele: a): a
    


*conats_shared_create* creates a shared object (of type *shared a*) holding
a linear buffer. The concept of shared object is similar to that of monitor
[1]_. The types of the aforementioned functions guarantee they are invoked
appropriately in a non-object-oriented language like ATS. (E.g. we have to call
*conats_shared_acquire* before invoking *conats_shared_condwait* and
*conats_shared_signal*. From the perspective of pthread programming, a shared object
consists of a mutex and a condition variable working together for synchronization
purpose.

However, sometimes it's not enough for a shared object to contain just one condition
varialbe. For example, in :ref:`tutorial_label`, the shared object has only one
condition varialbe, which is used to indicate two situations: buffer is full or
empty. The example has no deadlock because it only has one producer and one consumer.
Simply adding one more consumer to the example would lead to potential deadlock. The
complete code can be downloaded here :download:`16_1_producer_consumer_m_1.dats 
<16_1_producer_consumer_m_1.dats>`. You can also find this example at our website |mcats|_.
One example of the potential deadlock can be thought as follows: Initially, the
shared buffer is empty. Two consumers come and wait on the shared object. The
producer comes and puts one element into the buffer and then wake up one consumer.
However, the newly active consumer doesn't execute instantly. Instead, the
producer comes again, tries to put another element into the buffer, and has to wait
on the shared object since the capacity of the buffer is 1. Then the newly active
consumer gets one element out of the buffer and wakes up another consumer. At this
moment, the buffer is empty, the producer is waiting, and two consumers won't signal
the shared buffer any more. And this leads to a deadlock. The counterexample found by
the model checker by Breadth First Search confirms with our speculation.

To solve this problem, we also provide another version of shared object which
contains multiple condition variables. The types of related functions are shown
below.

.. code-block:: text
  :linenos:

    abstype shared_t (viewt@ype, int)
    
    fun conats_sharedn_create {a: viewt@ype} {n:pos} (ele: a, n: int n): shared_t (a, n)

    fun conats_sharedn_signal {a: viewt@ype} {i,n:nat | i < n} (s: shared_t (a, n), i: int i, ele: a): a

    fun conats_sharedn_condwait {a: viewt@ype} {i,n:nat | i < n} (s: shared_t (a, n), i: int i, ele: a): a

With such shared object, we can now set up two condition variables handling both full
and empty buffers separately. The complete code can be download here 
:download:`16_2_producer_consumer_m_1_2cond.dats`. A snappet of code for the producer
is shown below.
    
.. code-block:: text
  :linenos:

    // Keep adding elements into buffer.
    fun producer (x: int):<fun1> void = let
      val db = conats_shared_acquire (s)
    
      fun insert (db: demo_buffer):<cloref1> demo_buffer = let
        val (db, isful) = demo_buffer_isful (db)
      in
        if isful then let
          val db = conats_sharedn_condwait (s, NOTEMP, db)
        in
          insert (db)
        end else let 
          val (db, isnil) = demo_buffer_isnil (db)
          val db = demo_buffer_insert (db)
        in
          if isnil then conats_sharedn_signal (s, NOTFUL, db)
          else db
        end
      end
      
      val db = insert (db)
      val () = conats_shared_release (s, db); 
    in
      producer (x)
    end

In this implemenation, producer only signals the condition variable when the buffer
is actually empty at that moment. This would lead to the missing of signal if we have
multiple producers and consumers. (Please refer to [2]_.) In the example
:download:`16_3_producer_consumer_m_m_signal.dats`, there is two producers, each of
which inserts only one element, and two consumers, each of which takes out one
element. And the problem of miss signal would lead to deadlock. The model checker
would demonstrate this by a counterexample. One remedy is to sigal the condition
variable every time. The other is to use *conats_sharedn_wait* instead of
*conats_sharedn_signal*.





Bibliography
------------------------

.. [1] http://en.wikipedia.org/wiki/Monitor_%28synchronization%29
.. [2] todo



