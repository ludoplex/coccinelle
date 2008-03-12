(* exports everything, used only by parser_cocci_menhir.mly *)
module Ast0 = Ast0_cocci
module Ast = Ast_cocci

(* types for metavariable tokens *)
type info = Ast.meta_name * Ast0.pure * Data.clt
type idinfo = Ast.meta_name * Data.iconstraints * Ast0.pure * Data.clt
type expinfo = Ast.meta_name * Data.econstraints * Ast0.pure * Data.clt
type tyinfo = Ast.meta_name * Ast0.typeC list * Ast0.pure * Data.clt
type list_info = Ast.meta_name * Ast.meta_name option * Ast0.pure * Data.clt
type typed_info =
    Ast.meta_name * Data.econstraints * Ast0.pure *
      Type_cocci.typeC list option * Data.clt
type pos_info = Ast.meta_name * Data.pconstraints * Data.clt


let get_option fn = function
    None -> None
  | Some x -> Some (fn x)

let make_info line logical_line offset col strbef straft =
  { Ast0.line_start = line; Ast0.line_end = line;
    Ast0.logical_start = logical_line; Ast0.logical_end = logical_line;
    Ast0.attachable_start = true; Ast0.attachable_end = true;
    Ast0.mcode_start = []; Ast0.mcode_end = [];
    Ast0.column = col; Ast0.offset = offset;
    Ast0.strings_before = strbef; Ast0.strings_after = straft; }

let clt2info (_,line,logical_line,offset,col,strbef,straft,pos) =
  make_info line logical_line offset col strbef straft

let drop_bef (arity,line,lline,offset,col,strbef,straft,pos) =
  (arity,line,lline,offset,col,[],straft,pos)

let drop_aft (arity,line,lline,offset,col,strbef,straft,pos) =
  (arity,line,lline,offset,col,strbef,[],pos)

let clt2mcode str = function
    (Data.MINUS,line,lline,offset,col,strbef,straft,pos)       ->
      (str,Ast0.NONE,make_info line lline offset col strbef straft,
       Ast0.MINUS(ref([],Ast0.default_token_info)),ref pos)
  | (Data.OPTMINUS,line,lline,offset,col,strbef,straft,pos)    ->
      (str,Ast0.OPT,make_info line lline offset col strbef straft,
       Ast0.MINUS(ref([],Ast0.default_token_info)),ref pos)
  | (Data.UNIQUEMINUS,line,lline,offset,col,strbef,straft,pos) ->
      (str,Ast0.UNIQUE,make_info line lline offset col strbef straft,
       Ast0.MINUS(ref([],Ast0.default_token_info)),ref pos)
  | (Data.PLUS,line,lline,offset,col,strbef,straft,pos)        ->
      (str,Ast0.NONE,make_info line lline offset col strbef straft,Ast0.PLUS,
       ref pos)
  | (Data.CONTEXT,line,lline,offset,col,strbef,straft,pos)     ->
      (str,Ast0.NONE,make_info line lline offset col strbef straft,
       Ast0.CONTEXT(ref(Ast.NOTHING,
			Ast0.default_token_info,Ast0.default_token_info)),
       ref pos)
  | (Data.OPT,line,lline,offset,col,strbef,straft,pos)         ->
      (str,Ast0.OPT,make_info line lline offset col strbef straft,
       Ast0.CONTEXT(ref(Ast.NOTHING,
			Ast0.default_token_info,Ast0.default_token_info)),
       ref pos)
  | (Data.UNIQUE,line,lline,offset,col,strbef,straft,pos)      ->
      (str,Ast0.UNIQUE,make_info line lline offset col strbef straft,
       Ast0.CONTEXT(ref(Ast.NOTHING,
			Ast0.default_token_info,Ast0.default_token_info)),
       ref pos)

let id2name   (name, clt) = name
let id2clt    (name, clt) = clt
let id2mcode  (name, clt) = clt2mcode name clt

let mkdots str (dot,whencode) =
  match str with
    "..." -> Ast0.wrap(Ast0.Dots(clt2mcode str dot, whencode))
  | "ooo" -> Ast0.wrap(Ast0.Circles(clt2mcode str dot, whencode))
  | "***" -> Ast0.wrap(Ast0.Stars(clt2mcode str dot, whencode))
  | _ -> failwith "cannot happen"

let mkedots str (dot,whencode) =
  match str with
    "..." -> Ast0.wrap(Ast0.Edots(clt2mcode str dot, whencode))
  | "ooo" -> Ast0.wrap(Ast0.Ecircles(clt2mcode str dot, whencode))
  | "***" -> Ast0.wrap(Ast0.Estars(clt2mcode str dot, whencode))
  | _ -> failwith "cannot happen"

