
// Routine head files
#define CONATSCONTRIB
"https://raw.githubusercontent.com/alex-ren/org.ats-lang.postiats.jats/master/utfpl/src/jats/utfpl/stfpl/test"
staload "{$CONATSCONTRIB}/conats.sats"

(* ************* ************* *)

fun foo (): void = let
  prval () = mc_assert (false)
in
end

val () = foo ()

%{$

#assert main |= G sys_assertion;

%}



