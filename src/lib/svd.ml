
open Lacaml.D

type t = { u : mat
         ; s : vec
         ; vt : mat
         }

let u t = Mat.to_array t.u
let s t = Vec.to_array t.s
let vt t = Mat.to_array t.vt

(* Destroys [mat] !!!!! *)
let svd mat =
  (* `S returns just the desired components, to avoid further copying. *)
  let s, u, vt = gesvd ~jobu:`S ~jobvt:`S mat in
  { u; s; vt }

let s_inv t = function
  | None   -> Vec.map (function 0.0 -> 0.0 | x -> 1.0 /. x) t.s
  | Some l -> Vec.map (function 0.0 -> 0.0 | x -> x /. (x *. x +. l)) t.s

(* TODO: expose the dimensionality reduction. *)
let solve_linear ?lambda t b =
  let s_inv = s_inv t lambda in
  let s_mat = Mat.of_diag s_inv in
  gemv ~trans:`T t.u b
  |> gemv s_mat
  |> gemv ~trans:`T t.vt

let covariance_matrix ?lambda t =
  let s_inv = s_inv t lambda in
  gemm (Mat.of_diag (Vec.sqr s_inv)) t.vt
  |> gemm ~transa:`T t.vt

(* From "Notes on Regularized Least Squares"
   by Ryan M. Rifkin and Ross A. Lippert
   http://cbcl.mit.edu/projects/cbcl/publications/ps/MIT-CSAIL-TR-2007-025.pdf
*)
let looe svd y =
  fun l ->
    let d = Mat.of_diag (Vec.map (fun s -> 1./.(s*.s +. l) -. 1./.l) svd.s) in
    let a = gemm svd.u (gemm d ~transb:`T svd.u) in
    let num = Vec.add (gemv a y) (Vec.map (fun y -> y /. l) y) in
    let den = Vec.add (Mat.copy_diag a) (Vec.make (Mat.dim1 svd.u) (1./.l)) in
    Vec.div num den