let mkdpdots str dot =
  match str with
    "..." -> Ast0.wrap(Ast0.DPdots(clt2mcode str dot))
  | "ooo" -> Ast0.wrap(Ast0.DPcircles(clt2mcode str dot))
  | _ -> failwith "cannot happen"

let mkidots str (dot,whencode) =
  match str with
    "..." -> Ast0.wrap(Ast0.Idots(clt2mcode str dot, whencode))
  | _ -> failwith "cannot happen"

let mkddots str (dot,whencode) =
  match (str,whencode) with
    ("...",None) -> Ast0.wrap(Ast0.Ddots(clt2mcode str dot, None))
  | ("...",Some [w]) -> Ast0.wrap(Ast0.Ddots(clt2mcode str dot, Some w))
  | _ -> failwith "cannot happen"

let mkpdots str dot =
  match str with
    "..." -> Ast0.wrap(Ast0.Pdots(clt2mcode str dot))
  | "ooo" -> Ast0.wrap(Ast0.Pcircles(clt2mcode str dot))
  | _ -> failwith "cannot happen"

let arith_op ast_op left op right =
  Ast0.wrap
    (Ast0.Binary(left, clt2mcode (Ast.Arith ast_op) op, right))

let logic_op ast_op left op right =
  Ast0.wrap
    (Ast0.Binary(left, clt2mcode (Ast.Logical ast_op) op, right))

let make_cv cv ty =
  match cv with None -> ty | Some x -> Ast0.wrap (Ast0.ConstVol(x,ty))

let top_dots l =
  let circle x =
    match Ast0.unwrap x with Ast0.Circles(_) -> true | _ -> false in
  let star x =
    match Ast0.unwrap x with Ast0.Stars(_) -> true | _ -> false in
  if List.exists circle l
  then Ast0.wrap(Ast0.CIRCLES(l))
  else
    if List.exists star l
    then Ast0.wrap(Ast0.STARS(l))
    else Ast0.wrap(Ast0.DOTS(l))

(* here the offset is that of the first in the sequence of *s, not that of
each * individually *)
let pointerify ty m =
  List.fold_left
    (function inner ->
      function cur ->
	Ast0.wrap(Ast0.Pointer(inner,clt2mcode "*" cur)))
    ty m

let ty_pointerify ty m =
  List.fold_left
    (function inner -> function cur -> Type_cocci.Pointer(inner))
    ty m

(* Left is <=>, Right is =>.  Collect <=>s. *)
(* The parser should have done this, with precedences.  But whatever... *)
let iso_adjust fn first rest =
  let rec loop = function
      [] -> [[]]
    | (Common.Left x)::rest ->
	(match loop rest with
	  front::after -> (fn x::front)::after
	| _ -> failwith "not possible")
    | (Common.Right x)::rest ->
	(match loop rest with
	  front::after -> []::(fn x::front)::after
	| _ -> failwith "not possible") in
  match loop rest with
    front::after -> (fn first::front)::after
  | _ -> failwith "not possible"

