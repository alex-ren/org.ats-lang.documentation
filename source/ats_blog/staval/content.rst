.. Document for usage of retrieving value in the statics of ATS.
   Starting Date: 10/23/2014

**********************************
Get value in the statics of ATS
**********************************

.. todo::

  organize


ATS-Postiats/prelude/basics_dyn.sats



.. code-block:: none

  dataprop
  EQINT (int, int) = {x: int} EQINT (x, x)
  //
  extern prfun eqint_make {x,y:int | x == y} (): EQINT (x, y)
  //
  extern prfun
  eqint_make_gint
    {tk:tk}{x:int} (x: g1int (tk, x)): [y: int] EQINT (x, y)
  
  fun goo {x:int | x == 1} (): void = ()
  
  fun foo (): void = let
    val x = 1
    val [y:int] EQINT () = eqint_make_gint (x)
  in
    goo {y} ()
  end

