(** Create generators for sampling from specified distributions. *)

(** [normal ?seed mean std ()] creates a generator that will return variables
    from the Normal distribution of [mean] and [std] (standard deviation).*)
val normal : ?seed:int array -> mean:float -> std:float -> unit -> (unit ->
  float)

(** [normal_std seed ()] is equivalent to [normal seed ~mean:0.0 ~std:1.0 ()].*)
val normal_std : ?seed:int array -> unit -> (unit -> float)

(** [uniform ?seed n] creates a generator that will return an integer
    representating the ith element of [n] possible elements from
    the uniformly random distribution.

    @raise Invalid_argument if [n] is zero or negative. *)
val uniform : ?seed:int array -> int -> (unit -> int)

(** [multinomial ?seed weights] creates a generator that will return an integer
    representating the ith element from the Multinomial distribution given by
    a [weights] vector which sums to [1].

    @raise Invalid_argument if [weights] do not sum to [1.0] *)
val multinomial : ?seed:int array -> float array -> (unit -> int)

(** [softmax ?seed ?temp weights] creates a generator that will return an integer
    representating the ith element from the softmax distribution given by
    a [weights] vector and [temp]erature parameter which defaults to [1.0].

    @raise Invalid_argument if [weights] is empty *)
val softmax : ?seed:int array -> ?temp:float -> float array -> (unit -> int)
