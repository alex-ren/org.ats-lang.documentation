
//

#include
"share/atspre_define.hats"
#include
"share/atspre_staload.hats"

staload "dp_observer.sats"


staload "{$CAIRO}/SATS/cairo.sats"
staload "{$GTK}/SATS/gdk.sats"
staload "{$GTK}/SATS/gtk.sats"
staload "{$GLIB}/SATS/glib.sats"
staload "{$GLIB}/SATS/glib-object.sats"


staload "libc/SATS/math.sats"
staload "libats/ML/SATS/array0.sats"
staload _ = "libats/ML/DATS/array0.dats"

#define PI M_PI
#define N 5

val cg: ref double = ref<double>(0.0)
val cb: ref double = ref<double>(1.0)

val fork_arr = array0_make_elt<int> (size_of_int(N), 0)

// 0: free
// 1: used by clockwise
// ~1: used by counter clockwise
val () = fork_arr[0] := 0
val () = fork_arr[1] := 1
val () = fork_arr[2] := ~1 
val () = fork_arr[3] := 1
val () = fork_arr[4] := ~1

extern fun draw_plates{l1,l2:agz}(cr: !cairo_ref (l1),
                       src: !cairo_surface_ref (l2), 
                       WH: double,
                       num: int,
                       redius: double): void

extern fun draw_forks {l1,l2:agz} (
            cr: !cairo_ref (l1), 
            sf_fork: !cairo_surface_ref (l2),
            n: int
            ): void

implement inform (phil, fork, release) =
if release then fork_arr[fork] := 0
else if phil = fork then fork_arr[fork] := ~1
else fork_arr[fork] := 1

implement draw_drawingarea (darea) = let
//
val (
  fpf_win | win
) = gtk_widget_get_window (darea)
//
val isnot = g_object_isnot_null (win)
//
in
//
if isnot then let
  val cr = gdk_cairo_create (win)
  prval () = minus_addback (fpf_win, win | darea)
  var alloc: GtkAllocation?
  val () = gtk_widget_get_allocation (darea, alloc)
  
  (* ******************* *)
  val W = gint2int(alloc.width)
  val H = gint2int(alloc.height)
  val WH = min (W, H)
  val WH = g0int2float_int_double (WH)
  val WH2 = WH / 2
  (* ******************* *)
  // val () = cairo_set_source_rgb (cr, 0.0, !cg, !cb)
  // val () = cairo_move_to (cr, 0.0, 0.0)
  // val () = cairo_line_to (cr, WH, WH)
  // val () = cairo_stroke (cr)

  (* ******************* *)

  // 1200 X 1200
  val sf_fork = cairo_image_surface_create_from_png("fork.png");

  // 1130 X 1172
  val image = cairo_image_surface_create_from_png("Dining_philosophers.png")
  val dp_w = cairo_image_surface_get_width (image)
  val dp_h = cairo_image_surface_get_height (image)

  val sf_dp = cairo_image_surface_create (CAIRO_FORMAT_ARGB32, W, H)
  val cr1 = cairo_create(sf_dp)

  val () = cairo_translate(cr1, WH2, WH2);
  val () = cairo_scale(cr1, WH, WH);

  val () = cairo_arc(cr1, 0.0, ~0.22, 0.08, 0.0, 2*PI);
  val () = cairo_clip (cr1)
  val () = cairo_new_path (cr1) /* path not consumed by clip()*/

  val (pf1 | ()) = cairo_save(cr1)
  val () = cairo_scale(cr1, 1.0/dp_w * 1.2, 1.0/dp_h * 1.2);
  val () = cairo_set_source_surface (cr1, image, ~dp_w/2.0, ~dp_h/2.0);
  val () = cairo_paint(cr1);
  val () = cairo_restore(pf1 | cr1);

  // val _ = cairo_surface_write_to_png (sf_dp, "cr1.png")
  // finishing construction cr1 (sf_dp)

  // ================================

  // adjust to center and scale 1
  val () = cairo_translate(cr, WH2, WH2);
  val () = cairo_scale(cr, WH, WH);

  // ============================
  // draw plates
  val (pf2 | ()) = cairo_save(cr);

  // fun cairo_get_target
  //   {l1:agz} (ctx: !xr l1): [l2:agz] vtget0 (xr l1, xrsf l2) = "mac#%"
  // // end of [cairo_get_target]
  val (fpf | sf) = cairo_get_target(cr1)
  val () = draw_plates(cr, sf, WH, N, 2*PI/N)
  prval () = minus_addback (fpf, sf | cr1)
  val () = cairo_restore(pf2 | cr);

  val () = draw_forks(cr, sf_fork, 0)
  // ============================

  val () = cairo_surface_destroy (sf_dp)
  val () = cairo_surface_destroy (image)
  val () = cairo_surface_destroy (sf_fork)
  
  
  val () = cairo_destroy (cr1)
  (* ******************* *)
  val () = cairo_destroy (cr)
