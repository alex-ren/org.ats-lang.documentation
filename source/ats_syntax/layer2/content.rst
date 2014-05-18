.. Document for the syntax tree of layer 2 of ATS-Postiats.
   Date: 06/17/2014

Mapping from source code to data structure
=============================================

Function declaration and implementation
------------------------------------------
We use the following source code as an example.

.. code-block:: none

   abstype ty (int, int)
   extern fun foo {x: int} {y: int} (x: ty (x, y), y: int y): 
     [q: int] int q

   implement foo {x}{y}(x, y) = 3

For the function declaration, we would have a *D2Cdcstdecs*, which contains a list of
*d2cst*. Each *d2cst* has type information of the defined constant. In this example, the
type of function *foo* is quite complicated, which involves universal type (*S2Euni*) as
well as existential type (*S2Eexi*).







