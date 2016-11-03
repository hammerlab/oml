(*
   Copyright 2015:
     Carmelo Piccione <carmelo.piccione@gmail.com>
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


(** Provides various measurement functions from statistics and analysis *)


val normal_kl_divergence : ?d:float -> p_mean:float -> p_sigma:float ->
      q_mean:float -> q_sigma:float -> unit -> float
(** Computes kl divergence of the normal distributions P and Q defined
    given means [p_mean] and [q_mean] and std deviations [p_sigma]
    and [q_sigma]. Returns infinity for variances near zero.

    @param d float can be used to tune the sensitivity of the checks for
    zero.
    *)

val discrete_kl_divergence : ?d:float -> p:('a * float) list ->
      q:('a * float) list -> unit ->  float
(** [discrete_kl_divergence ~p:p_pdf ~q:q_pdf] Compute the KL divergence from
    [p_pdf] to [q_pdf]. [p_pdf] and [q_pdf] represent discrete probability
    distributions. Please note that this metric is not symmetric and the result
    does {b not} equal [discrete_kl_divergence ~p:q_pdf ~q:p_pdf].

    @param d float can be used to tune the sensitivity of checks that the
      probabilities sum to 1.
    @raise Invalid_argument if [p_pdf] or [q_pdf] have duplicate events,
      the probabilities are outside the bounds, or they not sum to 1.
    *)
