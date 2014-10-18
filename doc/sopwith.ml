module C = Chipmunk
module CO = Chipmunk.OO
module CL = Chipmunk.Low_level
open Physics

open V.VecOps

let pi = 4.0 *. atan 1.0

let negate = Gg.V2.neg

let draw_cp_polygon = false
let draw_force_vectors = false
let plane_mass = 500.0
let yaw_speed = 0.005			(* relative to forward speed *)
let accel_speed = 1000.0
let decel_speed = 2000.0
let initial_motor_speed = 0.0
let initial_speed = 0.0
let max_motor_speed = 4000.0
let fwd_frict_coeff = 0.2
let nor_frict_coeff = 2.0
let tail_frict_coeff = 0.5
let head_area = 1.0
let plane_area = 10.0
let tail_area = 0.2
let turn_speed = 0.2
let wing_lift = 0.1

(*
let initial_motor_speed = 0.0
let frict_coeff = 0.0
let head_area = 0.0
let tail_area = 0.0
*)

type yaw =
  | YawRight
  | YawRightToOther
  | YawOtherToRight
  | YawOther

let angle_of_yaw v = 180.0 *. (1.0 -. (cos (v *. pi) /. 2.0 +. 0.5))

let sign = function
  | x when x >= 0.0 -> 1.0
  | _ -> -1.0

let polygon = [(-25.0, 5.0); (13.0,5.0); (13.0, -2.0); (8.0, -6.0); (2.0, -4.0);]

