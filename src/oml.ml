module Util = Oml_util

module Uncategorized = Oml_lite_uncategorized

module Statistics = struct
  module Continued_fraction = Oml_continued_fraction
  module Functions = Oml_lite_functions
  module Sampling = Oml_sampling
  module Descriptive = Oml_descriptive
  module Measures = Oml_measures
end

module Online = Oml_online

module Classification = struct
  module Intf = Oml_cls_intf
  module Probabilities = Oml_probabilities
  module Naive_bayes = Oml_lite_naive_bayes
  module Performance = Oml_performance
end

module Regression = struct
  module Intf = Oml_lite_intf
  module Univariate = Oml_lite_univariate
  module Interpolate = Oml_interpolate
end
