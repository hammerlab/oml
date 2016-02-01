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
(*open Intf *)

(** Train a
  {{:https://en.wikipedia.org/wiki/Naive_Bayes_classifier}Naive Bayes}
  classifier on data encoded using
  {{!modtype:Intf.Dummy_encoded_data}Dummy variables.} *)
module Binomial(D: Intf.Dummy_encoded_data) : sig
  include Intf.Generative with type feature = D.feature
                     and type clas = D.clas

  (** [opt ~smoothing ~bernoulli ()] the optional configuration of the
       classifier.

      @param bernouli if true we treat the underlying distribution as Bernoulli
                      (as opposed to Multinomial) and estimate the likelihood
                      with (1-p_i) for features [i] that are missing from a
                      feature when {{!val:eval}evaluated}.
      @param smoothing
        {{:http://en.wikipedia.org/wiki/Additive_smoothing}Additive smoothing}
        can be applied to the final estimate of Naive Bayes classifiers.
        When estimating a probability distribution by counting observed instances
        in the feature space we may want to smooth the values, particularly if our
        training data is sparse. *)
  val opt : ?smoothing:float -> ?bernoulli:bool -> unit -> opt

end

(** Train a
  {{:https://en.wikipedia.org/wiki/Naive_Bayes_classifier}Naive Bayes}
  classifier on data encoded using
  {{!modtype:Intf.Category_encoded_data}Categorical variables.} *)
module Categorical(D: Intf.Category_encoded_data) : sig
  include Intf.Generative with type feature = D.feature
                     and type clas = D.clas

  (** [opt ~smoothing ()] the optional configuration of the classifier.

      @param smoothing
        {{:http://en.wikipedia.org/wiki/Additive_smoothing}Additive smoothing}
        can be applied to the final estimate of Naive Bayes classifiers.
        When estimating a probability distribution by counting observed instances
        in the feature space we may want to smooth the values, particularly if our
        training data is sparse. *)
  val opt : ?smoothing:float -> unit -> opt

end

(** Train a
  {{:https://en.wikipedia.org/wiki/Naive_Bayes_classifier#Gaussian_naive_Bayes}
  Gaussian Naive Bayes} by estimating mean and standard deviations
  for each of the quantitative features in the
  {{!modtype:Intf.Continuous_encoded_data}encoded data}. *)
module Gaussian(D: Intf.Continuous_encoded_data) :
  Intf.Generative with type feature = D.feature
                  and type clas = D.clas

