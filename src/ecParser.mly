%{
  open EcUtils
  open EcLocation
  open EcParsetree

  let error loc msg = raise (ParseError (loc, msg))

  let pqsymb_of_psymb (x : psymbol) : pqsymbol =
    mk_loc x.pl_loc ([], x.pl_desc)

  let pqsymb_of_symb loc x : pqsymbol =
    mk_loc loc ([], x)

  let mk_mod ?(modtypes = []) params body = Pm_struct {
    ps_params    = params;
    ps_signature = modtypes;
    ps_body      = body;
  }

  let mk_tydecl (tyvars, name) body = {
    pty_name   = name;
    pty_tyvars = tyvars;
    pty_body   = body;
  }

  let mk_datatype (tyvars, name) ctors = {
    ptd_name   = name;
    ptd_tyvars = tyvars;
    ptd_ctors  = ctors;
  }

  let mk_peid_symb loc s ti = 
    mk_loc loc (PEident (pqsymb_of_symb loc s, ti))

  let mk_pfid_symb loc s ti = 
    mk_loc loc (PFident (pqsymb_of_symb loc s, ti))

  let peapp_symb loc s ti es = 
    PEapp(mk_peid_symb loc s ti, es)

  let peget loc ti e1 e2    = 
    peapp_symb loc EcCoreLib.s_get ti [e1;e2]

  let peset loc ti e1 e2 e3 = 
    peapp_symb loc EcCoreLib.s_set ti [e1;e2;e3]

  let pfapp_symb loc s ti es = 
    PFapp(mk_pfid_symb loc s ti, es)

  let pfget loc ti e1 e2    = 
    pfapp_symb loc EcCoreLib.s_get ti [e1;e2]

  let pfset loc ti e1 e2 e3 = 
    pfapp_symb loc EcCoreLib.s_set ti [e1;e2;e3]

  let pe_nil loc ti = 
    mk_peid_symb loc EcCoreLib.s_nil ti

  let pe_cons loc ti e1 e2 = 
    mk_loc loc (peapp_symb loc EcCoreLib.s_cons ti [e1; e2])
      
  let pelist loc ti (es : pexpr    list) : pexpr    = 
    List.fold_right (fun e1 e2 -> pe_cons loc ti e1 e2) es (pe_nil loc ti)

  let pf_nil loc ti = 
    mk_pfid_symb loc EcCoreLib.s_nil ti

  let pf_cons loc ti e1 e2 = 
    mk_loc loc (pfapp_symb loc EcCoreLib.s_cons ti [e1; e2])
      
  let pflist loc ti (es : pformula    list) : pformula    = 
    List.fold_right (fun e1 e2 -> pf_cons loc ti e1 e2) es (pf_nil loc ti)

  let mk_axiom ?(local = false) ?(nosmt = false) (x, ty, vd, f) k = 
    { pa_name    = x;
      pa_tyvars  = ty;
      pa_vars    = vd;
      pa_formula = f; 
      pa_kind    = k;
      pa_nosmt   = nosmt;
      pa_local   = local; }

  let str_and b = if b then "&&" else "/\\"
  let str_or  b = if b then "||" else "\\/"

  let mk_simplify l = 
    if l = [] then
      { pbeta  = true; pzeta  = true;
        piota  = true; plogic = true;
        pdelta = None; pmodpath = true }
    else
      let doarg acc = function
        | `Delta l -> 
            if   l = [] || acc.pdelta = None
            then { acc with pdelta = None }
            else { acc with pdelta = Some (oget acc.pdelta @ l) }

        | `Zeta    -> { acc with pzeta    = true }
        | `Iota    -> { acc with piota    = true }
        | `Beta    -> { acc with pbeta    = true }
        | `Logic   -> { acc with plogic   = true }
        | `ModPath -> { acc with pmodpath = true}
      in
        List.fold_left doarg
          { pbeta  = false; pzeta  = false;
            piota  = false; plogic = false;
            pdelta = Some []; pmodpath = false } l

  let simplify_red = [`Zeta; `Iota; `Beta; `Logic; `ModPath]

  let mk_fpattern kind args =
    { fp_kind = kind;
      fp_args = args; }

  let mk_core_tactic t = { pt_core = t; pt_intros = []; }

  let mk_topmod ~local def =
    { ptm_def = def; ptm_local = local; }
%}

%token <EcSymbols.symbol> LIDENT
%token <EcSymbols.symbol> UIDENT
%token <EcSymbols.symbol> TIDENT
%token <EcSymbols.symbol> MIDENT
%token <EcSymbols.symbol> PBINOP

%token <int> NUM
%token <string> STRING

(* Tokens *)
%token <bool> AND (* true asym : &&, false sym : /\ *)
%token <bool> OR  (* true asym : ||, false sym : \/ *)

%token <EcParsetree.codepos> CPOS

%token ADD
%token ADMIT
%token ALIAS
%token APPLY
%token ARROW
%token AS
%token ASSERT
%token ASSUMPTION
%token AT
%token AUTO
%token AXIOM
%token BACKS
%token BDEQ
%token BDHOARE
%token BDHOAREDENO
%token BETA 
%token BY
%token BYPR
%token CALL
%token CASE
%token CEQ
%token CFOLD
%token CHANGE
%token CHECKPROOF
%token CLAIM
%token CLEAR
%token CLONE
%token COLON
%token COMMA
%token COMPUTE
%token CONGR
%token CONSEQ
%token EXFALSO
%token CONST
%token CUT
%token DATATYPE
%token DEBUG
%token DELTA
%token DLBRACKET
%token DO
%token DOT
%token DOTDOT
%token DROP
%token ELIM
%token ELIMT
%token ELSE
%token END
%token EOF
%token EQ
%token EQUIV
%token EQUIVDENO
%token EXIST
%token EXPORT
%token FEL
%token FIELD
%token FIELDSIMP
%token FINAL
%token FIRST
%token FISSION
%token FORALL
%token FROM_INT
%token FUN
%token FUSION
%token FWDS
%token GENERALIZE 
%token GLOB
%token HOARE
%token IDTAC
%token IF
%token IFF
%token IMPL
%token IMPORT
%token IMPOSSIBLE
%token IN
%token INLINE
%token INTROS
%token IOTA
%token KILL
%token LAMBDA
%token LAST
%token LBRACE
%token LBRACKET
%token LEFT
%token LEFTARROW
%token LEMMA
%token LET
%token LOCAL
%token LOGIC
%token LONGARROW
%token LOSSLESS
%token LPAREN
%token MINUS
%token MODPATH
%token MODULE
%token NE
%token NOSMT
%token NOT
%token OF
%token OFF
%token ON
%token OP
%token PIPE
%token POSE
%token PR
%token PRAGMA
%token PRBOUNDED
%token PRED
%token PRFALSE
%token PRINT
%token PROGRESS
%token PROOF
%token PROR
%token PROVER
%token QED
%token QUESTION
%token RBOOL
%token RBRACE
%token RBRACKET
%token RCONDF
%token RCONDT
%token REQUIRE
%token RES
%token RETURN
%token REWRITE
%token RIGHT
%token RND
%token RPAREN
%token SAME
%token SAMPLE
%token SAVE
%token SECTION
%token SEMICOLON
%token SEQ
%token SIMPLIFY
%token SKIP
%token SLASHEQ
%token SLASHSLASH
%token SLASHSLASHEQ
%token SMT
%token SPLIT
%token SPLITWHILE
%token STAR
%token STRICT
%token SUBST
%token SWAP
%token THEN
%token THEORY
%token TICKPIPE
%token TILD
%token TIMEOUT
%token TRIVIAL
%token TRY
%token TYPE
%token UNDERSCORE
%token UNDO
%token UNROLL
%token USING
%token VAR
%token WHILE
%token WHY3
%token WITH
%token WP
%token EQOBSIN
%token ZETA 

%token <string> OP1 OP2 OP3 OP4
%token LTCOLON GT GE LE

%nonassoc COMMA ELSE

%nonassoc IN
%nonassoc prec_below_IMPL
%right IMPL IFF
%right OR 
%right AND 

%nonassoc NOT
%left EQ NE OP1 GT GE LE

%right QUESTION
%left OP2 MINUS ADD
%right ARROW
%left OP3 STAR
%left OP4 

%nonassoc LBRACE

%right SEMICOLON

%nonassoc prec_prefix_op
%nonassoc prec_tactic

%type <EcParsetree.global EcLocation.located> global
%type <EcParsetree.prog> prog

%start prog global
%%

(* -------------------------------------------------------------------- *)
%inline lident: x=loc(LIDENT) { x };
%inline uident: x=loc(UIDENT) { x };
%inline tident: x=loc(TIDENT) { x };
%inline mident: x=loc(MIDENT) { x };

%inline _ident:
| x=LIDENT { x }
| x=UIDENT { x }
;

%inline ident:
| x=loc(_ident) { x }
;

%inline number: n=NUM { n };

(* -------------------------------------------------------------------- *)
%inline namespace:
| nm=rlist1(UIDENT, DOT) { nm }
;

qident:
| x=ident { pqsymb_of_psymb x }

| xs=namespace DOT x=_ident {
    { pl_desc = (xs, x);
      pl_loc  = EcLocation.make $startpos(xs) $endpos(xs);
    }
  }
;

(* -------------------------------------------------------------------- *)
uqident:
| x=UIDENT {
    { pl_desc = ([], x);
      pl_loc  = EcLocation.make $startpos $endpos; }
  }

| xs=namespace DOT x=UIDENT {
    { pl_desc = (xs, x);
      pl_loc  = EcLocation.make $startpos $endpos;
    }
  }
;

(* -------------------------------------------------------------------- *)
%inline _oident:
| x=LIDENT { x }
| x=UIDENT { x }
| x=PBINOP { x }
;

%inline oident:
| x=loc(_oident) { x }
;

qoident:
| x=oident
    { pqsymb_of_psymb x }

| xs=namespace DOT x=oident {
    { pl_desc = (xs, unloc x);
      pl_loc  = EcLocation.make $startpos $endpos;
    }
  }
;

(* -------------------------------------------------------------------- *)
mod_ident1:
| x=uident
    { (x, None) }

| x=uident LPAREN args=plist1(loc(mod_qident), COMMA) RPAREN
    { (x, Some args) }
;

%inline mod_qident:
| x=rlist1(mod_ident1, DOT) { x }
;

fident:
| nm=mod_qident DOT x=lident { (nm, x) }
| x=lident { ([], x) }
;

(* -------------------------------------------------------------------- *)
%inline binop:
| EQ      { "=" }
| x=AND   { str_and x }
| x=OR    { str_or  x }
| STAR    { "*" }
| GT      { ">" }
| GE      { ">=" }
| LE      { "<=" }
| ADD     { "+" }
| MINUS   { "-" }
| x=OP1   { x   }
| x=OP2   { x   }
| x=OP3   { x   }
| x=OP4   { x   }
;

(* -------------------------------------------------------------------- *)
pside_:
| x=LIDENT     { (0, Printf.sprintf "&%s" x) }
| x=NUM        { (0, Printf.sprintf "&%d" x) }
| ADD x=pside_ { (1 + fst x, snd x) }
;

pside:
| x=brace(pside_) { x }
;

(* -------------------------------------------------------------------- *)
(* Patterns                                                             *)

lpattern_u:
| x=ident { LPSymbol x }
| LPAREN p=plist2(ident, COMMA) RPAREN { LPTuple p }
;

%inline lpattern:
| x=loc(lpattern_u) { x }
;

(* -------------------------------------------------------------------- *)
(* Expressions: program expression, real expression                     *)

tyvar_byname1:
| x=tident EQ ty=loc(type_exp) { (x, ty) }
;

tyvar_annot:
| lt = plist1(loc(type_exp), COMMA) { TVIunamed lt }
| lt = plist1(tyvar_byname1, COMMA) { TVInamed lt }
;

%inline tvars_app:
| LTCOLON k=loc(tyvar_annot) GT { k }
;

(* -------------------------------------------------------------------- *)
%inline sexpr: x=loc(sexpr_u) { x };
%inline  expr: x=loc( expr_u) { x };

sexpr_u:
| n=number
   { PEint n }

| x=qoident ti=tvars_app?
   { PEident (x, ti) }

| se=sexpr op=loc(FROM_INT)
   { let id =
       PEident (mk_loc op.pl_loc EcCoreLib.s_from_int, None)
     in
       PEapp (mk_loc op.pl_loc id, [se]) }

| se=sexpr DLBRACKET ti=tvars_app? e=expr RBRACKET
   { peget (EcLocation.make $startpos $endpos) ti se e }

| se=sexpr DLBRACKET ti=tvars_app? e1=expr LEFTARROW e2=expr RBRACKET  
   { peset (EcLocation.make $startpos $endpos) ti se e1 e2 }

| TICKPIPE ti=tvars_app? e=expr PIPE 
   { peapp_symb e.pl_loc EcCoreLib.s_abs ti [e] }

| LBRACKET ti=tvars_app? es=loc(plist0(expr, SEMICOLON)) RBRACKET  
   { unloc (pelist es.pl_loc ti es.pl_desc) } 

| LBRACKET ti=tvars_app? e1=expr op=loc(DOTDOT) e2=expr RBRACKET
   { let id =
       PEident (mk_loc op.pl_loc EcCoreLib.s_dinter, ti)
     in
       PEapp(mk_loc op.pl_loc id, [e1; e2]) }

| LPAREN es=plist0(expr, COMMA) RPAREN
   { PEtuple es }

| r=loc(RBOOL)
   { PEident (mk_loc r.pl_loc EcCoreLib.s_dbool, None) }
;

expr_u:
| e=sexpr_u { e }

| e=sexpr args=sexpr+
    { PEapp (e, args) }

| op=loc(NOT) ti=tvars_app? e=expr
    { peapp_symb op.pl_loc "!" ti [e] }

| op=loc(binop) ti=tvars_app? e=expr %prec prec_prefix_op
    { peapp_symb op.pl_loc op.pl_desc ti [e] } 

| e1=expr op=loc(OP1) ti=tvars_app? e2=expr 
    { peapp_symb op.pl_loc op.pl_desc ti [e1; e2] }

| e1=expr op=loc(GT) ti=tvars_app? e2=expr  
    { peapp_symb op.pl_loc ">" ti [e1; e2] }

| e1=expr op=loc(LE) ti=tvars_app? e2=expr
    { peapp_symb op.pl_loc "<=" ti [e1; e2] }

| e1=expr op=loc(GE) ti=tvars_app? e2=expr
    { peapp_symb op.pl_loc ">=" ti [e1; e2] }

| e1=expr op=loc(EQ) ti=tvars_app? e2=expr
    { peapp_symb op.pl_loc "=" ti [e1; e2] }

| e1=expr op=loc(NE) ti=tvars_app? e2=expr
    { peapp_symb op.pl_loc "!" None 
      [ mk_loc op.pl_loc (peapp_symb op.pl_loc "=" ti [e1; e2])] }

| e1=expr op=loc(ADD) ti=tvars_app? e2=expr 
    { peapp_symb op.pl_loc "+" ti [e1; e2] }

| e1=expr op=loc(MINUS) ti=tvars_app? e2=expr 
    { peapp_symb op.pl_loc "-" ti [e1; e2] }

| e1=expr op=loc(OP2) ti=tvars_app? e2=expr 
    { peapp_symb op.pl_loc op.pl_desc ti [e1; e2] }

| e1=expr op=loc(OP3) ti=tvars_app? e2=expr 
    { peapp_symb op.pl_loc op.pl_desc ti [e1; e2] }

| e1=expr op=loc(OP4) ti=tvars_app? e2=expr 
    { peapp_symb op.pl_loc op.pl_desc ti [e1; e2] }

| e1=expr op=loc(IMPL) ti=tvars_app? e2=expr
    { peapp_symb op.pl_loc "=>" ti [e1; e2] }

| e1=expr op=loc(IFF) ti=tvars_app? e2=expr 
    { peapp_symb op.pl_loc "<=>" ti [e1; e2] }

| e1=expr op=loc(OR) ti=tvars_app? e2=expr  
    { peapp_symb op.pl_loc (str_or op.pl_desc) ti [e1; e2] }

| e1=expr op=loc(AND) ti=tvars_app? e2=expr 
    { peapp_symb op.pl_loc (str_and op.pl_desc) ti [e1; e2] }

| e1=expr op=loc(STAR) ti=tvars_app?  e2=expr  
    { peapp_symb op.pl_loc "*" ti [e1; e2] }

| c=expr QUESTION e1=expr COLON e2=expr %prec OP2
   { PEif (c, e1, e2) }

| IF c=expr THEN e1=expr ELSE e2=expr
   { PEif (c, e1, e2) }

| LET p=lpattern EQ e1=expr IN e2=expr
   { PElet (p, e1, e2) }

| r=loc(RBOOL) TILD e=sexpr
    { let id  = PEident(mk_loc r.pl_loc EcCoreLib.s_dbitstring, None) in
      let loc = EcLocation.make $startpos $endpos in
        PEapp (mk_loc loc id, [e]) }

| LAMBDA pd=ptybindings COMMA e=expr { PElambda (pd, e) } 
;

%inline pty_varty:
| x=ident+
   { let loc = EcLocation.make $startpos $endpos in
       (x, mk_loc loc PTunivar) }

| x=ident+ COLON ty=loc(type_exp)
   { (x, ty) }
;

ptybinding1:
| LPAREN bds=plist1(pty_varty, COMMA) RPAREN { bds }
| x=ident { [[x], mk_loc x.pl_loc PTunivar] }
;

ptybindings:
| x=ptybinding1+ { List.flatten x } 
;

(* -------------------------------------------------------------------- *)
(* Formulas                                                             *)

%inline sform_r(P): x=loc(sform_u(P)) { x }
%inline  form_r(P): x=loc( form_u(P)) { x }

%inline sform: x=sform_r(none) { x }
%inline  form: x=form_r (none) { x }

%inline sform_h: x=loc(sform_u(hole)) { x }
%inline  form_h: x=loc( form_u(hole)) { x }

%inline hole: UNDERSCORE { PFhole; }
%inline none: IMPOSSIBLE { assert false; }

qident_or_res_or_glob:
| x=qident   { GVvar x }
| x=loc(RES) { GVvar (mk_loc x.pl_loc ([], "res")) }
| GLOB mp=loc(mod_qident) { GVglob mp }

sform_u(P):
| x=P 
   { x }

| n=number
   { PFint n }

| x=loc(RES)
   { PFident (mk_loc x.pl_loc ([], "res"), None) }

| x=qoident ti=tvars_app?
   { PFident (x, ti) }

| se=sform_r(P) op=loc(FROM_INT)
   { let id = PFident(mk_loc op.pl_loc EcCoreLib.s_from_int, None) in
     PFapp (mk_loc op.pl_loc id, [se]) }

| se=sform_r(P) DLBRACKET ti=tvars_app? e=form_r(P) RBRACKET
   { pfget (EcLocation.make $startpos $endpos) ti se e }

| se=sform_r(P) DLBRACKET ti=tvars_app? e1=form_r(P) LEFTARROW e2=form_r(P) RBRACKET
   { pfset (EcLocation.make $startpos $endpos) ti se e1 e2 }

| x=sform_r(P) s=loc(pside)
   { PFside (x, s) }

| TICKPIPE ti=tvars_app? e =form_r(P) PIPE 
    { pfapp_symb e.pl_loc EcCoreLib.s_abs ti [e] }

| LPAREN fs=plist0(form_r(P), COMMA) RPAREN
   { PFtuple fs }

| LBRACKET ti=tvars_app? es=loc(plist0(form_r(P), SEMICOLON)) RBRACKET
   { (pflist es.pl_loc ti es.pl_desc).pl_desc }

| HOARE LBRACKET
    mp=loc(fident) COLON pre=form_r(P) LONGARROW post=form_r(P)
  RBRACKET
    { PFhoareF (pre, mp, post) }

| EQUIV LBRACKET eb=equiv_body(P) RBRACKET { eb }

| HOARE LBRACKET
    s=loc(fun_def_body)
    COLON pre=form_r(P) LONGARROW post=form_r(P)
  RBRACKET
	{ PFhoareS (pre, s, post) }

| PR LBRACKET
    mp=loc(fident) args=paren(plist0(sform_r(P), COMMA)) AT pn=mident
    COLON event=form_r(P)
  RBRACKET
    { PFprob (mp, args, pn, event) }

| r=loc(RBOOL)
    { PFident (mk_loc r.pl_loc EcCoreLib.s_dbool, None) }

| LBRACKET ti=tvars_app? e1=form_r(P) op=loc(DOTDOT) e2=form_r(P) RBRACKET
    { let id = PFident(mk_loc op.pl_loc EcCoreLib.s_dinter, ti) in
      PFapp(mk_loc op.pl_loc id, [e1; e2]) } 
;
                          
form_u(P):
| GLOB mp=loc(mod_qident) { PFglob mp }

| e=sform_u(P) { e }

| e=sform_r(P) args=sform_r(P)+ { PFapp (e, args) } 

| op=loc(NOT) ti=tvars_app? e=form_r(P) 
    { pfapp_symb  op.pl_loc "!" ti [e] }

| op=loc(binop) ti=tvars_app? e=form_r(P) %prec prec_prefix_op
   { pfapp_symb op.pl_loc op.pl_desc ti [e] } 

| e1=form_r(P) op=loc(OP1) ti=tvars_app? e2=form_r(P)
    { pfapp_symb op.pl_loc op.pl_desc ti [e1; e2] } 

| e1=form_r(P) op=loc(GT) ti=tvars_app? e2=form_r(P)
    { pfapp_symb op.pl_loc ">" ti [e1; e2] } 

| e1=form_r(P) op=loc(LE) ti=tvars_app? e2=form_r(P)
    { pfapp_symb op.pl_loc "<=" ti [e1; e2] } 

| e1=form_r(P) op=loc(GE) ti=tvars_app? e2=form_r(P)
    { pfapp_symb op.pl_loc ">=" ti [e1; e2] } 

| e1=form_r(P) op=loc(EQ) ti=tvars_app? e2=form_r(P)
    { pfapp_symb op.pl_loc "=" ti [e1; e2] }

| e1=form_r(P) op=loc(NE) ti=tvars_app? e2=form_r(P)
    { pfapp_symb op.pl_loc "!" None 
      [ mk_loc op.pl_loc (pfapp_symb op.pl_loc "=" ti [e1; e2])] }

| e1=form_r(P) op=loc(MINUS) ti=tvars_app? e2=form_r(P)
    { pfapp_symb op.pl_loc "-" ti [e1; e2] }

| e1=form_r(P) op=loc(ADD) ti=tvars_app? e2=form_r(P) 
    { pfapp_symb op.pl_loc "+" ti [e1; e2] }

| e1=form_r(P) op=loc(OP2) ti=tvars_app? e2=form_r(P)  
    { pfapp_symb op.pl_loc op.pl_desc ti [e1; e2] }

| e1=form_r(P) op=loc(OP3) ti=tvars_app? e2=form_r(P)  
    { pfapp_symb op.pl_loc op.pl_desc ti [e1; e2] }

| e1=form_r(P) op=loc(OP4) ti=tvars_app? e2=form_r(P)  
    { pfapp_symb op.pl_loc op.pl_desc ti [e1; e2] }

| e1=form_r(P) op=loc(IMPL) ti=tvars_app? e2=form_r(P)  
    { pfapp_symb op.pl_loc "=>" ti [e1; e2] }

| e1=form_r(P) op=loc(IFF) ti=tvars_app? e2=form_r(P)  
    { pfapp_symb op.pl_loc "<=>" ti [e1; e2] }

| e1=form_r(P) op=loc(OR) ti=tvars_app? e2=form_r(P)  
    { pfapp_symb op.pl_loc (str_or op.pl_desc) ti [e1; e2] }

| e1=form_r(P) op=loc(AND) ti=tvars_app? e2=form_r(P)  
    { pfapp_symb op.pl_loc (str_and op.pl_desc) ti [e1; e2] }

| e1=form_r(P) op=loc(STAR ) ti=tvars_app? e2=form_r(P)  
    { pfapp_symb op.pl_loc "*" ti [e1; e2] }

| c=form_r(P) QUESTION e1=form_r(P) COLON e2=form_r(P) %prec OP2
    { PFif (c, e1, e2) }

| EQ LBRACE xs=plist1(qident_or_res_or_glob, COMMA) RBRACE
    { PFeqveq xs }

| IF c=form_r(P) THEN e1=form_r(P) ELSE e2=form_r(P)
    { PFif (c, e1, e2) }

| LET p=lpattern EQ e1=form_r(P) IN e2=form_r(P) { PFlet (p, e1, e2) }

| FORALL pd=pgtybindings COMMA e=form_r(P) { PFforall (pd, e) }
| EXIST  pd=pgtybindings COMMA e=form_r(P) { PFexists (pd, e) }
| LAMBDA pd=ptybindings  COMMA e=form_r(P) { PFlambda (pd, e) }

| r=loc(RBOOL) TILD e=sform_r(P)
    { let id  = PFident (mk_loc r.pl_loc EcCoreLib.s_dbitstring, None) in
      let loc = EcLocation.make $startpos $endpos in
        PFapp (mk_loc loc id, [e]) }

| BDHOARE 
    LBRACKET mp=loc(fident) COLON
      pre=form_r(P) LONGARROW post=form_r(P)
    RBRACKET
      cmp=hoare_bd_cmp bd=sform_r(P)
	{ PFBDhoareF (pre, mp, post, cmp, bd) }

| BDHOARE 
    LBRACKET s=loc(fun_def_body) COLON
      pre=form_r(P) LONGARROW post=form_r(P)
    RBRACKET
      cmp=hoare_bd_cmp bd=sform_r(P)
	{ PFBDhoareS (pre, s, post, cmp, bd) }

| LOSSLESS mp=loc(fident)
    { PFlsless mp }
;

hoare_bd_cmp :
| LE {PFHle}
| EQ {PFHeq}
| GE {PFHge}

equiv_body(P):
  mp1=loc(fident) TILD mp2=loc(fident)
  COLON pre=form_r(P) LONGARROW post=form_r(P)

    { PFequivF (pre, (mp1, mp2), post) }

pgtybinding1:
| x=ptybinding1 { List.map (fun (xs,ty) -> xs, PGTY_Type ty) x }

| LPAREN x=uident LTCOLON mi=mod_type_restr RPAREN
    { [[x], PGTY_ModTy mi] }

| pn=mident
    { [[pn], PGTY_Mem] }
;

pgtybindings:
| x=pgtybinding1+ { List.flatten x }
;

(* -------------------------------------------------------------------- *)
(* Type expressions                                                     *)

simpl_type_exp:
| UNDERSCORE                  { PTunivar       }
| x=qident                    { PTnamed x      }
| x=tident                    { PTvar x        }
| tya=type_args x=qident      { PTapp (x, tya) }
| LPAREN ty=type_exp RPAREN   { ty             }
;

type_args:
| ty=loc(simpl_type_exp)                          { [ty] }
| LPAREN tys=plist2(loc(type_exp), COMMA) RPAREN  { tys  }
;

type_exp:
| ty=simpl_type_exp                              { ty }
| ty=plist2(loc(simpl_type_exp), STAR)           { PTtuple ty }
| ty1=loc(type_exp) ARROW ty2=loc(type_exp)      { PTfun(ty1,ty2) }
;

(* -------------------------------------------------------------------- *)
(* Parameter declarations                                              *)

typed_vars:
| xs=ident+ COLON ty=loc(type_exp)
   { List.map (fun v -> (v, ty)) xs }

| xs=ident+
    { List.map (fun v -> (v, mk_loc v.pl_loc PTunivar)) xs }
;

param_decl:
| LPAREN aout=plist0(typed_vars, COMMA) RPAREN { List.flatten aout }
;

(* -------------------------------------------------------------------- *)
(* Statements                                                           *)

lvalue_u:
| x=qident
   { PLvSymbol x }

| LPAREN p=plist2(qident, COMMA) RPAREN
   { PLvTuple p }

| x=qident DLBRACKET ti=tvars_app? e=expr RBRACKET
   { PLvMap(x, ti, e) }
;

%inline lvalue:
| x=loc(lvalue_u) { x }
;

base_instr:
| x=lvalue EQ SAMPLE e=expr
    { PSrnd (x, e) }

| x=lvalue EQ e=expr
    { let islow = function 'a'..'z' -> true | _ -> false in
      let islow = fun s -> s <> "" && islow s.[0] in

        match unloc e with
        | PEapp ( { pl_desc = PEident (({ pl_desc = (_, fx) } as f), None) },
                 [{ pl_desc = PEtuple es; pl_loc = les; }])
            when islow fx ->
          begin
            PScall (Some x, f, mk_loc les es)
          end
        | _ -> PSasgn (x, e) }

| f=qident LPAREN es=loc(plist0(expr, COMMA)) RPAREN
    { PScall (None, f, es) }

| ASSERT LPAREN c=expr RPAREN 
    { PSassert c }
;

instr:
| bi=base_instr SEMICOLON
   { bi }

| IF LPAREN c=expr RPAREN b1=block ELSE b2=block
   { PSif (c, b1, b2) }

| IF LPAREN c=expr RPAREN b=block
   { PSif (c, b , []) }

| WHILE LPAREN c=expr RPAREN b=block
   { PSwhile (c, b) }
;

block:
| i=loc(base_instr) SEMICOLON
    { [i] }

| stmt=brace(stmt)
   { stmt }
;

stmt: aout=loc(instr)* { aout }

(* -------------------------------------------------------------------- *)
(* Module definition                                                    *)

var_decl:
| VAR xs=plist1(lident, COMMA) COLON ty=loc(type_exp)
   { (xs, ty) }
;

loc_decl_names:
| x=plist1(lident, COMMA) { (`Single, x) }

