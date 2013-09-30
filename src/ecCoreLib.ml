(* -------------------------------------------------------------------- *)
let s_get  = "_.[_]"
let s_set  = "_.[_<-_]"
let s_nil  = "[]"
let s_cons = "_::_"
let s_abs  = "`|_|"

(* -------------------------------------------------------------------- *)
let mixfix_ops = [s_get; s_set; s_nil; s_cons; s_abs]

let is_mixfix_op op =
  List.mem op mixfix_ops

(* -------------------------------------------------------------------- *)
let s_dbool      = (["<top>"; "Bool" ; "Dbool"     ], "dbool")
let s_dbitstring = (["<top>"; "Distr"; "Dbitstring"], "dbitstring")
let s_dinter     = (["<top>"; "Distr"; "Dinter"    ], "dinter")
let s_from_int   = (["<top>"; "Real" ; "FromInt"   ], "from_int")
let s_fset       = (["<top>"; "FSet" ], "set")

(* -------------------------------------------------------------------- *)
let id_top       = "<top>"
let id_Pervasive = "Pervasive"
let id_unit      = "unit"
let id_tt        = "tt"
let id_bool      = "bool"
let id_int       = "int"
let id_real      = "real"
let id_distr     = "distr"
let id_cpred     = "cpred"
let id_from_int  = "from_int"

let id_true      = "true"
let id_false     = "false"
let id_not       = "!"
let id_and       = "/\\"
let id_anda      = "&&"
let id_ora       = "||"
let id_or        = "\\/"
let id_imp       = "=>"
let id_iff       = "<=>"
let id_eq        = "="

let id_le        = "<="
let id_lt        = "<"
let id_ge        = ">="

let id_add         = "+"
let id_sub         = "-"
let id_opp         = "[-]"
let id_prod        = "*"
let id_div         = "/"
let id_pow         = "^"

let id_in_supp   = "in_supp"
let id_mu        = "mu"
let id_mu_x      = "mu_x"
let id_weight    = "weight"

let p_top         = EcPath.psymbol id_top
let p_Pervasive   = EcPath.pqname p_top id_Pervasive
let _Pervasive id = EcPath.pqname p_Pervasive id

let p_unit       = _Pervasive id_unit
let p_tt         = _Pervasive id_tt
let p_bool       = _Pervasive id_bool
let p_int        = _Pervasive id_int
let p_real       = _Pervasive id_real
let p_distr      = _Pervasive id_distr
let p_cpred      = _Pervasive id_cpred
let p_fset       = EcPath.fromqsymbol s_fset
let p_from_int   = EcPath.fromqsymbol s_from_int

let p_true       = _Pervasive id_true
let p_false      = _Pervasive id_false
let p_not        = _Pervasive id_not
let p_anda       = _Pervasive id_anda 
let p_and        = _Pervasive id_and
let p_ora        = _Pervasive id_ora
let p_or         = _Pervasive id_or
let p_imp        = _Pervasive id_imp
let p_iff        = _Pervasive id_iff
let p_eq         = _Pervasive id_eq

let id_Int       = "Int"
let p_Int        = EcPath.pqname p_top id_Int 
let _Int id      = EcPath.pqname p_Int id

let p_int_le     = _Int  id_le
let p_int_lt     = _Int  id_lt

let p_int_opp    = _Int id_opp
let p_int_add    = _Int id_add
let p_int_sub    = _Int id_sub
let p_int_prod   = _Int id_prod
let p_int_pow    = _Int id_pow   

let p_int_intval = EcPath.fromqsymbol (["<top>"; "Sum"], "intval" )
let p_int_sum    = EcPath.fromqsymbol (["<top>"; "Sum"], "int_sum")

let id_Real      = "Real"
let p_Real       = EcPath.pqname p_top id_Real
let _Real id     = EcPath.pqname p_Real id

let p_real_le    = _Real id_le
let p_real_lt    = _Real id_lt
let p_real_ge    = _Real id_ge
let p_real_add    = _Real id_add
let p_real_sub    = _Real id_sub
let p_real_prod   = _Real id_prod
let p_real_div    = _Real id_div   

let id_Distr     = "Distr"
let p_Distr      = EcPath.pqname p_top id_Distr
let _Distr id    = EcPath.pqname p_Distr id

let p_in_supp    = _Distr id_in_supp
let p_mu         = _Pervasive id_mu
let p_mu_x       = _Distr id_mu_x
let p_weight     = _Distr id_weight

let p_Logic         = EcPath.pqname p_top "Logic" 
let _Logic    id    = EcPath.pqname p_Logic id

let p_cut_lemma     = _Logic "cut_lemma"
let p_false_elim    = _Logic "falseE"
let p_and_elim      = _Logic "andE"
let p_anda_elim     = _Logic "andaE"
let p_and_proj_l    = _Logic "andEl"
let p_and_proj_r    = _Logic "andEr"
let p_or_elim       = _Logic "orE"
let p_ora_elim      = _Logic "oraE"
let p_iff_elim      = _Logic "iffE"
let p_if_elim       = _Logic "ifE"

let p_true_intro    = _Logic "trueI"
let p_and_intro     = _Logic "andI"
let p_anda_intro    = _Logic "andaI"
let p_or_intro_l    = _Logic "orIl"
let p_ora_intro_l   = _Logic "oraIl"
let p_or_intro_r    = _Logic "orIr"
let p_ora_intro_r   = _Logic "oraIr"
let p_iff_intro     = _Logic "iffI"
let p_if_intro      = _Logic "ifI"
let p_eq_refl       = _Logic "eq_refl"
let p_eq_trans      = _Logic "eq_trans"
let p_fcongr        = _Logic "fcongr"

let p_rewrite_l     = _Logic "rewrite_l"
let p_rewrite_r     = _Logic "rewrite_r"
let p_rewrite_iff_l = _Logic "rewrite_iff_l"
let p_rewrite_iff_r = _Logic "rewrite_iff_r"
let p_rewrite_bool  = _Logic "rewrite_bool"

let p_case_eq_bool  = _Logic "bool_case_eq"

let p_tuple_ind n = 
  if 2 <= n && n <= 9 then
    let name = Format.sprintf "tuple%i_ind" n in
    _Logic name
  else raise Not_found