in
  // nothing
end else let
  prval () = minus_addback (fpf_win, win | darea)
in
  // nothing
end (* end of [if] *)
end (* end of [draw_drawingarea] *)


implement draw_plates{l1,l2}(cr,src, WH, num, redius) =
if num = 0 then ()
else let
  val () = cairo_rotate(cr, redius)
  val (pf | ()) = cairo_save (cr)
  val () = cairo_scale(cr, 1/WH, 1/WH)
  val () = cairo_set_source_surface (cr, src, ~WH/2, ~WH/2)
  val () = cairo_paint(cr)
  val () = cairo_restore(pf | cr)
in
  draw_plates(cr, src, WH, num - 1, redius)
end

// =============================
// draw a fork from (0, 0) to (0, -0.1)
fun draw_fork_prim {l1,l2:agz} (cr: !cairo_ref (l1), 
            sf_fork: !cairo_surface_ref (l2)): void = let

  val fork_w = cairo_image_surface_get_width (sf_fork);
  val fork_h = cairo_image_surface_get_height (sf_fork);

  // val () = cairo_set_line_width (cr, 0.05)
  // val () = cairo_move_to(cr, 0.0, 0.0)
  // val () = cairo_line_to(cr, 0.0, ~0.1)
  // val () = cairo_stroke(cr)

  val (pf | ()) = cairo_save(cr)
  val () = cairo_scale(cr, 0.2 / fork_w, ~0.2 / fork_h)
  val () = cairo_set_source_surface(cr, sf_fork, ~fork_w / 2.0, 0.0)
  val () = cairo_paint_with_alpha(cr, 1.0)
  val () = cairo_restore(pf | cr)
in end

// assume scale is 1
fun draw_fork {l1,l2:agz} (
            cr: !cairo_ref (l1), 
            sf_fork: !cairo_surface_ref (l2),
            id: int,
            status: int
            ): void = let
  val (pf | ()) = cairo_save(cr)
  val () =  cairo_rotate(cr, 2.0 * id * PI / N + 2.0 * PI / N / 2.0)
in
  if 0 = status then let
    val () = cairo_translate(cr, 0.0, ~0.3)
    val () = draw_fork_prim (cr, sf_fork)
  in
    cairo_restore (pf | cr)
  end
  else if ~1 = status then let
    val () = cairo_rotate(cr, ~2.0 * PI / N / 3.0)
    val () = cairo_translate(cr, 0.0, ~0.2)
    val () = draw_fork_prim(cr, sf_fork)
  in
    cairo_restore (pf | cr)
  end
  else let
    val () = cairo_rotate(cr, 2.0 * PI / N / 3.0)
    val () = cairo_translate(cr, 0.0, ~0.2)
    val () = draw_fork_prim(cr, sf_fork)
  in
    cairo_restore (pf | cr)
  end
end

// assume scale is 1
// doesn't change context
implement draw_forks {l1,l2} (cr, sf_fork, n) = let
  val () = draw_fork (cr, sf_fork, n, fork_arr[n])
  val n = n + 1
in
  if N = n then ()
  else draw_forks (cr, sf_fork, n)
end