let check_meta tok =
  let lookup rule name =
    try
      let info = Hashtbl.find Data.all_metadecls rule in
      List.find (function mv -> Ast.get_meta_name mv = (rule,name)) info
    with
      Not_found ->
	raise
	  (Semantic_cocci.Semantic
	     ("bad rule "^rule^" or bad variable "^name)) in
  match tok with
    Ast.MetaIdDecl(Ast.NONE,(rule,name)) ->
      (match lookup rule name with
	Ast.MetaIdDecl(_,_) | Ast.MetaFreshIdDecl(_,_) -> ()
      | _ ->
	  raise
	    (Semantic_cocci.Semantic
	       ("incompatible inheritance declaration "^name)))
  | Ast.MetaFreshIdDecl(Ast.NONE,(rule,name)) ->
      raise
	(Semantic_cocci.Semantic
	   "can't inherit the freshness of an identifier")
  | Ast.MetaListlenDecl((rule,name)) ->
      (match lookup rule name with
	Ast.MetaListlenDecl(_) -> ()
      | _ ->
	  raise
	    (Semantic_cocci.Semantic
	       ("incompatible inheritance declaration "^name)))
  | Ast.MetaTypeDecl(Ast.NONE,(rule,name)) ->
      (match lookup rule name with
	Ast.MetaTypeDecl(_,_) -> ()
      | _ ->
	  raise
	    (Semantic_cocci.Semantic
	       ("incompatible inheritance declaration "^name)))
  | Ast.MetaParamDecl(Ast.NONE,(rule,name)) ->
      (match lookup rule name with
	Ast.MetaParamDecl(_,_) -> ()
      | _ ->
	  raise
	    (Semantic_cocci.Semantic
	       ("incompatible inheritance declaration "^name)))
  | Ast.MetaParamListDecl(Ast.NONE,(rule,name),len_name) ->
      (match lookup rule name with
	Ast.MetaParamListDecl(_,_,_) -> ()
      | _ ->
	  raise
	    (Semantic_cocci.Semantic
	       ("incompatible inheritance declaration "^name)))
  | Ast.MetaErrDecl(Ast.NONE,(rule,name)) ->
      (match lookup rule name with
	Ast.MetaErrDecl(_,_) -> ()
      | _ ->
	  raise
	    (Semantic_cocci.Semantic
	       ("incompatible inheritance declaration "^name)))
  | Ast.MetaExpDecl(Ast.NONE,(rule,name),ty) ->
      (match lookup rule name with
	Ast.MetaExpDecl(_,_,ty1) when ty = ty1 -> ()
      | _ ->
	  raise
	    (Semantic_cocci.Semantic
	       ("incompatible inheritance declaration "^name)))
  | Ast.MetaIdExpDecl(Ast.NONE,(rule,name),ty) ->
      (match lookup rule name with
	Ast.MetaIdExpDecl(_,_,ty1) when ty = ty1 -> ()
      | _ ->
	  raise
	    (Semantic_cocci.Semantic
	       ("incompatible inheritance declaration "^name)))
  | Ast.MetaExpListDecl(Ast.NONE,(rule,name),len_name) ->
      (match lookup rule name with
	Ast.MetaExpListDecl(_,_,_) -> ()
      | _ ->
	  raise
	    (Semantic_cocci.Semantic
	       ("incompatible inheritance declaration "^name)))
  | Ast.MetaStmDecl(Ast.NONE,(rule,name)) ->
      (match lookup rule name with
	Ast.MetaStmDecl(_,_) -> ()
      | _ ->
	  raise
	    (Semantic_cocci.Semantic
	       ("incompatible inheritance declaration "^name)))
  | Ast.MetaStmListDecl(Ast.NONE,(rule,name)) ->
      (match lookup rule name with
	Ast.MetaStmListDecl(_,_) -> ()
      | _ ->
	  raise
	    (Semantic_cocci.Semantic
	       ("incompatible inheritance declaration "^name)))
  | Ast.MetaFuncDecl(Ast.NONE,(rule,name)) ->
      (match lookup rule name with
	Ast.MetaFuncDecl(_,_) -> ()
      | _ ->
	  raise
	    (Semantic_cocci.Semantic
	       ("incompatible inheritance declaration "^name)))
  | Ast.MetaLocalFuncDecl(Ast.NONE,(rule,name)) ->
      (match lookup rule name with
	Ast.MetaLocalFuncDecl(_,_) -> ()
      | _ ->
	  raise
	    (Semantic_cocci.Semantic
	       ("incompatible inheritance declaration "^name)))
  | Ast.MetaConstDecl(Ast.NONE,(rule,name),ty) ->
      (match lookup rule name with
	Ast.MetaConstDecl(_,_,ty1) when ty = ty1 -> ()
      | _ ->
	  raise
	    (Semantic_cocci.Semantic
	       ("incompatible inheritance declaration "^name)))
  | Ast.MetaPosDecl(Ast.NONE,(rule,name)) ->
      (match lookup rule name with
	Ast.MetaPosDecl(_,_) ->
	  if not (List.mem rule !Data.inheritable_positions)
	  then
	    raise
	      (Semantic_cocci.Semantic
		 ("position cannot be inherited over modifications: "^name))
      | _ ->
	  raise
	    (Semantic_cocci.Semantic
	       ("incompatible inheritance declaration "^name)))
  | _ ->
      raise
	(Semantic_cocci.Semantic ("arity not allowed on imported declaration"))

let create_metadec ar ispure kindfn ids current_rule =
  List.concat
    (List.map
       (function (rule,nm) ->
	 let (rule,checker) =
	   match rule with
	     None -> ((current_rule,nm),function x -> [Common.Left x])
	   | Some rule ->
	       ((rule,nm),
		function x -> check_meta x; [Common.Right x]) in
	 kindfn ar rule ispure checker)
       ids)

let create_metadec_ne ar ispure kindfn ids current_rule =
  List.concat
    (List.map
       (function ((rule,nm),constraints) ->
	 let (rule,checker) =
	   match rule with
	     None -> ((current_rule,nm),function x -> [Common.Left x])
	   | Some rule ->
	       ((rule,nm),
		function x -> check_meta x; [Common.Right x]) in
	 kindfn ar rule ispure checker constraints)
       ids)

