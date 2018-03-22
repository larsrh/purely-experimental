theory Typed_Evaluation_Examples
imports Typed_Evaluation
begin

typed_evaluation data = \<open>int\<close>

ML\<open>val x = 1\<close>

ML\<open>
  Typed_Evaluation.eval_exn @{token data} \<open>1 + error "abc"\<close> @{context};

  val res = Typed_Evaluation.eval @{token data} \<open>1 + x\<close> @{context};
  @{assert} (res = 2);

  val res = Exn.capture (Typed_Evaluation.eval @{token data} \<open>1 + error "abc"\<close>) @{context};
  @{assert} (is_some (Exn.get_exn res))
\<close>

ML\<open>@{token data}\<close>

locale f
begin

typed_evaluation data = \<open>int list\<close>

ML\<open>
  Typed_Evaluation.eval @{token data} \<open>[1]\<close> @{context};

  Typed_Evaluation.eval @{token Typed_Evaluation_Examples.data} \<open>1\<close> @{context};

  val res = Exn.capture (Typed_Evaluation.eval @{token Typed_Evaluation_Examples.data} \<open>[1]\<close>) @{context};
  @{assert} (is_some (Exn.get_exn res))
\<close>

end

context f begin
ML_val \<open>@{token "data"}\<close>
end

ML\<open>Typed_Evaluation.eval @{token data} \<open>1\<close> @{context}\<close>

end