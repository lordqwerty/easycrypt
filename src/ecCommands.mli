(* -------------------------------------------------------------------- *)
open EcSymbols

(* -------------------------------------------------------------------- *)
type info =
| GI_AddedType      of symbol
| GI_AddedAxiom     of symbol
| GI_AddedOperator  of symbol
| GI_AddedPredicate of symbol

(* -------------------------------------------------------------------- *)
val addidir    : string -> unit
val full_check : bool -> int -> unit

val process : EcParsetree.global -> info list

val undo    : int -> unit
val uuid    : unit -> int
