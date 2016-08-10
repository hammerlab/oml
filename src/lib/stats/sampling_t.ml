(*
   Copyright 2015,2016:
     Leonid Rozenberg <leonidr@gmail.com>
     Carmelo Piccione <carmelo.piccione@gmail.com>

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*)

(* The spirit of these tests isn't to find out if the underlying [Random]
   module generates very good Random numbers (at-the-moment). Rather we
   want our distributions to be well behaved. *)

open Test_utils
open Util
open Statistics.Sampling

let () =
  let add_partial_random_test
    ?title ?nb_runs ?nb_tries ?classifier
    ?reducer ?reduce_depth ?reduce_smaller ?random_src gen f spec =
    Test.add_partial_random_test_group "Sampling"
      ?title ?nb_runs ?nb_tries ?classifier
      ?reducer ?reduce_depth ?reduce_smaller ?random_src gen f spec
  in
  let msas = 100 in   (* max seed array size *)
  let seed = Gen.(array (make_int 1 msas) int |> option bool) in
  let samples = 1000 in
  let test f =
    let rec loop p = p = samples || f () && loop (p + 1) in
    loop 0
  in
  let bound f = Spec.(zip2 always f) in
  add_partial_random_test
    ~title:"Uniform int obeys bounds."
    Gen.(zip2 seed int)
    (fun (seed, b) ->
      let int_maker = uniform_i ?seed b in
      test (fun () -> let i = int_maker () in 0 <= i && i < b))
    Spec.([ bound (fun x -> 0 <= x && x < int_upper_bound) ==> is_result is_true
          ; bound (fun x -> x >= int_upper_bound) ==> is_exception is_invalid_arg
          ; bound is_neg_int  ==> is_exception is_invalid_arg
          ; bound is_zero_int ==> is_exception is_invalid_arg
          ]);

  add_partial_random_test
    ~title:"Uniform float obeys bounds."
    Gen.(zip2 seed (bfloat 1e8))
    (fun (seed, b) ->
      let float_maker = uniform_f ?seed b in
      test (fun () -> let f = float_maker () in 0.0 <= f && f <= b))
    Spec.([ bound is_pos_float  ==> is_result is_true
          ; bound is_neg_float  ==> is_exception is_invalid_arg
          ; bound is_zero_float ==> is_exception is_invalid_arg
          ]);

  let mean_g = Gen.make_float (-10.0) 10.0 in
  add_partial_random_test
    ~title:"Normal obeys bounds."
    Gen.(zip2 seed (zip2 mean_g (make_float (-1.0) 1.0)))
    (fun (seed, (mean, std)) ->
      let _ = normal ?seed ~mean ~std () in
      true)
    Spec.([ zip2 always (zip2 always (fun x -> x < 0.0)) ==> is_exception is_invalid_arg
          ; zip2 always (zip2 always (fun x -> x >= 0.0)) ==> is_result is_true]);

  add_partial_random_test
    ~title:"Normal zero std gives you back the mean."
    Gen.(zip2 seed mean_g)
    (fun (seed, mean) ->
      let gauss = normal ?seed ~mean ~std:0.0 () in
      Array.init samples (fun _ -> gauss()) |> Array.all (fun x -> x = mean))
    Spec.([ zip2 always always ==> is_result is_true]);

  let samples_f = float samples in
  let std_g     = Gen.make_float (0.0 +. dx) 10.0 in
  add_partial_random_test
    ~title:"Normal obeys Chebyshev."
    (* This forms such a wide bound that k closer to 1.0 are the worthwhile cases. *)
    Gen.(zip3 seed (zip2 mean_g std_g) (make_float 1.0 2.0))
    (fun (seed, (mean, std), k) ->
      let bound = k *. std in
      let gauss = normal ?seed ~mean ~std () in
      let outside =
        Array.init samples (fun _ -> gauss ())
        |> Array.fold_left (fun c x ->
              if abs_float (x -. mean) >= bound then c +. 1.0 else c)
            0.0
      in
      (*let _ = Printf.printf "got %0.3f %0.3f samples outside \n" outside bound in *)
      outside /. samples_f <= 1.0 /. (k *. k))
    Spec.([ zip3 always always always ==> is_result is_true ]);

  let any_weights = Gen.(array (make_int 0 10) (make_float 0.0 1.0)) in (* 10 *)
  (* Since [Functions.softmax] does the checking on [temperature] this is mostly a shell. *)
  add_partial_random_test
    ~title:"Softmax obeys bounds."
    Gen.(zip2 seed any_weights)
    (fun (seed, weights) ->
      let mm = softmax ?seed weights in
      let _  = Array.init samples (fun _ -> mm ()) in
      true)
    Spec.([ (fun (_,arr) -> arr <> [||]) ==> is_result is_true
          ; (fun (_,arr) -> arr =  [||]) ==> is_exception is_invalid_arg
          ]);

  ()

