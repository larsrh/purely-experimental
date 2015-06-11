theory Examples
  imports Typed_Evaluation Main
begin

typed_evaluation data = \<open>int\<close>

ML\<open>val x = 1\<close>

ML\<open>Typed_Evaluation.eval_exn @{token "Examples.data"} \<open>1 + error "abc"\<close> @{context}\<close>
ML\<open>Typed_Evaluation.eval @{token "Examples.data"} \<open>1 + error "abc"\<close> @{context}\<close>
ML\<open>Typed_Evaluation.eval @{token data} \<open>1 + x\<close> @{context}\<close>

ML\<open>@{token data}\<close>

locale f
begin

  typed_evaluation data = \<open>int list\<close>

  ML\<open>Typed_Evaluation.eval @{token data} \<open>[1]\<close> @{context}\<close>
  ML\<open>Typed_Evaluation.eval @{token "Examples.data"} \<open>[1]\<close> @{context}\<close>
  ML\<open>Typed_Evaluation.eval @{token "Examples.data"} \<open>1\<close> @{context}\<close>

end

ML\<open>Typed_Evaluation.eval @{token data} \<open>1\<close> @{context}\<close>


end