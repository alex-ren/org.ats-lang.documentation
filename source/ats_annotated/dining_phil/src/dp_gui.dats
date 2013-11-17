(*
**
**
**
*)

(* ****** ****** *)

(*
Copy from
Assignment 3:
Class: BU CAS CS520, Fall, 2013
Due: Thursday, the 26th of September, 2013
*)

(* ****** ****** *)
//
#include
"share/atspre_define.hats"
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

staload
UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libc/SATS/time.sats"

(* ****** ****** *)

staload "{$CAIRO}/SATS/cairo.sats"

(* ****** ****** *)


staload "{$GTK}/SATS/gdk.sats"
staload "{$GTK}/SATS/gtk.sats"
staload "{$GLIB}/SATS/glib.sats"
staload "{$GLIB}/SATS/glib-object.sats"

(* ****** ****** *)

staload "mythread.sats"

// staload "libc/SATS/stdlib.sats"
staload "libc/SATS/unistd.sats"


staload "dp_observer.sats"
dynload "dp_observer.dats"

staload "DiningPhil.sats"
dynload "DiningPhil.dats"
(* ****** ****** *)

%{^
typedef
struct { char buf[32] ; } bytes32 ;
%} // end of [%{^]
abst@ype bytes32 = $extype"bytes32"

(* ****** ****** *)

%{^
#define mystrftime(bufp, m, fmt, ptm) strftime((char*)bufp, m, fmt, ptm)
%} // end of [%{^]

(* ****** ****** *)

extern fun worker (darea: !GtkDrawingArea1): void

(* ****** ****** *)
val x: ref int = ref<int>(0)
val cg: ref double = ref<double>(0.0)
val cb: ref double = ref<double>(1.0)


(* ****** ****** *)

%{^
typedef char **charptrptr ;
%} ;
abstype charptrptr = $extype"charptrptr"


(* ****** ****** *)
(* ****** ****** *)
extern
fun{} fexpose (!GtkDrawingArea1): gboolean

implement{
} fexpose (darea) = let
  val () = draw_drawingarea (darea) in GFALSE
end // end of [fexpose]

extern fun{
} dp_anime_main (): void

(* ****** ****** *)

#define nullp the_null_ptr

#define W 400
#define H 400

implement{}
dp_anime_main
  ((*void*)) = () where
{
//
val win0 =
  gtk_window_new (GTK_WINDOW_TOPLEVEL)
val win0 = win0
val () = assertloc (ptrcast(win0) > 0)
val () = gtk_window_set_default_size (win0, (gint)W, (gint)H)
//
val opt = stropt_some"dining philosopher"
val issome = stropt_is_some(opt)
//
val () =
if issome then let
  val title = stropt_unsome (opt)
in
  gtk_window_set_title (win0, gstring(title))
end // end of [if] // end of [val]
//
val darea =
  gtk_drawing_area_new ()
val p_darea = gobjref2ptr (darea)
val () = assertloc (p_darea > 0)
val () = gtk_container_add (win0, darea)
//
val _sid = g_signal_connect
(
  darea, (gsignal)"expose-event", G_CALLBACK(fexpose), (gpointer)nullp
)
//
val _sid = g_signal_connect
(
  win0, (gsignal)"delete-event", G_CALLBACK(gtk_main_quit), (gpointer)nullp
)
val _sid = g_signal_connect
(
  win0, (gsignal)"destroy-event", G_CALLBACK(gtk_widget_destroy), (gpointer)nullp
)
//
val () = gtk_widget_show_all (win0)
//
val () = g_object_unref (win0) // HX: refcount of [win0] decreases from 2 to 1
//
// todo: Why does this pass the typechecking?
val () = mythread_create_cloptr (llam () => worker (darea))
val () = dp_init ()

//
val ((*void*)) = gtk_main ((*void*))

val () = g_object_unref (darea)
//
} // end of [dp_anime_main]

(* ****** ****** *)

implement
main0 (argc, argv) =
{
//
var argc: int = argc
var argv: charptrptr = $UN.castvwtp1{charptrptr}(argv)
//
val () = $extfcall (void, "gtk_init", addr@(argc), addr@(argv))

val ((*void*)) = dp_anime_main ((*void*))
//
} (* end of [main0] *)

implement worker (darea) = let
  val () = ignoret (sleep(1))
  //
  val (fpf_win | win) = gtk_widget_get_window (darea)
  //
  val isnot = g_object_isnot_null (win) 
  //
  prval () = minus_addback (fpf_win, win | darea)
  //
  in
  //
  if isnot then let
    var alloc: GtkAllocation
    val () = gtk_widget_get_allocation (darea, alloc)
    val () = gtk_widget_queue_draw_area (darea, (gint)0, (gint)0, alloc.width, alloc.height)
  in
    worker(darea)
  end else
    ()
  // end of [if]
  //
end // end of [worker]

(* ****** ****** *)

(* end of [dp_gui.dats] *)

