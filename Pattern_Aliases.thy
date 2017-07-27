theory Pattern_Aliases
imports Main
begin

consts as :: "'a \<Rightarrow> 'a \<Rightarrow> 'a"

ML\<open>
local

fun let_typ a b = a --> (a --> b) --> b

fun strip_all t =
  case try Logic.dest_all t of
    NONE => ([], t)
  | SOME (var, t) => apfst (cons var) (strip_all t)

fun all_Frees t =
  fold_aterms (fn Free (x, t) => insert op = (x, t) | _ => I) t []

in

(* doesn't check that defined constant doesn't occur to the left of =: *)
(* doesn't check linearity *)

fun check_pattern_syntax t =
  case strip_all t of
    (vars, @{const Trueprop} $ (Const (@{const_name HOL.eq}, _) $ lhs $ rhs)) =>
      let
        fun go (Const (@{const_name as}, _) $ var $ pat, rhs) =
              let
                val (pat', rhs') = go (pat, rhs)
                val _ = if is_Free var then () else error "no can do"
                val rhs'' =
                  Const (@{const_name Let}, let_typ (fastype_of var) (fastype_of rhs)) $
                    pat' $ lambda var rhs'
              in
                (pat', rhs'')
              end
          | go (t $ u, rhs) =
              let
                val (t', rhs') = go (t, rhs)
                val (u', rhs'') = go (u, rhs')
              in (t' $ u', rhs'') end
          | go (t, rhs) = (t, rhs)

        val (lhs', rhs') = go (lhs, rhs)

        val res = HOLogic.mk_Trueprop (HOLogic.mk_eq (lhs', rhs'))

        val frees = filter (member op = vars) (all_Frees res)
      in fold (fn v => Logic.dependent_all_name ("", v)) (map Free frees) res end
  | _ => t

end
\<close>

bundle pattern_syntax begin

  notation as (infixr "=:" 65)

  declaration \<open>K (Syntax_Phases.term_check 98 "pattern_syntax" (K (map check_pattern_syntax)))\<close>

end

hide_const (open) as

context includes pattern_syntax begin

term "\<And>x y ys. bla (x =: (y # ys)) = x @ x"

fun bla where
"bla [] = []" |
"bla (x =: (y # (x' =: (y' # ys)))) = x @ x'"

thm bla.simps[unfolded Let_def]

end

end