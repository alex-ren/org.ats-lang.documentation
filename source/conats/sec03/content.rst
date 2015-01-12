
.. include:: ../conats.hrst

Properties across the boundry of threads
===============================================

todo

Global ghost variables
--------------------------------------------------------

To facilite programmers to state the properties across the boundry of threads, we
provide the concept of global ghost variables. (As being ghost, any flow of data from
the such variables to the operational state of the program is forbidden.) Programmers
are also required to give identities to ghost variables, which provides a way to bridge
model checking and type checking for program development. The following example
demonstrates this concept.

.. code-block:: text
  :linenos:

    xx

We explains this example in details as follows:

.. code-block:: text

  xx

*stacst* declares a
constant *sid_init* in the *statics* of ATS. This contant serves as the identity of a
ghost variable. *extern val* declares a ghost variable *mc_init* with the identity
*sid_init*. (In the future, only *stacst* is needed after we simplify the model
generation process.)

.. code-block:: text

  xx

The type of function *foo* states that a proof that ghost variable *sid_init* used to
be positive is needed to invoke the function. Therefore, if we erase the ghost code
*mc_assert* from the following code

.. code-block:: text

  xx

the type checker of ATS would complain that there exists unsolved constraint in the
type checking process. From the example, we can see that a set of well designed
interfaces for functions can force programmers to incorporate model checking method
during development process.












