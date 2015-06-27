signature UNICODE = sig
  val parse_translation: Proof.context -> term list -> term
end

structure Unicode: UNICODE = struct

fun parse_translation _ args =
  let
    fun err () = raise TERM ("Unicode.input_translation", args)
    fun input s pos =
      let
        val content = Symbol_Pos.cartouche_content (Symbol_Pos.explode (s, pos))
        val (text, _) = Symbol_Pos.implode_range (Symbol_Pos.range content) content
      in
        text
      end
    fun mk_codepoint r [] = r
      | mk_codepoint r (c :: cs) = mk_codepoint (r * 256 + ord c) cs
    val eval =
      Symbol.explode
      #> map (HOLogic.mk_number @{typ nat} o mk_codepoint 0 o raw_explode)
      #> HOLogic.mk_list @{typ nat}
  in
    case args of
      [(c as Const (@{syntax_const "_constrain"}, _)) $ Free (s, _) $ p] =>
        (case Term_Position.decode_position p of
          SOME (pos, _) => c $ (@{const Ustring} $ eval (input s pos)) $ p
        | NONE => err ())
    | _ => err ()
  end

end