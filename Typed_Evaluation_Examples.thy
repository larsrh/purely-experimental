theory Typed_Evaluation_Examples
imports Typed_Evaluation
begin

typed_evaluation data = \<open>int\<close>

ML\<open>val x = 1\<close>

ML\<open>Typed_Evaluation.eval_exn @{token data} \<open>1 + error "abc"\<close> @{context}\<close>
ML\<open>Typed_Evaluation.eval @{token data} \<open>1 + error "abc"\<close> @{context}\<close>
ML\<open>Typed_Evaluation.eval @{token data} \<open>1 + x\<close> @{context}\<close>

ML\<open>@{token data}\<close>

locale f
begin

  typed_evaluation data = \<open>int list\<close>

  ML\<open>Typed_Evaluation.eval @{token data} \<open>[1]\<close> @{context}\<close>
  ML\<open>Typed_Evaluation.eval @{token Typed_Evaluation_Examples.data} \<open>[1]\<close> @{context}\<close>
  ML\<open>Typed_Evaluation.eval @{token Typed_Evaluation_Examples.data} \<open>1\<close> @{context}\<close>

end

context f begin
ML_val \<open>@{token "data"}\<close>
end

ML\<open>Typed_Evaluation.eval @{token data} \<open>1\<close> @{context}\<close>


end