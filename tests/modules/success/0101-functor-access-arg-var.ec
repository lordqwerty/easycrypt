type t.

module type I = {
  var x : t
}.

module M(X : I) = {
  var y : t

  fun init() : unit = {
    y = X.x;
  }
}.
