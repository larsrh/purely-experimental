signature REIFY = sig
  type flags = {schematic: bool, check: bool, typ: bool}

  val print_typ: bool -> typ -> string
  val print_term: bool -> term -> string

  val print: Proof.context -> flags -> string -> string

  val setup: theory -> theory
end

structure Reify: REIFY = struct

type flags = {schematic: bool, check: bool, typ: bool}

structure Flags = Flags
(
  type T = flags
  fun from_string "schematic" = SOME {schematic = true,  check = false, typ = false}
    | from_string "check"     = SOME {schematic = false, check = true,  typ = false}
    | from_string "typ"       = SOME {schematic = false, check = false, typ = true}
    | from_string _           = NONE
  val empty = {schematic = false, check = false, typ = false}
  fun merge {schematic = s1, check = c1, typ = t1} {schematic = s2, check = c2, typ = t2} =
    {schematic = s1 orelse s2, check = c1 orelse c2, typ = t1 orelse t2}
)

local
  open ML_Syntax
in

fun print_typ s (Type arg) = "Term.Type " ^ print_pair print_string (print_list (print_typ s)) arg
  | print_typ _ (TFree arg) = "Term.TFree " ^ print_pair print_string print_sort arg
  | print_typ false (TVar _) = error "unexpected schematic variable"
  | print_typ true (TVar ((name, _), _)) = name

fun print_term s (Const arg) = "Term.Const " ^ print_pair print_string (print_typ s) arg
  | print_term s (Free arg) = "Term.Free " ^ print_pair print_string (print_typ s) arg
  | print_term _ (Bound i) = "Term.Bound " ^ print_int i
  | print_term s (t $ u) = "Term.$ " ^ print_pair (print_term s) (print_term s) (t, u)
  | print_term s (Abs (name, typ, t)) = "Term.Abs (" ^ print_string name ^ ", " ^ print_typ s typ ^ ", " ^ print_term s t ^ ")"
  | print_term false (Var _) = error "unexpected schematic variable"
  | print_term true (Var ((name, _), _)) = name

end

fun print ctxt {schematic, check, typ} s =
  let
    val ctxt = if schematic then Proof_Context.set_mode Proof_Context.mode_schematic ctxt else ctxt
  in
    if typ then
      s
    else
      let
        val t = Syntax.parse_term ctxt s
        val t' = (if check then Syntax.check_term ctxt t else t)
      in
        print_term schematic t'
      end
  end

val setup =
  ML_Antiquotation.inline @{binding reify}
    (Args.context -- Scan.lift (Flags.parse -- Parse.inner_syntax Parse.cartouche) >>
      (fn (ctxt, (flags, s)) => print ctxt flags s))

end