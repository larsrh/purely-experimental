theory Unicode
imports Main
begin

datatype ustring = Ustring (dest_Ustring: "nat list list")

syntax
  "_ustring" :: "cartouche_position \<Rightarrow> ustring" ("ustr _")

ML_file "unicode.ML"

parse_translation \<open>[(@{syntax_const "_ustring"}, K Unicode.parse_translation)]\<close>
print_translation \<open>[(@{const_syntax Ustring}, K Unicode.print_translation)]\<close>

end