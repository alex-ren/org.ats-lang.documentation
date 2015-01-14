
.. index::
   single: Virtual Lock

Virtual Lock
=======================

Improper handling of resources (e.g. memory) in a program may lead to various
bugs (e.g. memroy leak) in sequential programs. The problem gets even worse
when entering the concurrent domain, in which simultaneous access to shared resource by
multiple threads is feasible. One example is that we may lose the integrity of data if
two threads are using a shared memory to transfer data. Techniques for solving 
this problem generally rely on mutual exclusion principles to control access to shared
resources. Mutual exclusion introduces a measure of synchronization, but with the cost of
losing efficiency. With a deliberate design, sometimes we can remove the need for 
synchronization while maintaining the desired property of mutual exclusion.
Simpson's four-slot fully asynchronous communication mechanism [1]_ demonstrates such
idea. However, it's very difficult to verify that the deemed mutual exclusion
property actually holds in the design. To tackle this problem, we provide two
primitives supporting the concept of "virtual lock" to allow programmers to 
specify assumptions of mutual exclusion to various
granularities according to their design. And such assumption can then be verified by
our model checker.

Let's illustrate the usage of "virtual lock" using the following example of two-slot
mechanism. Consider the scenario in which one writer and one reader try to
communicate via a shared resource consisting of multiple memory regions 
(two in this example). Due to hardware
constraint, access to each memory region cannot be done atomically. Therefore, reader
may get inconsistent data if writer is writing the same region at the same time. The
following code shows the proposed types for the shared resource (*dataslots_t*) as well as the
interfaces for accessing it.

.. code-block:: text
  :linenos:
    
    abstype dataslots_t (t@ype, int)
    
    absviewtype own_slot_vt (int)
    
    fun dataslots_create {a:t@ype} {x:pos} (
      x: int x, v: a): dataslots_t (a, x)
    
    fun dataslots_update {a:t@ype} {x,i:nat | i < x} 
      ( vpf: own_slot_vt (i)
      | slots: dataslots_t (a, x), i: int i, v: a
      ): (own_slot_vt i | void)
    
    fun dataslots_get {a:t@ype} {x,i:nat | i < x} 
      ( vpf: own_slot_vt (i)
      | slots: dataslots_t (a, x), i: int i
      ): (own_slot_vt i | a)

The usage of linear type *own_slot_vt* states clearly that
*dataslots_update* and *dataslots_get* require mutual exclusion on the memory region
to be accessed. Normally, programmers ensure such property by the
usage of synchronization primitives (e.g. mutex). However, in the following code, we
try to gain mutual exclusion by the usage of a few global variables
the access for which is atomic. The code is shown below.

.. code-block:: text
  :linenos:

    typedef data_t = dataslots_t (int, 2)
    val data: data_t = dataslots_create (2, 0)
    
    typedef int2 = [i: int | i >= 0 && i <= 1] int i
    
    // control variables
    val latest = conats_atomref_create {int2} (0)
    
    fun write (item: int): void = let
      val index = 1 - conats_atomref_get (latest)
    
      prval vpf = mc_acquire_ownership (index)
      val (vpf | _) = dataslots_update (vpf | data, index, item)
      prval () = mc_release_ownership (vpf)
    
      val () = conats_atomref_update (latest, index)
    in
    end
    
    fun read (): int = let
      val index = conats_atomref_get (latest)
    
      prval vpf = mc_acquire_ownership (index)
      val (vpf | item) = dataslots_get (vpf | data, index)
      prval () = mc_release_ownership (vpf)
    in
      item
    end
    
In the example, the shared resource (*data_t*) contains two regions (slots). *lastest*
is a global reference for an integer, which is created by the primitive 
*conats_atomref_create*. (Primitives *conats_atomref_create*,
*conats_atomref_get*, and *conats_atomref_update* are provided as an extension to ATS
to support concurrent programming.) To pass the type checking of ATS, we use two 
functions *mc_acquire_ownership* and *mc_release_ownership* to generate and destroy
the linear ghost value (*vpf*), which serves as the warranty for mutual exclusion.
*mc_acquire_ownership* and *mc_release_ownership* are not primitives. Instead, they
are user-defined ghost functions. Their implementation is shown below.

.. code-block:: text
  :linenos:

      prfun mc_acquire_ownership .<>. {i: nat}
        (i: int i): own_slot_vt (i) = mc_vlock_get (i, 0, 1, 1)
    
      prfun mc_release_ownership .<>. {i: nat}
        (vpf: own_slot_vt (i)): void = mc_vlock_put (vpf)

The two ghost functions are built upon two primitives *mc_vlock_put* and
*mc_vlock_get*. Intuitively, *mc_vlock_get (x, y, a, b)* indicates the acquision of
a *virtual lock* covering a rectangle with *(x, y)* as the upper left corner, *a* as
the width (x-axis), and *b* as the height (y-axis), and *mc_vlock_put* indicates the
release of the lock. And our model
checker would check that under no circumstances would two threads try to acquire two
virtual locks covering overlapping areas simutaneously. And this serves as the 
verification of mutual exclusion.
To model checking the example, we would need to add the following code to implement
those interfaces for accessing shared resource.

.. code-block:: text
  :linenos:

    fun dataslots_create {a:t@ype} {x:pos} (
      x: int x, v: a): dataslots_t (a, x) =
       conats_atomarrayref_create {a} (x, v)
  
    fun dataslots_update {a:t@ype} {x,i:nat | i < x} 
      ( vpf: own_slot_vt (i)
      | slots: dataslots_t (a, x), i: int i, v: a
      ): (own_slot_vt i | void) = let
      val () = conats_atomarrayref_update (slots, i, v)
    in
      (vpf | ())
    end
  
    fun dataslots_get {a:t@ype} {x,i:nat | i < x} 
      ( vpf: own_slot_vt (i)
      | slots: dataslots_t (a, x), i: int i
      ): (own_slot_vt i | a) = let
      val v = conats_atomarrayref_get (slots, i)
    in
      (vpf | v)
    end

In the aforementioned code, this implementation is actually based on the 
primitives for creating and accessing array. This is not necessary if our focus is
to verify the validity of mutual exclusion.

The complete code can be downloaded here :download:`20_1_two_slot_acm.dats`. Without
much thinking, we know that this implementation cannot pass model checking since
writer just switches between two slots. Going
further, the implementation (:download:`20_2_three_slot_acm.dats`) using three slots 
doesn't work either. And based on the implementation using four slots
(:download:`20_3_four_slot_acm.dats`), we verify that Simpson's four-slot asynchronous
mechanism possesses the acclaimed mutual exclusion property.

Bibliography
--------------------------

.. [1] H.R. Simpson, Four-slot fully asynchronous communication mechanism




