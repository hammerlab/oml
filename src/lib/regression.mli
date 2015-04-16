
(** A fit linear model. *)
type linear_model =
  { m_pred                : float         (** Mean of predictor variable. *)
  ; m_resp                : float         (** Mean of response variable. *)
  ; size                  : float         (** Number of observations. *)
  ; alpha                 : float         (** Constant term of model. *)
  ; beta                  : float         (** Linear multiplicative term. *)
  ; correlation           : float         (** Pearson correlation of response
                                              to predictor.*)
  ; chi_square            : float         (** Chi^2 of the residuals. *)
  ; inferred_response_var : float         (** *)
  ; goodness_of_fit       : float option  (** *)
  ; s_xx                  : float         (** Sum of squared difference to
                                              [m_pred] useful by interval. *)
  }

(** [to_string lrm] returns a string representing the inferred linear model. *)
val to_string : linear_model -> string

(** [eval_lrm linear_model x] evaluate a the [linear_model] at [x]. *)
val eval_lrm : linear_model -> float -> float

(** [linear_regress ?pred_variance resp pred] create a linear model that
    estimates [resp = alpha + beta * pred].

    [pred_variance] represents the assumed variance in the [pred] elements and
    defaults to 1 for all elements. *)
val linear_regress : ?pred_variance:float array -> resp:float array ->
                      pred:float array -> unit -> linear_model

(** [confidence_interval linear_model alpha_level x], given [linear_model]
    compute the alpha (ex 0.95) confidence interval around [x]. *)
val confidence_interval : linear_model -> alpha_level:float -> float -> float * float

(** [prediction_interval linear_model alpha_level x], given [linear_model]
    compute the alpha (ex 0.95) prediction interval around [x]. *)
val prediction_interval : linear_model -> alpha_level:float -> float -> float * float

type general_linear_model =
  { g_m_pred                : float array   (** Means of the predicted variables. *)
  ; g_m_resp                : float         (** Mean of the response variable. *)
  ; deg_of_freedom          : float         (** Degree's of freedom in the regression. *)
  ; coefficients            : float array   (** The coefficients of the determined model. *)
  ; correlations            : float array   (** TODO. Document *)
  ; chi_square              : float
  ; g_inferred_response_var : float
  ; sum_squares             : float
  ; cod                     : float         (** coefficient of determination. r^2 *)
  ; adj_cod                 : float         (** adjusted coefficient of determination. r^2 *)
  ; covariance              : float array array (* Covariance matrix. *)
  ; residuals               : float array
  ; aic                     : float
  }

val sub_general_linear_regress : resp: float array -> pred: float array array
                                -> unit -> general_linear_model