let create_metadec_ty ar ispure kindfn ids current_rule =
  List.concat
    (List.map
       (function ((rule,nm),constraints) ->
	 let (rule,checker) =
	   match rule with
	     None -> ((current_rule,nm),function x -> [Common.Left x])
	   | Some rule ->
	       ((rule,nm),
		function x -> check_meta x; [Common.Right x]) in
	 kindfn ar rule ispure checker constraints)
       ids)

let create_len_metadec ar ispure kindfn lenid ids current_rule =
  let lendec =
    create_metadec Ast.NONE Ast0.Impure
      (fun _ name _ check_meta -> check_meta(Ast.MetaListlenDecl(name)))
      [lenid] current_rule in
  let lenname =
    match lendec with
      [Common.Left (Ast.MetaListlenDecl(x))] -> x
    | [Common.Right (Ast.MetaListlenDecl(x))] -> x
    | _ -> failwith "unexpected length declaration" in
  lendec@(create_metadec ar ispure (kindfn lenname) ids current_rule)

(* ---------------------------------------------------------------------- *)

let str2inc s =
  let elements = Str.split (Str.regexp "/") s in
  List.map (function "..." -> Ast.IncDots | s -> Ast.IncPath s) elements

(* ---------------------------------------------------------------------- *)
(* statements *)

let meta_stm name =
  let (nm,pure,clt) = name in
  Ast0.wrap(Ast0.MetaStmt(clt2mcode nm clt,pure))

let exp_stm exp pv =
  Ast0.wrap(Ast0.ExprStatement (exp, clt2mcode ";" pv))

let ifthen iff lp tst rp thn =
  let tst = Ast0.set_test_exp tst in
  Ast0.wrap(Ast0.IfThen(clt2mcode "if" iff,
    clt2mcode "(" lp,tst,clt2mcode ")" rp,thn,
    (Ast0.default_info(),Ast0.context_befaft())))

let ifthenelse iff lp tst rp thn e els =
  Ast0.wrap(Ast0.IfThenElse(clt2mcode "if" iff,
    clt2mcode "(" lp,Ast0.set_test_exp tst,clt2mcode ")" rp,thn,
    clt2mcode "else" e,els,
    (Ast0.default_info(),Ast0.context_befaft())))

let forloop fr lp e1 sc1 e2 sc2 e3 rp s =
  Ast0.wrap(Ast0.For(clt2mcode "for" fr,clt2mcode "(" lp,e1,
		     clt2mcode ";" sc1,get_option Ast0.set_test_exp e2,
		     clt2mcode ";" sc2,e3,clt2mcode ")" rp,s,
		     (Ast0.default_info(),Ast0.context_befaft())))

let whileloop w lp e rp s =
  Ast0.wrap(Ast0.While(clt2mcode "while" w,clt2mcode "(" lp,
		       Ast0.set_test_exp e,clt2mcode ")" rp,s,
		       (Ast0.default_info(),Ast0.context_befaft())))

let doloop d s w lp e rp pv =
  Ast0.wrap(Ast0.Do(clt2mcode "do" d,s,clt2mcode "while" w,
		    clt2mcode "(" lp,Ast0.set_test_exp e,clt2mcode ")" rp,
		    clt2mcode ";" pv))

let iterator i lp e rp s =
  Ast0.wrap(Ast0.Iterator(id2mcode i,clt2mcode "(" lp,e,
			  clt2mcode ")" rp,s,
			  (Ast0.default_info(),Ast0.context_befaft())))

let switch s lp e rp lb c rb =
  Ast0.wrap(Ast0.Switch(clt2mcode "switch" s,clt2mcode "(" lp,e,
			clt2mcode ")" rp,clt2mcode "{" lb,
			Ast0.wrap(Ast0.DOTS(c)),clt2mcode "}" rb))

let ret_exp r e pv =
  Ast0.wrap(Ast0.ReturnExpr(clt2mcode "return" r,e,clt2mcode ";" pv))

let ret r pv =
  Ast0.wrap(Ast0.Return(clt2mcode "return" r,clt2mcode ";" pv))

let break b pv =
  Ast0.wrap(Ast0.Break(clt2mcode "break" b,clt2mcode ";" pv))

let cont c pv =
  Ast0.wrap(Ast0.Continue(clt2mcode "continue" c,clt2mcode ";" pv))

let label i dd =
  Ast0.wrap(Ast0.Label(i,clt2mcode ":" dd))

let goto g i pv =
  Ast0.wrap(Ast0.Goto(clt2mcode "goto" g,i,clt2mcode ";" pv))

let seq lb s rb =
  Ast0.wrap(Ast0.Seq(clt2mcode "{" lb,s,clt2mcode "}" rb))

(* ---------------------------------------------------------------------- *)
