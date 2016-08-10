
type t = private float

val restrict : float -> t

val check : float -> t option

type s = private float array

(* Constructors *)
val normalize : float array -> s
 
val softmax : ?temperature:float -> float array -> s

(* Getters. *)
val length : s -> int

val get : s -> int -> float

