
.. include:: ../conats.hrst

.. Properties across the boundry of threads

Accessing Global Ghost Variables
===============================================

Global ghost variables
--------------------------------------------------------

To facilite programmers to state the properties across the boundry of threads, we
provide the concept of global ghost variables. (As being ghost, any flow of data from
such variables to the operational state of the program is forbidden.) Programmers
are also required to give identities to ghost variables, which provides a way to bridge
model checking and type checking for program development. The following example
demonstrates this concept.

.. code-block:: text
  :linenos:

    stacst sid_init: sid
    extern val mc_init: mc_gv_t sid_init
    
    fun exec (x: int): void = let
    
      fun foo {init: pos}(pf: int_value_of (sid_init, init) | x: int): int = x
    
      prval (pf | init) = mc_get_int (mc_init)
      
      // mc_assert cannot be omitted though it is ghost code.
      prval () = mc_assert (init > 0)
      
      val _ = foo (pf | x)
    in
    end
    
    val tid1 = conats_tid_allocate ()
    
    val () = conats_thread_create(exec, 0, tid1)
    
    prval () = mc_set_int (mc_init, 1)
    
    
    %{$
    // #assert main deadlockfree;
    
    #assert main |= G sys_assertion;
    
    %}
    
We explain this example in details as follows:

.. code-block:: text

    stacst sid_init: sid
    extern val mc_init: mc_gv_t sid_init

*stacst* declares a
constant *sid_init* in the *statics* of ATS. This contant serves as the identifier of a
ghost variable. *extern val* declares a value *mc_init*, which is the counterpart of
*sid_init* in the dynamics of ATS. (In the future, only *stacst* is needed after we simplify the model
generation process.)

.. code-block:: text

    fun foo {init: pos}(pf: int_value_of (sid_init, init) | x: int): int = x
    
The type of function *foo* states that a proof that ghost variable *sid_init* used to
be positive is needed to invoke the function. Therefore, if we erase the ghost code
*mc_assert* from the following code

.. code-block:: text

    fun exec (x: int): void = let
    
      fun foo {init: pos}(pf: int_value_of (sid_init, init) | x: int): int = x
    
      prval (pf | init) = mc_get_int (mc_init)
      
      // mc_assert cannot be omitted though it is ghost code.
      prval () = mc_assert (init > 0)
      
      val _ = foo (pf | x)
    in
    end

the type checker of ATS would complain that there exists unsolved constraint in the
type checking process. From the example, we can see that a set of well designed
interfaces for functions can force programmers to incorporate model checking method
during the development process. The complete program can be downloaded here
:download:`24_global_ghost_variable.dats`. Because of the following code

.. code-block:: text

  val tid1 = conats_tid_allocate ()
  
  val () = conats_thread_create(exec, 0, tid1)
  
  prval () = mc_set_int (mc_init, 1)

The program stands a chance of making the 
*mc_assert* (in function *exec*) to fail since the ghost variable is set to 1 after 
creating a new thread to
execute function *exec*. The model checking process can help us detect such problem.

Atomicity in ghost code
--------------------------------

For specification purpose, sometimes it's necessary to group sereral ghost code into
one atomic step. We provide two ghost primitives *mc_atomic_start* and *mc_atomic_end* 
to mark the scope for an atomic step, which we call an atomic scope, consisting of both 
ghost code and operational code. The following program shows the usage of the atomic
step.

.. code-block:: text
  :linenos:

    stacst mid: sid
    
    extern val mc_m: mc_gv_t mid
    
    fun foo1 (): void = let
      prval () = mc_atomic_start()
      prval () = mc_set_int (mc_m, 3)
      prval () = mc_set_int (mc_m, 4)
      prval () = mc_atomic_end()
    in
    end
    
    fun foo2 (x: int): void = let
      prval (pf | x) = mc_get_int (mc_m)
      prval () = mc_assert (x <> 3)
    in
    end
    
    val tid1 = conats_tid_allocate ()
    
    val () = conats_thread_create(foo2, 0, tid1)
    
    val () = foo1 ()
    
The *mc_assert* in function foo2 succeeds because the state in which the ghost
variable *mc_m* is set to 3 is not observable by other threads. The complete code
can be downloaded here :download:`18_atomic_opr.dats`.

Currently, it's programmers' responsibility to make sure that only primitives for
accessing ghost variables (*mc_set_int*, *mc_get_int*) and primitives for accessing
global references (*conats_atomref_update*, *conats_atomref_get*,
*conats_atomarrayref_update*, *conats_atomarrayref_get*) can appear in an atomic scope. 
Also they have to make sure that an atomic scope can contain at most one operational 
primitive for accessing global reference while there's no 
limit for the number of primitives for accessing ghost variables.











