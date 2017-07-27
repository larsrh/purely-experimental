theory Graph
imports Main
begin

definition "graph f = (\<lambda>x y. y = f x)"

ML\<open>val graph_plugin = Plugin_Name.declare_setup @{binding graph}\<close>

setup \<open>
  BNF_FP_Def_Sugar.fp_sugars_interpretation
    graph_plugin
    (fn list => (@{print} list; I))
\<close>

ML\<open>
fun TRY' tac = tac ORELSE' (K all_tac)

fun graph_tac' typ ctxt =
  let
    val {fp_co_induct_sugar, fp_bnf_sugar, fp_bnf, ...} = the (BNF_FP_Def_Sugar.fp_sugar_of ctxt typ)
    val {rel_co_inducts = [induct], ...} = the fp_co_induct_sugar
  in
    resolve_tac ctxt @{thms ext} THEN'
      resolve_tac ctxt @{thms ext} THEN'
      resolve_tac ctxt @{thms iffI} THEN'
      (eresolve_tac ctxt [induct] THEN_ALL_NEW
        (SELECT_GOAL (Local_Defs.unfold_tac ctxt (@{thm graph_def} :: #map_thms fp_bnf_sugar)) THEN'
          TRY' (hyp_subst_tac_thin true ctxt) THEN'
          resolve_tac ctxt @{thms refl})) THEN'
      SELECT_GOAL (Local_Defs.unfold_tac ctxt @{thms graph_def}) THEN'
      hyp_subst_tac_thin true ctxt THEN'
      SELECT_GOAL (Local_Defs.unfold_tac ctxt (BNF_Def.rel_map_of_bnf fp_bnf)) THEN'
      (resolve_tac ctxt [BNF_Def.rel_refl_of_bnf fp_bnf] THEN_ALL_NEW
        resolve_tac ctxt @{thms refl})
  end
\<close>


lemma "rel_sum (graph f) (graph g) = graph (map_sum f g)"
by (tactic \<open>graph_tac' @{type_name sum} @{context} 1\<close>)

lemma graph_map: "list_all2 (graph f) = graph (map f)"
by (tactic \<open>graph_tac' @{type_name list} @{context} 1\<close>)

end