class plane (space : CO.cp_space) (at0 : Gg.V2.t) =
  (*   let schema = Ase.normalize_model (List.concat (Ase.load "foo.ase")) in *)
  let schema = (* Ase.normalize_model *) (List.concat (List.map snd (Ase.flip_on (fun (name, _) -> try ignore (Pcre.exec ~pat:"flip" name); true with Not_found -> false) (Ase.load "sopwith.ase")))) in
    (*   let schema = (* Ase.normalize_model *) (List.concat (Ase.load "sphere.ase")) in *)
    (*    let schema = (* Ase.normalize_model *) (List.concat (Ase.load "cube.ase")) in *)
  let body = 
    new CO.cp_body plane_mass
      (CO.moment_for_poly plane_mass
	 (Array.of_list (List.map cpvt polygon))
	 (cpvt (5.0, 3.0))) in
  let shapes = ref [] in
  let add_shape shape =
    space#add_shape shape;
    shape#set_friction 0.0;
    shapes := shape::!shapes 
  in
  (*let motor_sound = MotorSound.create () in*)
  let add_shapes flipped =
    let mapv (x, y) =
      if flipped then cpvt (x, -.y)
      else cpvt (x, y)
    in
    let optrev xs =
      if flipped then List.rev xs
      else xs
    in
    let optrev_array xs =
      if flipped then Array.of_list (List.rev (Array.to_list xs))
      else xs
    in
    let listmap f xs = optrev (List.map f xs) in
      List.iter (fun shape -> space#remove_shape shape) !shapes;
      List.iter (fun v -> v#free) !shapes;
      shapes := [];
      List.iter add_shape
	[new CO.cp_shape body (CO.POLY_SHAPE ((Array.of_list (listmap mapv polygon)), mapv (0.0, 0.0)));
	 new CO.cp_shape body (CO.CIRCLE_SHAPE (4.0, mapv (-25.0, 0.0)));
	 new CO.cp_shape body (CO.POLY_SHAPE (optrev_array [|mapv (-25.0, 5.0); mapv (-10.0, 5.0);
						             mapv (-25.0, -3.0)|], mapv (0.0, 0.0)));
	 new CO.cp_shape body (CO.CIRCLE_SHAPE (4.0, mapv (8.0, -3.0)))]
  in
object (self)
  val mutable accelerating = false
  val mutable decelerating = false
  val mutable turning_cw = false
  val mutable turning_ccw = false
  val mutable yawing = YawRight
  val mutable yaw = 0.0
  val mutable motor_speed = initial_motor_speed
  val mutable forces = []

  method where = uncpv body#get_pos

  method angle = body#get_angle

  method private reset_forces =
    body#reset_forces;
    forces <- []

  method private add_force label force at =
    body#apply_force (cpv force) (cpv at);
    forces <- (label, force, at)::forces;

  method step (message : string -> unit) (delta : float) = 
    (* Speed of the plane *)
    let vel = uncpv body#get_vel in
    let abs_vel = V.abs2 vel in

    let base = V.base (V.vec_of_ang (~-.(body#get_angle))) in

    let to_base v = V.mul2 v base in

    let fwd = V.vec_of_ang body#get_angle in
    let normal = V.vec_of_ang (body#get_angle +. pi /. 2.0) in

    (* What is the tail speed towards the normal of the plane speed vector *)
    let tail_speed = body#get_a_vel *. pi *. 2.0 *. 20.0 in
    let tail_vel = to_base (Gg.V2.v tail_speed 0.0) in
    let abs_tail_vel = vel +.| tail_vel in
      
    (* How much is the speed towards plane head. can be negative. *)
    let fwd_vel = Gg.V2.dot vel fwd in
    let normal_vel = Gg.V2.dot vel normal in

    let head_angle = body#get_angle in

    let rel_force label force at = self#add_force label (to_base force) (to_base at) in

    let speed_angle =
      let (vel_x, vel_y) = uncpvt body#get_vel in
        if abs_vel < 1.0 then
          head_angle
        else
          atan2 vel_y vel_x
    in

    let air_wing_angle =
      let v = head_angle -. speed_angle in
        if v > pi then
          v -. 2.0 *. pi
        else
          v
    in

    let lift_coeff = Lift.lift air_wing_angle in

      (*Printf.printf "air wing angle: %f %f %f -> %f\n%!"
        air_wing_angle
        (fst (uncpv body#get_vel))
        (snd (uncpv body#get_vel))
        lift_coeff;

        Printf.printf "body angle: %f\n%!" body#get_angle;*)

      self#reset_forces;

      (* If accelerating, increase motor speed *)
      if accelerating then motor_speed <- min max_motor_speed (motor_speed +. delta *. accel_speed);

      if decelerating then motor_speed <- max 0.0 (motor_speed -. delta *. decel_speed);

      (*MotorSound.set_freq motor_sound motor_speed;*)

      (* Motor speed applies forward force *)
      self#add_force "motor" ((V.v2 (motor_speed *. 10.0) *.| V.vec_of_ang body#get_angle)) Gg.V2.zero;

      (* Air friction (and drag?) opposes movement towards plane velocity *)
      (* self#add_force "fwddrag" *)
      (*   (Gg.V2.smul (fwd_frict_coeff *. fwd_vel ** 2.0 *. head_area) (V.unit (negate vel))) *)
      (*   (to_base (Gg.V2.v 0.0 0.0)); *)

      (* Air friction (and drag?) opposes movement towards plane velocity normal also *)
      self#add_force "hddrag"
        (Gg.V2.smul (nor_frict_coeff *. normal_vel ** 2.0 *. plane_area *. sign normal_vel) (negate (V.unit normal)))
        (to_base (Gg.V2.v ~-.1.0 0.0));

      (* self#add_force "tldrag" *)
      (*   (Gg.V2.smul (nor_frict_coeff *. tail_speed ** 2.0 *. tail_area *. sign tail_speed) (negate (V.unit normal))) *)
      (*   (to_base (-20.0, 0.0)); *)

      (* Upward lift *)
      (* self#add_force (Gg.V2.smul (0.01 *. fwd_vel ** 2.0) (V.vec_of_ang (body#get_angle +. pi /. 2.0))) (0.0, 0.0); *)
      self#add_force "lift" (Gg.V2.smul (wing_lift *. fwd_vel ** 2.0 *. lift_coeff) (V.vec_of_ang (body#get_angle +. pi /. 2.0))) Gg.V2.zero;

      (* (\* When turning cw, apply opposing (ccw) force to the tail *\) *)
      if turning_cw then
        rel_force "cw" (Gg.V2.smul (turn_speed *. fwd_vel ** 2.0 *. sign fwd_vel) (Gg.V2.v 0.0 1.0)) (Gg.V2.v ~-.20.0 0.0);

      (* (\* When turning ccw, apply opposing (cw) force to the tail *\) *)
      if turning_ccw then
        rel_force "ccw" (Gg.V2.smul (turn_speed *. fwd_vel ** 2.0 *. sign fwd_vel) (Gg.V2.v 0.0 ~-.1.0)) (Gg.V2.v ~-.20.0 0.0);

      (* (\* Such force (rotation) will also be opposed by air friction *\) *)
      rel_force "tf"
        (Gg.V2.v 0.0 (tail_frict_coeff *. tail_speed ** 2.0 *. sign tail_speed))
        (Gg.V2.v ~-.20.0 0.0);

      (* Printf.printf "%f %f\n%!" fwd_vel tail_speed; *)
      (match yawing with
         | YawRight | YawOther -> ()
         | YawRightToOther ->
             yaw <- min 1.0 (yaw +. yaw_speed *. delta *. abs_float fwd_vel);
             if yaw >= 1.0 then
               (yawing <- YawOther;
        	add_shapes true;
               )
         | YawOtherToRight ->
             yaw <- min 2.0 (yaw +. yaw_speed *. delta *. abs_float fwd_vel);
             if yaw >= 2.0 then
               (yawing <- YawRight;
        	yaw <- 0.0;
        	add_shapes false)
      );

      let printf fmt = Printf.ksprintf message fmt in
	printf "Location: %f, %f" (Gg.V2.x self#where) (Gg.V2.y self#where);
	printf "Motor speed: %f" motor_speed;
	printf "Velocity: %f" abs_vel;

  method begin_accel = accelerating <- true
  method end_accel = accelerating <- false
    
  method begin_decel = decelerating <- true
  method end_decel = decelerating <- false
    
  method begin_turn_cw = turning_cw <- true
  method end_turn_cw = turning_cw <- false
    
  method begin_turn_ccw = turning_ccw <- true
  method end_turn_ccw = turning_ccw <- false
    
  method begin_yaw_cw = ()
  method end_yaw_cw = ()
    
  method begin_yaw_ccw = ()
  method end_yaw_ccw = ()

  method swap_yaw = 
    match yawing with
      | YawRightToOther | YawOtherToRight -> ()
      | YawRight -> yawing <- YawRightToOther
      | YawOther -> yawing <- YawOtherToRight

  method render (surface : Sdlvideo.surface) = 
    let at = self#where in
    let angle = self#angle in
    let vel = uncpv body#get_vel in
    let abs_vel = V.abs2 vel in
      Render.render at 15.0 (angle_of_yaw yaw, 0.0, angle /. pi *. 180.0) schema;
      GlMat.mode `modelview;

      Gl.disable `lighting;
      Gl.disable `depth_test;
      GlDraw.color (1.0, 1.0, 1.0);

      if draw_cp_polygon then
	(GlDraw.begins `polygon;
	 List.iter (fun v -> GlDraw.vertex2 (Gg.V2.to_tuple (self#where +.| (V.mul2 (Gg.V2.of_tuple v) (V.base (V.vec_of_ang (~-.(body#get_angle)))))))) polygon;
	 GlDraw.ends ());

      if draw_force_vectors then
	List.iter 
	  (fun (label, dir, at) ->
	     let at = self#where +.| at in
	     let dir = dir /.| V.v2 50.0 in
	       Render.vector ~label:(fun () -> (Lazy.force Display.font_render_annot) label) 
                             (Gg.V3.v (Gg.V2.x at) (Gg.V2.y at) 0.0)
                             (Gg.V3.v (Gg.V2.x dir) (Gg.V2.y dir) 0.0)
	  )
	  forces;

      Gl.enable `lighting;
      Gl.enable `depth_test;

  method reset () =
    body#set_a_vel 0.0;
    body#set_angle 0.0;
    body#set_pos (cpv at0);
    body#set_vel (cpvt (initial_speed, 0.0));

  initializer
    self#reset ();
    add_shapes false;
    space#add_body body;
    (*MotorSound.start motor_sound;*)
end
