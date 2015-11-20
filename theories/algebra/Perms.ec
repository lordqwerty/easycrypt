(* --------------------------------------------------------------------
 * Copyright (c) - 2012--2015 - IMDEA Software Institute
 * Copyright (c) - 2012--2015 - Inria
 * 
 * Distributed under the terms of the CeCILL-B-V1 license
 * -------------------------------------------------------------------- *)

(* -------------------------------------------------------------------- *)
require import Option Pred Fun Int IntExtra Real RealExtra List.
require import IntDiv Binomial Ring.
(*---*) import IntID.

(* -------------------------------------------------------------------- *)
op allperms_r (n : unit list) (s : 'a list) =
  with n = [] => [[]]
  with n = h :: n => flatten (
    map (fun x => map ((::) x) (allperms_r n (rem x s))) (undup s)).

op allperms (s : 'a list) = allperms_r (nseq (size s) tt) s.

(* -------------------------------------------------------------------- *)
lemma nosmt allperms_rP n (s t : 'a list) : size s = size n =>
  (mem (allperms_r n s) t) <=> (perm_eq s t).
proof.
elim: n s t => [s t /size_eq0 ->|_ n ih s t] //=.
  split=> [->|]; first by apply/perm_eq_refl.
  by move/perm_eq_sym; apply/perm_eq_small.
case: s ih=> [|x s] ih; first by rewrite addz_neq0 ?size_ge0.
(pose s' := undup _)=> /=; move/addrI=> eq_sz; split.
  move/flatten_mapP=> [y] [s'y] /= /mapP [t'] [+ ->>].
  case: (x = y)=> [<<-|]; first by rewrite ih // perm_cons.
  move=> ne_xy; have sy: mem s y.
    by have @/s' := s'y; rewrite mem_undup /= eq_sym ne_xy.
  rewrite ih /= ?size_rem // 1:subrE 1?addrCA //.
  move/(perm_cons y); rewrite perm_consCA => /perm_eqrE <-.
  by apply/perm_cons/perm_to_rem.
move=> ^eq_st /perm_eq_mem/(_ x) /= tx; apply/flatten_mapP=> /=.
have nz_t: t <> [] by case: (t) tx. exists (head x t) => /=.
have/perm_eq_mem/(_ (head x t)) := eq_st; rewrite /s' mem_undup.
move=> ->; rewrite -(mem_head_behead x) //=; apply/mapP.
case: (x = head x t)=> /= [xE|nex].
  exists (behead t); rewrite head_behead //= ih //.
  by rewrite -(perm_cons x) {2}xE head_behead.
have shx: mem s (head x t).
  move/perm_eq_mem/(_ (head x t)): eq_st => /=; rewrite eq_sym.
  by rewrite nex /= => ->; rewrite -(mem_head_behead x).
exists (behead t); rewrite head_behead //= ih /=.
  by rewrite size_rem // subrE addrCA.
rewrite -(perm_cons (head x t)) head_behead // perm_consCA.
by have/perm_eqrE <- := eq_st; apply/perm_cons/perm_eq_sym/perm_to_rem.
qed.

(* -------------------------------------------------------------------- *)
lemma allpermsP (s t : 'a list) :
  mem (allperms s) t <=> perm_eq s t.
proof. by apply/allperms_rP; rewrite size_nseq max_ler ?size_ge0. qed.