
#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"

staload "libats/ML/SATS/basis.sats" // for list0 and array0

staload "libats/ML/SATS/list0.sats"
staload _ = "libats/ML/DATS/list0.dats"

staload "libats/ML/SATS/array0.sats"
staload _ = "libats/ML/DATS/array0.dats"


implement main0 () = let

  val out = stdout_ref

  // list int
  val xs = (list)$arrpsz{int}(6, 7, 8, 9)
  val () = fprintln!(out, xs)
  val () = fprintln!(out, xs, ", ")  // with seperator
  val () = (fprint!(out, xs); fprintln!(out))

  // list0 int
  val xs = (g0ofg1 (xs)): list0 int
  val () = fprintln!(out, xs)  // overload fprint_list0
  val () = fprintln!(out, xs, ", ")  // overload fprint_list0_sep
  val () = (fprint_list0 (out, xs); fprintln!(out))  // without seperator
  val () = (fprint_list0_sep (out, xs, ", "); fprintln!(out))  // with seperator

  // list0 double
  val xs = $list{double}(1.0, 2.0, 3.0)
  val xs = g0ofg1 (xs)
  val () = (fprint!(out, xs, ", "); fprintln!(out))

  // array0 int
  val xs = array0_make_elt<int> (g0i2u(3), 0)
  val () = fprintln!(out, xs)  // overload fprint_array0
  val () = fprintln!(out, xs, ", ")  // overload fprint_array0_sep
  val () = (fprint_array0 (out, xs); fprintln!(out))  // without seperator
  val () = (fprint_array0_sep (out, xs, ", "); fprintln!(out))  // with seperator

  // array0 double
  val xs = (array0)$arrpsz{double}(0.0, 1.0, 2.0, 3.0, 4.0, 5.0)
  val () = fprintln!(out, xs)  // overload fprint_array0
  val () = fprintln!(out, xs, ", ")  // overload fprint_array0_sep

in
end


