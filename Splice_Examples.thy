theory Splice_Examples
imports Main Splice
begin


ML \<open>
  val ctxt = @{context};
  val input = \<open>\<lambda>x. x + y + SPLICE \<open>Bound 0\<close>\<close>;

  val t = Syntax.read_term ctxt (Syntax.implode_input input);
\<close>


term "SPLICE \<open>@{const Nil(int)}\<close>"
term "(\<lambda>x. SPLICE \<open>Bound 0\<close>)"

term "SPLICE \<open>@{const zero_nat_inst.zero_nat}\<close> + SPLICE \<open>@{const zero_nat_inst.zero_nat}\<close>"

ML\<open>val mythm = @{thm conjI[where P = True]}\<close>

lemmas mythm = [[splice \<open>mythm\<close>]]

lemma "0 < SPLICE \<open>HOLogic.mk_number @{typ nat} (1+1)\<close>"
oops

notepad
begin

  fix x
  assume x

  (* doesn't work, bad name *)
  have "SPLICE \<open>@{term x}\<close>"

end

ML\<open>@{term "SPLICE \<open>@{term x}\<close>"}\<close>

ML\<open>@{make_string} (Exn.capture the NONE)\<close>

ML\<open>val tt = @{const Nil(int)};\<close>

term "SPLICE \<open>tt\<close>"

term "SPLICE* \<open>the NONE\<close>"
term "(\<lambda>x. SPLICE* \<open>Bound 0\<close>)"
term "SPLICE* \<open>Exn.interrupt ()\<close>"

term "SPLICE \<open>0\<close>"

end