(*
   Copyright 2015,2016:
     Leonid Rozenberg <leonidr@gmail.com>

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

include Array
open Oml_util_base
let invalid_arg ~f fmt = invalid_arg ~m:"Array" ~f fmt

let fold2 f i a b =
  let n = Array.length a
  and m = Array.length b in
  if n <> m then
    invalid_arg ~f:"fold2" "unequal lengths %d and %d" n m
  else
    begin
      let r = ref i in
      for i = 0 to n - 1 do
        r := f !r a.(i) b.(i)
      done;
      !r
    end

let map2 f a b =
  let n = Array.length a
  and m = Array.length b in
  if n <> m then
    invalid_arg ~f:"map2" "unequal lengths %d and %d" n m
  else
    Array.mapi (fun i a_i -> f a_i b.(i)) a

let sumf a = Oml_kahan.sum (Array.fold_left Oml_kahan.update Oml_kahan.empty a)
  (* Old, unrolled version:
  let c = ref 0. in
  let s = ref 0. in
  for i = 0 to Array.length a - 1 do
    let x = a.(i) -. !c in
    let ns = !s +. x in
    c := (ns -. !s) -. x;
    s := ns;
  done;
  !s *)

(* TODO: Are there heuristics to consider when arrays are large? or elements
  in the array are particulary large/small,
  specifically. when to log transforms?
  Furthermore, if I'm not going to use this method for geometric_mean,
  when should I use this default version?  *)
let prodf = Array.fold_left ( *. ) 1.0

let max a = Array.fold_left max a.(0) a
let min a = Array.fold_left min a.(0) a

let find_index ?(start=0) f a =
  let n = Array.length a in
  let rec loop i =
    if i >= n then
      raise Not_found
    else if f a.(i) then
      i
    else
      loop (i + 1)
  in
  loop start

let bs precise c a =
  let rec bs_loop mi mx =
    if mx < mi then
      if precise then
        raise Not_found
      else
        mx
    else
      let md = (mx + mi) / 2 in
      let cc = c a.(md) in
      if cc < 0
      then bs_loop mi (md - 1)
      else if cc > 0
          then bs_loop (md + 1) mx
          else md
  in
  bs_loop 0 (Array.length a - 1)

let binary_search c arr = bs false c arr
let binary_search_exn c arr = bs true c arr

let all p a =
  let n = Array.length a in
  let rec loop i =
    i = n || (p a.(i)) && loop (i + 1)
  in
  loop 0

let any p a =
  let n = Array.length a in
  let rec loop i =
    if i < n
    then (p a.(i)) || loop (i + 1)
    else false
  in
  loop 0

let has_order c a =
  let n = Array.length a in
  let rec loop i =
    i = n || (c a.(i -1) a.(i) && loop (i + 1))
  in
  loop 1

let range ?(incr=1.0) ~start ~stop () =
  if stop < start
  then [||]
  else
    Array.init (truncate (ceil ((stop -. start) /. incr)))
      (fun i -> start +. incr *. (float i))

let ranks = Oml_rank.ranks

let zip x y =
  let n = Array.length x in
  let m = Array.length y in
  if m <> n then invalid_arg ~f:"zip" "array lengths not equal %d %d" n m
  else Array.mapi (fun i x -> x, y.(i)) x

let unzip arr = Array.map fst arr, Array.map snd arr

let permute ?seed ?(copy=true) arr =
  random_init seed;
  let a = if copy then Array.copy arr else arr in
  for n = Array.length a - 1 downto 1 do
    let k = Random.int (n + 1) in
    let temp = a.(n) in
    a.(n) <- a.(k);
    a.(k) <- temp
  done;
  a
