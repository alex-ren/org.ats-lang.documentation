.. Blogs for documenting various topics related to ATS-Postiats.

ATS-Postiats' Blog
==================================

Some other sources of ATS: `ATS Wiki <https://github.com/githwxi/ATS-Postiats/wiki>`_.


Contents:

.. toctree::
   :maxdepth: 2

   staload_var/content
   print_misc/content
   misc/content
   ats2cs/content
   staval/content
   makefile/content

Global value with linear type
------------------------------------

Global values with linear type can only be used in the global scope. They cannot be used 
inside a function scope. For example, the following code cannot pass the type
checking.

.. code-block:: none

    staload
    UNSAFE = "prelude/SATS/unsafe.sats"
    
    absvtype VT
    
    extern fun create (): VT
    extern fun use (v: !VT): void
    
    val v = create ()
    
    fun temp (): void = let
      val () = use (v)
    in
    end
    
    implement main0 () = ()

ATS compiler conplains that
  regexp_main.dats: 177(line=15, offs=17) -- 178(line=15, offs=18): error(3): the linear dynamic variable [v$64(-1)] is expected to be local but it is not.
  regexp_main.dats: 177(line=15, offs=17) -- 178(line=15, offs=18): error(3): a linear component of the following type is abandoned: [S2Ecst(VT)].
  patsopt(TRANS3): there are [2] errors in total.
  exit(ATS): uncaught exception: _2home_2alex_2programs_2ats2_github_2ATS_2dPostiats_2src_2pats_error_2esats__FatalErrorExn(1025)
  
Usually we would cast the global value of linear type into non-linear type, and cast
it back inside a function scope, which is shown below::
  staload
  UNSAFE = "prelude/SATS/unsafe.sats"
  
  absvtype VT
  
  extern fun create (): VT
  extern fun use (v: !VT): void
  
  val v = create ()
  
  val ele = $UNSAFE.castvwtp0{ptr}(v)
  
  fun temp (): void = let
    val v1 = $UNSAFE.castvwtp0{VT}(ele)
    val () = use (v1)
    prval ((*void*)) = $UNSAFE.cast2void (v1)
  in
  end
  
  implement main0 () = ()



