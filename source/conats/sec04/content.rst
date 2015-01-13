
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
Simpson's four-slot fully asynchronous communication mechanism demonstrates such
idea. However, it's very difficult to verify that the deemed mutual exclusion
property actually holds in the design. To tackle this problem, we provide two
primitives supporting the concept of "virtual lock" to allow programmers to 
specify mutual exclusion assumption to the
granularity according to their design. And such assumption can then be verified by
our model checker.

Let's illustrate the usage of "virtual lock" using the following example of two-slot
mechanism. Consider the scenario in which one writer and one reader try to
communicate via a shared resource consisting of multiple memory regions 
(two in this example). Due to hardware
constraint, access to each memory region cannot be done atomically. Therefore, reader
may get inconsistent data if writer is writing the same region at the same time. The
following code shows the proposed types for the shared resource as well as the
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
to be accessed. Normally, such assumption of mutual exclusion would come from the
usage of synchronization primitives (e.g. mutex)

todo



