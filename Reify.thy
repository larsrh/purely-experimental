theory Reify
imports Main
begin

ML_file "flags.ML"
ML_file "reify.ML"

setup "Reify.setup"

ML\<open>
val x = @{term 0};

@{reify [schematic] \<open>0 + ?x\<close>};
\<close>

end