| LPAREN x=plist2(lident, COMMA) RPAREN { (`Tuple, x) }
;

loc_decl_r:
| VAR x=loc(loc_decl_names) COLON ty=loc(type_exp)
    { { pfl_names = x; pfl_type = Some ty; pfl_init = None; } }

| VAR x=loc(loc_decl_names) COLON ty=loc(type_exp) EQ e=expr
    { { pfl_names = x; pfl_type = Some ty; pfl_init = Some e; } }

| VAR x=loc(loc_decl_names) EQ e=expr
    { { pfl_names = x; pfl_type = None; pfl_init = Some e; } }
;

loc_decl:
| x=loc_decl_r SEMICOLON { x }
;

ret_stmt:
| RETURN e=expr SEMICOLON
    { Some e }

| empty
    { None }
;

fun_def_body:
| LBRACE decl=loc_decl* s=stmt rs=ret_stmt RBRACE
    { { pfb_locals = decl;
        pfb_body   = s   ;
        pfb_return = rs  ; }
    }
;

fun_decl:
| x=lident pd=param_decl COLON ty=loc(type_exp)
    { { pfd_name     = x   ;
        pfd_tyargs   = pd  ;
        pfd_tyresult = ty  ;
        pfd_uses     = None; }
    }
;

mod_item:
| v=var_decl
    { Pst_var v }

| m=mod_def
    { let (x, m) = m in Pst_mod (x, m) }

| FUN decl=fun_decl EQ body=fun_def_body
    { Pst_fun (decl, body) }

| FUN x=lident EQ f=qident
    { Pst_alias (x, f) }
;

(* -------------------------------------------------------------------- *)
(* Modules                                                              *)

mod_body:
| m=mod_qident
    { `App m }

| LBRACE stt=loc(mod_item)* RBRACE
    { `Struct stt }
;

mod_def:
| MODULE x=uident p=mod_params? t=mod_aty? EQ body=loc(mod_body)
    { let p = EcUtils.odfl [] p in
        match body.pl_desc with
        | `App m ->
             if p <> [] then
               error (EcLocation.make $startpos $endpos)
                 (Some "cannot parameterized module alias");
             if t <> None then
               error (EcLocation.make $startpos $endpos)
                 (Some "cannot bind module type to module alias"); 
             (x, mk_loc body.pl_loc (Pm_ident m))

        | `Struct st ->
             (x, mk_loc body.pl_loc (mk_mod ?modtypes:t p st)) }
;

top_mod_def:
| x=mod_def       { mk_topmod ~local:false x }
| LOCAL x=mod_def { mk_topmod ~local:true  x }
;

mod_params:
| LPAREN a=plist1(sig_param, COMMA) RPAREN  { a }
;

mod_aty:
| COLON t=plist1(loc(mod_aty1), COMMA) { t }
;

mod_aty1:
| x=qident { (x, []) }
| x=qident xs=paren(ident+) { (x, xs) }
;

(* -------------------------------------------------------------------- *)
(* Modules interfaces                                                   *)

%inline mod_type:
| x = qident { x }
;

%inline mod_type_restr:
| x = qident { (x,[]) }
| x = qident LBRACE restr=plist1(loc(mod_qident),COMMA) RBRACE { (x,restr) }
;

sig_def:
| MODULE TYPE x=uident args=sig_params? EQ i=sig_body
    {
      let args = EcUtils.odfl [] args in
      (x, Pmty_struct { pmsig_params = args;
                        pmsig_body   = i; })
    }
;

sig_body:
| body=sig_struct_body { body }
;

sig_struct_body:
| LBRACE ty=signature_item* RBRACE
    { ty }
;

sig_params:
| LPAREN params=plist1(sig_param, COMMA) RPAREN
    { params }
;

sig_param:
| x=uident COLON i=mod_type { (x, i) }
;

signature_item:
| FUN decl=ifun_decl
    { `FunctionDecl decl }
;

ifun_decl:
| x=lident pd=param_decl COLON ty=loc(type_exp) us=brace(oracle_info)?
    { { pfd_name     = x ;
        pfd_tyargs   = pd;
        pfd_tyresult = ty;
        pfd_uses     = us; }
    }
;

oracle_info:
| i=STAR? qs=qident* { i=None, qs }
;

(* -------------------------------------------------------------------- *)
(* EcTypes declarations / definitions                                   *)

typarams:
| empty
    { []  }

| x=tident
   { [x] }

| LPAREN xs=plist1(tident, COMMA) RPAREN
    { xs }
;

type_decl:
| TYPE tya=typarams x=ident { (tya, x) }
;

type_decl_or_def:
| td=type_decl { mk_tydecl td None }
| td=type_decl EQ te=loc(type_exp) { mk_tydecl td (Some te) }
;

(* -------------------------------------------------------------------- *)
(* Datatypes                                                            *)

datatype_def:
| DATATYPE tya=typarams x=ident EQ PIPE? ctors=plist1(dt_ctor_def, PIPE)
    { mk_datatype (tya, x) ctors }
;

dt_ctor_def:
| x=uident { (x, None) }
| x=uident OF ty=loc(simpl_type_exp) { (x, (Some ty)) }
;

(* -------------------------------------------------------------------- *)
(* Operator definitions                                                 *)

op_tydom:
| LPAREN RPAREN
    { [  ] }

| ty=loc(simpl_type_exp)
   { [ty] }

| tys=paren(plist2(loc(type_exp), COMMA))
   { tys  }
;

tyvars_decl:
| LBRACKET tyvars=tident* RBRACKET { Some tyvars }
| empty { None }
;

%inline op_or_const:
| OP    { `Op }
| CONST { `Const }
;

operator:
| k=op_or_const x=oident tyvars=tyvars_decl COLON sty=loc(type_exp) {
    { po_kind   = k;
      po_name   = x;
      po_tyvars = tyvars;
      po_def    = POabstr sty; }
  }

| k=op_or_const x=oident tyvars=tyvars_decl COLON sty=loc(type_exp) EQ b=expr {
    { po_kind   = k;
      po_name   = x;
      po_tyvars = tyvars;
      po_def    = POconcr ([], sty, b); }
  }

| k=op_or_const x=oident tyvars=tyvars_decl eq=loc(EQ) b=expr {
    { po_kind   = k;
      po_name   = x;
      po_tyvars = tyvars;
      po_def    = POconcr([], mk_loc eq.pl_loc PTunivar, b); }
  }

| k=op_or_const x=oident tyvars=tyvars_decl p=ptybindings eq=loc(EQ) b=expr {
    { po_kind   = k;
      po_name   = x;
      po_tyvars = tyvars;
      po_def    = POconcr(p, mk_loc eq.pl_loc PTunivar, b); }
  }

| k=op_or_const x=oident tyvars=tyvars_decl p=ptybindings COLON codom=loc(type_exp)
    EQ b=expr {
    { po_kind   = k;
      po_name   = x;
      po_tyvars = tyvars;
      po_def    = POconcr(p, codom, b); }
  } 
;

predicate:
| PRED x = oident
   { { pp_name = x;
       pp_tyvars = None;
       pp_def = PPabstr []; } }

| PRED x = oident tyvars=tyvars_decl COLON sty = op_tydom
   { { pp_name = x;
       pp_tyvars = tyvars;
       pp_def = PPabstr sty; } }

| PRED x = oident tyvars=tyvars_decl p=ptybindings EQ f=form
   { { pp_name = x;
       pp_tyvars = tyvars;
       pp_def = PPconcr(p,f); } } 
;

(* -------------------------------------------------------------------- *)
(* Global entries                                                       *)

%inline ident_exp:
| x=ident COMMA e=expr { (x, e) }
;

real_hint:
| USING x=ident { Husing x }
| ADMIT         { Hadmit }
| COMPUTE       { Hcompute }
| SPLIT         { Hsplit }
| SAME          { Hsame }
| AUTO          { Hauto }
| empty         { Hnone }

| COMPUTE n=NUM e1=expr COMMA e2=expr
   { Hfailure (n, e1, e2, []) }

| COMPUTE n=NUM e1=expr COMMA e2=expr COLON l=plist1(ident_exp, COLON)
   { Hfailure (n, e1, e2, l) }
;

claim:
| CLAIM x=ident COLON e=expr h=real_hint { (x, (e, h)) }
;

lemma_decl :
| x=ident tyvars=tyvars_decl pd=pgtybindings? COLON f=form { x,tyvars,pd,f }
;

nosmt:
| NOSMT { true  }
| empty { false }
;

local:
| LOCAL { true  }
| empty { false }
;

axiom:
| l=local AXIOM o=nosmt d=lemma_decl 
    { mk_axiom ~local:l ~nosmt:o d PAxiom }

| l=local LEMMA o=nosmt d=lemma_decl
    { mk_axiom ~local:l ~nosmt:o d PILemma }

| l=local LEMMA o=nosmt d=lemma_decl BY t=tactic
    { mk_axiom ~local:l ~nosmt:o d (PLemma (Some t)) }

| l=local LEMMA o=nosmt d=lemma_decl BY LBRACKET RBRACKET
    { mk_axiom ~local:l ~nosmt:o d (PLemma None) }

| l=local EQUIV x=ident pd=pgtybindings? COLON p=loc(equiv_body(none))
    { mk_axiom ~local:l (x, None, pd, p) PILemma }

| l=local EQUIV x=ident pd=pgtybindings? COLON p=loc(equiv_body(none)) BY t=tactic
    { mk_axiom ~local:l (x, None, pd, p) (PLemma (Some t)) }

| l=local EQUIV x=ident pd=pgtybindings? COLON p=loc(equiv_body(none)) BY LBRACKET RBRACKET
    { mk_axiom ~local:l (x, None, pd, p) (PLemma None) }
;

(* -------------------------------------------------------------------- *)
(* Theory interactive manipulation                                      *)

theory_open  : THEORY  x=uident  { x }
theory_close : END     x=uident  { x }

section_open  : SECTION     { () }
section_close : END SECTION { () }

import_flag:
| IMPORT { `Import }
| EXPORT { `Export }
;

theory_require : 
| REQUIRE ip=import_flag? x=uident { (x, ip) }
;

theory_import: IMPORT x=uqident { x }
theory_export: EXPORT x=uqident { x }

theory_w3:
| IMPORT WHY3 path=string_list r=plist0(renaming,SEMICOLON)
    { 
      let l = List.rev path in
      let th = List.hd l in
      let path = List.rev (List.tl l) in
      path,th,r }
;

renaming:
| TYPE l=string_list AS s=STRING { l, RNty, s }
| OP   l=string_list AS s=STRING { l, RNop, s }
| AXIOM l=string_list AS s=STRING {l, RNpr, s }
;

%inline string_list: l=plist1(STRING,empty) { l };

(* -------------------------------------------------------------------- *)
(* pattern selection (tactics)                                          *)
idpattern:
| x=ident { [x] }
| LBRACKET xs=ident+ RBRACKET { xs }
;

ipattern:
| UNDERSCORE
    { PtAny }

| UNDERSCORE CEQ f=idpattern LPAREN UNDERSCORE RPAREN
    { PtAsgn f }

| IF UNDERSCORE LBRACE p=spattern RBRACE
    { PtIf (p, `NoElse) }

| IF UNDERSCORE LBRACE p=spattern RBRACE UNDERSCORE
    { PtIf (p, `MaybeElse) }

| IF UNDERSCORE LBRACE p1=spattern RBRACE ELSE LBRACE p2=spattern RBRACE
    { PtIf (p1, `Else p2) }

| WHILE UNDERSCORE LBRACE p=spattern RBRACE
    { PtWhile p }
;

spattern:
| UNDERSCORE { () }
;

tselect:
| p=ipattern { p }
;

(* -------------------------------------------------------------------- *)
(* tactic                                                               *)


intro_pattern_1_name:
| s=LIDENT   { s }
| s=UIDENT   { s }
| s=MIDENT   { s }
;

intro_pattern_1:
| UNDERSCORE { `noName }
| QUESTION { `findName }
| s=intro_pattern_1_name {`noRename s}
| s=intro_pattern_1_name NOT {`withRename s}
;

intro_pattern:
| x=loc(intro_pattern_1)
   { IPCore x }

| LBRACKET RBRACKET
   { IPCase [] }

| LBRACKET ip=intro_pattern+ RBRACKET
   { IPCase [ip] }

| LBRACKET ip=plist2(intro_pattern*, PIPE) RBRACKET
   { IPCase ip }

| o=rwocc? ARROW
   { IPRw (omap o EcMaps.Sint.of_list, `LtoR) }

| o=rwocc? LEFTARROW
   { IPRw (omap o EcMaps.Sint.of_list, `RtoL) }

| LBRACE xs=lident+ RBRACE
   { IPClear xs }

| SLASHSLASH
   { IPDone false }

| SLASHSLASHEQ
   { IPDone true }

| SLASHEQ
   { IPSimplify }
;

fpattern_head(F):
| p=qident tvi=tvars_app?
   { FPNamed (p, tvi) }

| LPAREN UNDERSCORE COLON f=F RPAREN
   { FPCut f }
;

fpattern_arg:
| UNDERSCORE   { EA_none }
| f=sform      { EA_form f }
| s=mident     { EA_mem s }
;

fpattern(F):
| hd=fpattern_head(F)
   { mk_fpattern hd [] }

| LPAREN hd=fpattern_head(F) args=loc(fpattern_arg)* RPAREN
   { mk_fpattern hd args }
;

rwside:
| MINUS { `RtoL }
| empty { `LtoR }
;

rwrepeat:
| NOT            { (`All  , None  ) }
| QUESTION       { (`Maybe, None  ) }
| n=NUM NOT      { (`All  , Some n) }
| n=NUM QUESTION { (`Maybe, Some n) }
;

rwocc:
| LBRACE x=NUM+ RBRACE { x }
;

rwarg:
| SLASHSLASH
    { RWDone false }

| SLASHSLASHEQ
    { RWDone true  }

| SLASHEQ
   { RWSimpl }

| s=rwside r=rwrepeat? o=rwocc? fp=fpattern(form)
    { RWRw (s, r, omap o EcMaps.Sint.of_list, fp) }
;

genpattern:
| o=rwocc? l=sform_h %prec prec_tactic { (omap o EcMaps.Sint.of_list, l) }
;

simplify_arg: 
| DELTA l=qoident* { `Delta l }
| ZETA             { `Zeta }
| IOTA             { `Iota }
| BETA             { `Beta }
| LOGIC            { `Logic }
| MODPATH          { `ModPath }
;

simplify:
| l=simplify_arg+     { l }
| SIMPLIFY            { simplify_red }
| SIMPLIFY l=qoident+ { `Delta l  :: simplify_red  }
| SIMPLIFY DELTA      { `Delta [] :: simplify_red }
;

conseq:
| empty                         { None, None }
| f1=form                       { Some f1, None }
| f1=form LONGARROW             { Some f1, None }
| f1=form LONGARROW UNDERSCORE  { Some f1, None }
| LONGARROW f2=form             { None, Some f2 }
| UNDERSCORE LONGARROW f2=form  { None, Some f2 }
| f1=form LONGARROW f2=form     { Some f1, Some f2 }
;

call_info: 
 | f1=form LONGARROW f2=form             { CI_spec (f1, f2) }
 | f=form                                { CI_inv  f }
 | bad=form COMMA p=form                 { CI_upto (bad,p,None) }
 | bad=form COMMA p=form COMMA q=form    { CI_upto (bad,p,Some q) }

tac_dir: 
| BACKS { Backs }
| FWDS  { Fwds }
| empty { Backs }
;

codepos:
| i=NUM  { (i, None) }
| c=CPOS { c }
;

code_position:
| n=number { Single n }
| n1=number n2=number { Double (n1, n2) } 
;

while_tac_info : 
| inv=sform
    { (inv, None, None) }
| inv=sform vrnt=sform 
    { (inv, Some vrnt, None) }
| inv=sform vrnt=sform bd=sform n_iter=sform
    { (inv, Some vrnt, Some (bd, n_iter)) }

rnd_info:
| e1=sform e2=sform 
    { Some e1, Some e2 }
| e=sform UNDERSCORE 
    { Some e, None }
| UNDERSCORE e=sform 
    { None, Some e }
| empty
    {None, None }
;

swap_info:
| s=side? p=swap_pos { s,p }
;

swap_pos:
| i1=number i2=number i3=number
    { SKbase (i1, i2, i3) }

| p=int
    { SKmove p }

| i1=number p=int
    { SKmovei (i1, p) }

| LBRACKET i1=number DOTDOT i2=number RBRACKET p=int
    { SKmoveinter (i1, i2, p) }
;

int:
| n=number { n }
| loc(MINUS) n=number { -n }
;

side:
| LBRACE n=number RBRACE {
   match n with
   | 1 -> true
   | 2 -> false
   | _ -> error
              (EcLocation.make $startpos $endpos)
              (Some "variable side must be 1 or 2")
 }
;

occurences:
| p=paren(NUM+) {
    if List.mem 0 p then
      error
        (EcLocation.make $startpos $endpos)
        (Some "`0' is not a valid occurence");
    p
  }
;

app_bd_info:
  | empty { PAppNone }
  | f=sform { PAppSingle f }
  | f1=sform f2=sform g1=sform g2=sform { PAppMult (f1,f2,g1,g2) }

logtactic:
| ASSUMPTION
    { Passumption (None, None) }

| ASSUMPTION p=qident tvi=tvars_app?
   { Passumption (Some p, tvi) } 

| GENERALIZE l=genpattern+
   { Pgeneralize l } 

| CLEAR l=ident+
   { Pclear l }

| CONGR
   { Pcongr }

| TRIVIAL
   { Ptrivial }

| SMT pi=prover_info
   { Psmt pi }

| INTROS a=intro_pattern*
   { Pintro a }

| SPLIT
    { Psplit }

| FIELD plus=sform times=sform inv=sform minus=sform z=sform o=sform eq=sform
    { Pfield (plus,times,inv,minus,z,o,eq)}

| FIELDSIMP plus=sform times=sform inv=sform minus=sform z=sform o=sform  eq=sform
    { Pfieldsimp (plus,times,inv,minus,z,o,eq)}

| EXIST a=plist1(loc(fpattern_arg), COMMA)
   { Pexists a }

| LEFT
    { Pleft }

| RIGHT
    { Pright }

| ELIM e=fpattern(form)
   { Pelim e }

| ELIMT p=qident f=sform
   { PelimT (f, p) }

| APPLY e=fpattern(form)
   { Papply e }

| l=simplify
   { Psimplify (mk_simplify l) }

| CHANGE f=sform
   { Pchange f }

| REWRITE a=rwarg+
   { Prewrite a }

| SUBST l=sform*
   { Psubst l }

| CUT ip=intro_pattern COLON p=form %prec prec_below_IMPL
   { Pcut (ip, p, None) }

| CUT ip=intro_pattern COLON p=form BY t=tactic_core
   { Pcut (ip, p, Some t) }

| POSE o=rwocc? x=lident CEQ p=form_h %prec prec_below_IMPL
   { Ppose (x, omap o EcMaps.Sint.of_list, p) }
;

phltactic:
| FUN
    { Pfun_def }

| FUN f=sform
    { Pfun_abs f }

| FUN bad=sform p=sform q=sform? 
    { Pfun_upto(bad, p, q) }

| SEQ d=tac_dir pos=code_position COLON p=sform f=app_bd_info
   { Papp (d, pos, p, f) }

| WP n=code_position?
   { Pwp n }

| SKIP
    { Pskip }

| WHILE s=side? info=while_tac_info
    { Pwhile (s,info) }

| CALL s=side? info=fpattern(call_info) 
    { Pcall (s, info) }

| RCONDT s=side? i=number
    { Prcond (s, true, i) }

| RCONDF s=side? i=number 
    { Prcond (s, false, i) }

| IF s=side?
    { Pcond s }

| SWAP info=plist1(loc(swap_info),COMMA)
    { Pswap info }

| CFOLD s=side? c=codepos NOT n=NUM
    { Pcfold (s, c, Some n) }

| CFOLD s=side? c=codepos
    { Pcfold (s, c, None) }

| RND s=side? info=rnd_info
    { Prnd (s, info) }

| INLINE s=side? o=occurences? f=plist0(loc(fident), empty)
    { Pinline (`ByName (s, (f, o))) }

| KILL s=side? o=codepos 
    { Pkill (s, o, Some 1) }

| KILL s=side? o=codepos NOT n=NUM
    { Pkill (s, o, Some n) }

| KILL s=side? o=codepos NOT STAR
    { Pkill (s, o, None) }

| p=tselect INLINE
    { Pinline (`ByPattern p) }

| ALIAS s=side? o=codepos
    { Palias (s, o, None) }

| ALIAS s=side? o=codepos WITH x=lident
    { Palias (s, o, Some x) }

| FISSION s=side? o=codepos AT d1=NUM COMMA d2=NUM
    { Pfission (s, o, (1, (d1, d2))) }

| FISSION s=side? o=codepos NOT i=NUM AT d1=NUM COMMA d2=NUM
    { Pfission (s, o, (i, (d1, d2))) }

| FUSION s=side? o=codepos AT d1=NUM COMMA d2=NUM
    { Pfusion (s, o, (1, (d1, d2))) }

| FUSION s=side? o=codepos NOT i=NUM AT d1=NUM COMMA d2=NUM
    { Pfusion (s, o, (i, (d1, d2))) }

| UNROLL s=side? o=codepos
    { Punroll (s, o) }

| SPLITWHILE c=expr COLON s=side? o=codepos
    { Psplitwhile (c, s, o) }

| EQUIVDENO info=fpattern(conseq)
    { Pequivdeno info }

| BDHOAREDENO info=fpattern(conseq)
    { Pbdhoaredeno info }

| CONSEQ info=fpattern(conseq)
    { Pconseq info }

| EXFALSO
    { Pexfalso }

| BYPR f1=sform f2=sform { PPr(f1,f2) }

| FEL at_pos=NUM cntr=sform delta=sform q=sform f_event=sform some_p=sform
   {Pfel (at_pos,(cntr,delta,q,f_event,some_p))}
| EQOBSIN f1=sform f2=sform f3=sform {Peqobs_in (f1,f2,f3) }
(* basic pr based tacs *)
| HOARE {Phoare}
| BDHOARE {Pbdhoare}
| PRBOUNDED {Pprbounded}
| PROR {Ppror}
| PRFALSE {Pprfalse}
| BDEQ {Pbdeq}
;

tactic_core_r:
| IDTAC
   { Pidtac None }

| IDTAC s=STRING
   { Pidtac (Some s) }

| TRY t=tactic_core
   { Ptry t }

| BY t=tactics
   { Pby t }

| DO t=tactic_core
   { Pdo ((`All, None), t) }

| DO n=NUM? NOT t=tactic_core
   { Pdo ((`All, n), t) }

| DO n=NUM? QUESTION t=tactic_core
   { Pdo ((`Maybe, n), t) }

| LPAREN s=tactics RPAREN
   { Pseq s } 

| ADMIT
   { Padmit }

| CASE f=sform
   { Pcase f }

| PROGRESS t=tactic_core?
   { Pprogress t }

| x=logtactic
   { Plogic x }

| x=phltactic
   { PPhl x }

(* DEBUG *)
| DEBUG
    { Pdebug }
;

%inline tactic_core:
| x=loc(tactic_core_r) { x }
;

tactic:
| t=tactic_core
    { mk_core_tactic t }

| t=tactic_core IMPL ip=intro_pattern+
    { { pt_core = t; pt_intros = ip; } }
;

tactic_chain:
| LBRACKET ts=plist1(loc(tactics0), PIPE) RBRACKET
    { Psubtacs (List.map mk_core_tactic ts) }

| FIRST t=loc(tactics) { Pfirst (mk_core_tactic (mk_loc t.pl_loc (Pseq (unloc t))), 1) }
| LAST  t=loc(tactics) { Plast  (mk_core_tactic (mk_loc t.pl_loc (Pseq (unloc t))), 1) }

| FIRST n=NUM t=loc(tactics) { Pfirst (mk_core_tactic (mk_loc t.pl_loc (Pseq (unloc t))), n) }
| LAST  n=NUM t=loc(tactics) { Plast  (mk_core_tactic (mk_loc t.pl_loc (Pseq (unloc t))), n) }

| FIRST LAST  { Protate (`Left , 1) }
| LAST  FIRST { Protate (`Right, 1) }

| FIRST n=NUM LAST  { Protate (`Left , n) }
| LAST  n=NUM FIRST { Protate (`Right, n) }

;

subtactic:
| t=loc(tactic_chain)
    { mk_core_tactic (mk_loc t.pl_loc (Psubgoal (unloc t))) }

| t=tactic
    { t }
;

subtactics:
| t=subtactic { [t] }
| ts=subtactics SEMICOLON t=subtactic { t :: ts }
;

tactics:
| t=tactic %prec SEMICOLON { [t] }
| t=tactic SEMICOLON ts=subtactics { t :: (List.rev ts) }
;

tactics0:
| ts=tactics   { Pseq ts } 
| x=loc(empty) { Pseq [mk_core_tactic (mk_loc x.pl_loc (Pidtac None))] }

tactics_or_prf:
| t=tactics    { `Actual t    }
| PROOF        { `Proof false }
| PROOF STRICT { `Proof true  }
;

(* -------------------------------------------------------------------- *)
(* Theory cloning                                                       *)

theory_clone:
| CLONE ip=import_flag? x=uqident cw=clone_with?
   { let oth =
       { pthc_base = x;
         pthc_name = None;
         pthc_ext  = EcUtils.odfl [] cw; }
     in
       (oth, ip) }

| CLONE ip=import_flag? x=uqident AS y=uident cw=clone_with?
   { let oth =
       { pthc_base = x;
         pthc_name = Some y;
         pthc_ext  = EcUtils.odfl [] cw; }
     in
       (oth, ip) }
;

clone_with:
| WITH x=plist1(clone_override, COMMA) { x }
;

clone_override:
| TYPE ps=typarams x=qident EQ t=loc(type_exp)
   { (x, PTHO_Type (ps, t, `Alias)) }

| TYPE ps=typarams x=qident LEFTARROW t=loc(type_exp)
   { (x, PTHO_Type (ps, t, `Inline)) }

| OP x=qoident tyvars=tyvars_decl COLON sty=loc(type_exp) EQ e=expr
   { let ov = {
       opov_tyvars = tyvars;
       opov_args   = [];
       opov_retty  = sty;
       opov_body   = e;
     } in
       (x, PTHO_Op ov) }

| OP x=qoident tyvars=tyvars_decl eq=loc(EQ) e=expr
   { let ov = {
       opov_tyvars = tyvars;
       opov_args   = [];
       opov_retty  = mk_loc eq.pl_loc PTunivar;
       opov_body   = e;
     } in
       (x, PTHO_Op ov) }

| OP x=qoident tyvars=tyvars_decl p=ptybindings eq=loc(EQ) e=expr
   { let ov = {
       opov_tyvars = tyvars;
       opov_args   = p;
       opov_retty  = mk_loc eq.pl_loc PTunivar;
       opov_body   = e;
     } in
       (x, PTHO_Op ov) }

| PRED x=qoident tyvars=tyvars_decl p=ptybindings EQ f=form
   { let ov = {
       prov_tyvars = tyvars;
       prov_args   = p;
       prov_body   = f;
     } in
       (x, PTHO_Pred ov) }

| PRED x=qoident tyvars=tyvars_decl EQ f=form
   { let ov = {
       prov_tyvars = tyvars;
       prov_args   = [];
       prov_body   = f;
     } in
       (x, PTHO_Pred ov) }
;

(* -------------------------------------------------------------------- *)
(* Printing                                                             *)
print:
| TYPE   qs=qident { Pr_ty qs }
| OP     qs=qident { Pr_op qs }
| THEORY qs=qident { Pr_th qs }
| PRED   qs=qident { Pr_pr qs } 
| AXIOM  qs=qident { Pr_ax qs }
;

prover_iconfig:
| /* empty */   { (None   , None   ) }
| i=NUM         { (Some i , None   ) }
| i1=NUM i2=NUM { (Some i1, Some i2) }
;

prover_info:
| ic=prover_iconfig pl=plist1(loc(STRING), empty)? 
    { let (m, t) = ic in
        { pprov_max   = m;
          pprov_time  = t;
          pprov_names = pl; } }
;

gprover_info: 
| PROVER x=prover_info { x }
| TIMEOUT t=NUM        
    { { pprov_max = None; pprov_time = Some t; pprov_names = None } }
;

checkproof:
| CHECKPROOF ON  { true }
| CHECKPROOF OFF { false }
;

(* -------------------------------------------------------------------- *)
(* Global entries                                                       *)

global_:
| theory_open      { GthOpen      $1 }
| theory_close     { GthClose     $1 }
| theory_require   { GthRequire   $1 }
| theory_import    { GthImport    $1 }
| theory_export    { GthExport    $1 }
| theory_clone     { GthClone     $1 }
| theory_w3        { GthW3        $1 }
| section_open     { GsctOpen        }
| section_close    { GsctClose       }
| top_mod_def      { Gmodule      $1 }
| sig_def          { Ginterface   $1 }
| type_decl_or_def { Gtype        $1 }
| datatype_def     { Gdatatype    $1 }
| operator         { Goperator    $1 }
| predicate        { Gpredicate   $1 }
| axiom            { Gaxiom       $1 }
| claim            { Gclaim       $1 }
| tactics_or_prf   { Gtactics     $1 }
| gprover_info     { Gprover_info $1 }
| checkproof       { Gcheckproof  $1 }

| x=loc(SAVE)      { Gsave x.pl_loc }
| x=loc(QED)       { Gsave x.pl_loc }
| PRINT p=print    { Gprint     p   }
| PRAGMA x=lident  { Gpragma    x   }
;

stop:
| EOF { }
| DROP DOT { }
;

global:
| g=loc(global_) FINAL { g }
;

prog:
| g=global { P_Prog ([g], false) }
| stop     { P_Prog ([ ], true ) }

| UNDO d=number FINAL
   { P_Undo d }

| error
   { error (EcLocation.make $startpos $endpos) None }
;

(* -------------------------------------------------------------------- *)
%inline plist0(X, S):
| aout=separated_list(S, X) { aout }
;

%inline plist1(X, S):
| aout=separated_nonempty_list(S, X) { aout }
;

%inline plist2(X, S):
| x=X S xs=plist1(X, S) { x :: xs }
;

%inline list2(X):
| x=X xs=X+ { x :: xs }
;

%inline empty:
| /**/ { () }
;

(* -------------------------------------------------------------------- *)
__rlist1(X, S):                         (* left-recursive *)
| x=X { [x] }
| xs=__rlist1(X, S) S x=X { x :: xs }
;

%inline rlist0(X, S):
| /* empty */     { [] }
| xs=rlist1(X, S) { xs }
;

%inline rlist1(X, S):
| xs=__rlist1(X, S) { List.rev xs }
;

(* -------------------------------------------------------------------- *)
%inline paren(X):
| LPAREN x=X RPAREN { x }
;

%inline brace(X):
| LBRACE x=X RBRACE { x }
;

(* -------------------------------------------------------------------- *)
%inline loc(X):
| x=X {
    { pl_desc = x;
      pl_loc  = EcLocation.make $startpos $endpos;
    }
  }
;
