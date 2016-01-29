(*
   Copyright 2015:
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

(** Construct linear models that describe (and learn from) data.*)

(** The interface of the model constructed by a Regression procedure. *)
module type Linear_model_intf = sig
  include Util.Optional_arg_intf

  type input
  type t

  (** [describe t] returns a string describing the regressed linear model.*)
  val describe : t -> string

  (** [eval linear_model x] Evaluate a the [linear_model] at [x].*)
  val eval : t -> input -> float

  (** [regress options pred resp] computes a linear model of [resp] based
      off of the independent variables in the design matrix [pred], taking
      into account the various method [opt]s. *)
  val regress : ?opt:opt -> input array -> resp:float array -> t

  (** [residuals t] returns the residuals, the difference between the observed
      value and the estimated value for the independent, response, values. *)
  val residuals : t -> float array

  (** [coefficients t] returns the coefficients used in the linear model. *)
  val coefficients : t -> float array

  (** [residual_standard_error linear_model] returns an estimate, based on the
      residuals, of the variance of the error term in the linear model.*)
  val residual_standard_error : t -> float

  (** [coeff_of_determination linear_model] returns the R^2 statistic for the
      linear model. *)
  val coeff_of_determination : t -> float

  (** [confidence_interval linear_model alpha x] Use the [linear_model] to
      construct confidence intervals at [x] at an [alpha]-level of significance.
  *)
  val confidence_interval : t -> alpha:float -> input -> float * float

  (** [prediction_interval linear_model alpha x] Use the [linear_model] to
      construct prediction intervals at [x] at an [alpha]-level of significance.
  *)
  val prediction_interval : t -> alpha:float -> input -> float * float

  (** [coefficient_tests linear_model] perform hypothesis tests on the
      models coefficients to see if they are significantly different from
      the null. *)
  val coefficient_tests : ?null:float -> t -> Inference.test array

  (** [F_test linear_model] compute the F-statistic to assess if there is any
      relationship between the response and predictors in the [linear_model].*)
  val f_statistic : t -> float (*Inference.test*)

end

(** Simple one dimensional regression. *)
module Univariate : sig

  (** The optional [opt] for univariate regression are weights for each
      observation. One can use them to change the model such that each
      error (e_i) is now sampled from it's own distribution: [N(0, s/w_i)],
      where s^2 is the error variance and w_i is the weight of the ith
      error. *)
  type opt = float array

  val opt : ?weights:float array -> unit -> opt

  include Linear_model_intf
    with type input = float
    and type opt := opt

  (** [alpha t] a shorthand for the constant parameter used in the regression.
      Equivalent to [(coefficients t).(0)] *)
  val alpha : t -> float

  (** [beta t] a shorthand for the linear parameter used in the regression.
      Equivalent to [(coefficients t).(1)] *)
  val beta : t -> float

  (** [alpha_test ~null linear_model] perform a hypothesis test on the [alpha]
      coefficient of the [linear_model]. *)
  val alpha_test : ?null:float -> t -> Inference.test

  (** [beta_test ~null linear_model] perform a hypothesis test on the [beta]
      coefficient of the [linear_model]. *)
  val beta_test : ?null:float -> t -> Inference.test

end

(** Multi-dimensional input regression, with support for Ridge regression. *)
module Multivariate : sig

  type opt =
    { add_constant_column : bool          (** Instructs the method to efficiently insert a colum of 1's into the
                                            design matrix for the constant term. *)
    ; l2_regularizer : [`S of float | `From of float array] option    (** How to optionally determine the ridge parameter. *)
    }

  val opt : ?l2_regularizer:[`S of float | `From of float array] ->
            ?add_constant_column:bool ->
            unit ->
            opt

  include Linear_model_intf
    with type input = float array
    and type opt := opt

  (** [aic linear_model] return the Akaike information criterion for the
      [linear_model].*)
  val aic : t -> float

  (** [press linear_model] return the Predicted REsidual Sum of Squares for the
      [linear_model]. *)
  val press : t -> float

end

(** Multi-dimensional input regression with a matrix regularizer.
  described {{:https://en.wikipedia.org/wiki/Tikhonov_regularization} here}.

  Please take care with using this method as not all of the algorithms have
  been verified. A warning is printed to standard-error. *)
module Tikhonov : sig

  type opt =
    { tik_matrix : float array array   (** The regularizing matrix. *)
    ; l2_regularizer : [`S of float | `From of float array] option  (** How to optionally determine the ridge parameter. *)
    }

  val opt : ?tik_matrix:float array array ->
            ?l2_regularizer:[`S of float | `From of float array] ->
            unit ->
            opt

  include Linear_model_intf
    with type input = float array
    and type opt := opt

  (** [aic linear_model] return the Akaike information criterion for the
      [linear_model].*)
  val aic : t -> float

  (** [press linear_model] return the Predicted REsidual Sum of Squares for the
      [linear_model]. *)
  val press : t -> float

end
