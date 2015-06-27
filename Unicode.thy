theory Unicode
imports Main
begin

datatype ustring = Ustring "nat list"

syntax
  "_string" :: "cartouche_position \<Rightarrow> ustring" ("ustr _")

ML_file "unicode.ML"

parse_translation \<open>[(@{syntax_const "_string"}, Unicode.parse_translation)]\<close>

end