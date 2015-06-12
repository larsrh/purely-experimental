theory Splice
imports Main Typed_Evaluation
begin

datatype 'a res = Exn string | Res 'a

typed_evaluation splice_term = \<open>term\<close>
typed_evaluation splice_thm = \<open>thm\<close>

ML_file "splice.ML"

syntax
  "_cartouche_splice" :: "cartouche_position \<Rightarrow> 'a"  ("SPLICE _")
  "_cartouche_splice_res" :: "cartouche_position \<Rightarrow> 'a"  ("SPLICE* _")

parse_translation
  \<open>[(@{syntax_const "_cartouche_splice"}, Splice.term_translation false),
    (@{syntax_const "_cartouche_splice_res"}, Splice.term_translation true)]\<close>

attribute_setup splice = \<open>Scan.lift Args.cartouche_input >> Splice.thm_attribute\<close>

end