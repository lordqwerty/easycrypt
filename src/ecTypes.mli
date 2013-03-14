(* -------------------------------------------------------------------- *)
open EcDebug
open EcMaps
open EcUtils
open EcSymbols
open EcParsetree
open EcUidgen
open EcIdent

(* -------------------------------------------------------------------- *)
type ty = private {
  ty_node : ty_node;
  ty_tag  : int 
}

and ty_node =
  | Tunivar of EcUidgen.uid
  | Tvar    of EcIdent.t 
  | Ttuple  of ty list
  | Tconstr of EcPath.path * ty list
  | Tfun    of ty * ty

val ty_equal : ty -> ty -> bool
val ty_hash  : ty -> int 

val tuni   : EcUidgen.uid -> ty
val tvar   : EcIdent.t -> ty
val ttuple  : ty list -> ty
val tconstr : EcPath.path -> ty list -> ty
val tfun    : ty -> ty -> ty

type dom   = ty list
type tysig = dom * ty 

(* -------------------------------------------------------------------- *)
val tunit      : ty
val tbool      : ty
val tint       : ty
val treal      : ty
val tdistr     : ty -> ty
val toarrow    : dom -> ty -> ty

(* -------------------------------------------------------------------- *)
val ty_dump  : ty -> EcDebug.dnode
val dom_dump : dom -> EcDebug.dnode

(* -------------------------------------------------------------------- *)
module Tuni : sig
  val subst1    : (uid * ty) -> ty -> ty
  val subst     : ty Muid.t -> ty -> ty
  val subst_dom : ty Muid.t -> dom -> dom
  val occur     : uid -> ty -> bool
  val fv        : ty -> Suid.t
  val fv_sig    : tysig -> Suid.t
end

module Tvar : sig
  val subst1  : (EcIdent.t * ty) -> ty -> ty
  val subst   : ty Mid.t -> ty -> ty
  val init    : EcIdent.t list -> ty list -> ty Mid.t
  val fv      : ty -> Sid.t
  val fv_sig  : tysig -> Sid.t
end

(* -------------------------------------------------------------------- *)

(* [map f t] applies [f] on strict subterms of [t] (not recursive) *)
val map : (ty -> ty) -> ty -> ty

(* [sub_exists f t] true if one of the strict-subterm of [t] valid [f] *)
val sub_exists : (ty -> bool) -> ty -> bool

(* -------------------------------------------------------------------- *)
type lpattern =
  | LSymbol of EcIdent.t
  | LTuple  of EcIdent.t list

val lp_equal : lpattern -> lpattern -> bool
val lp_hash  : lpattern -> int 
val lp_ids   : lpattern -> EcIdent.t list
val lp_fv    : lpattern -> EcIdent.Sid.t

(* -------------------------------------------------------------------- *)
type pvar_kind =
  | PVglob
  | PVloc

type prog_var = {
  pv_name : EcPath.mpath;
  pv_kind : pvar_kind;
}

val pv_equal   : prog_var -> prog_var -> bool 
val pv_compare : prog_var -> prog_var -> int
val pv_hash    : prog_var -> int
val pv_fv      : prog_var -> int EcIdent.Mid.t
val is_loc     : prog_var -> bool

val string_of_pvar : prog_var -> string

module PVsubst : sig
  val subst_ids : EcIdent.t EcIdent.Mid.t -> prog_var -> prog_var
end

(* -------------------------------------------------------------------- *)
type tyexpr = private {
  tye_node : tyexpr_node;
  tye_type : ty;
  tye_fv   : int Mid.t;
  tye_tag  : int;
}

and tyexpr_node =
  | Eint      of int                         (* int. literal          *)
  | Elocal    of EcIdent.t                   (* let-variables         *)
  | Evar      of prog_var                    (* module variable       *)
  | Eop       of EcPath.path * ty list       (* op apply to type args *)
  | Eapp      of tyexpr * tyexpr list        (* op. application       *)
  | Elet      of lpattern * tyexpr * tyexpr  (* let binding           *)
  | Etuple    of tyexpr list                 (* tuple constructor     *)
  | Eif       of tyexpr * tyexpr * tyexpr    (* _ ? _ : _             *)

val type_of_exp : tyexpr -> ty
val expr_dump   : tyexpr -> dnode

(* -------------------------------------------------------------------- *)
val e_equal   : tyexpr -> tyexpr -> bool
val e_compare : tyexpr -> tyexpr -> int
val e_hash    : tyexpr -> int
val e_fv      : tyexpr -> int EcIdent.Mid.t

(* -------------------------------------------------------------------- *)
val e_int      : int -> tyexpr
val e_local    : EcIdent.t -> ty -> tyexpr
val e_var      : prog_var -> ty -> tyexpr
val e_op       : EcPath.path -> ty list -> ty -> tyexpr
val e_app      : tyexpr -> tyexpr list -> ty -> tyexpr
val e_let      : lpattern -> tyexpr -> tyexpr -> tyexpr
val e_tuple    : tyexpr list -> tyexpr
val e_if       : tyexpr -> tyexpr -> tyexpr -> tyexpr

(* -------------------------------------------------------------------- *)
val e_map :
     (ty     -> ty    ) (* 1-subtype op. *)
  -> (tyexpr -> tyexpr) (* 1-subexpr op. *)
  -> tyexpr
  -> tyexpr

val e_fold :
  ('state -> tyexpr -> 'state) -> 'state -> tyexpr -> 'state

(* -------------------------------------------------------------------- *)
module Esubst : sig
  val mapty : (ty -> ty) -> tyexpr -> tyexpr

  val uni : ty Muid.t -> tyexpr -> tyexpr 

  val subst_ids : EcIdent.t Mid.t -> tyexpr -> tyexpr
end

(* -------------------------------------------------------------------- *)
module Dump : sig
  val ty_dump : EcDebug.ppdebug -> ty -> unit
  val ex_dump : EcDebug.ppdebug -> tyexpr -> unit
end
