(** OCaml Math, Statistics and ML Libary.

    Oml {i plus} [C] and [Fortran] bindings where appropriate.*)

(** Common values used throughout the library. *)
module Util : sig
  include module type of Oml.Util
end

(** WIP: Special functions and Linear Algebra. *)
module Uncategorized : sig
  include module type of Omlf_uncategorized
end

(** Inference, parameter estimation.*)
module Statistics : sig

  module Continued_fraction : sig
    include module type of Oml.Statistics.Continued_fraction
  end
  module Functions : sig
    include module type of Omlf_functions
  end
  module Sampling : sig
    include module type of Oml.Statistics.Sampling
  end
  module Descriptive : sig
    include module type of Oml.Statistics.Descriptive
  end
  module Measures : sig
    include module type of Oml.Statistics.Measures
  end

  module Distributions : sig include module type of Omlf_distributions end
  module Hypothesis_test : sig include module type of Omlf_hypothesis_test end
end

(** Compute running statitics using recurrence equations. *)
module Online : sig
  include module type of Oml.Online
        with type t = Oml.Online.t
end

(** Classify data based on features. *)
module Classification : sig
  module Intf : sig
    include module type of Oml.Classification.Intf
  end
  module Probabilities : sig
    include module type of Oml.Classification.Probabilities
  end
  module Naive_bayes : sig
    include module type of Omlf_naive_bayes
  end
  module Logistic_regression : sig
    include module type of Omlf_logistic_regression
  end
  module Descriminant : sig
    include module type of Omlf_descriminant
  end
  module Performance : sig
    include module type of Oml.Classification.Performance
  end
end

(** Model relationship between variables. *)
module Regression : sig
  module Intf : sig
    include module type of Omlf_intf
  end

  module Univariate : sig
    include module type of Omlf_univariate
  end
  module Multivariate : sig
    include module type of Omlf_multivariate
  end
  module Tikhonov : sig
    include module type of Omlf_tikhonov
  end
  module Interpolate : sig
    include module type of  Oml.Regression.Interpolate
  end
end

(** Unsupervised learning. *)
module Unsupervised : sig
  module Pca : sig
    include module type of Omlf_pca
  end
end
