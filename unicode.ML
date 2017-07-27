signature UNICODE = sig
  val parse_translation: term list -> term
  val print_translation: term list -> term
end

structure Unicode: UNICODE = struct

fun parse_translation args =
  let
    fun err () = raise TERM ("Unicode.parse_translation", args)
    fun input s pos =
      let
        val content = Symbol_Pos.cartouche_content (Symbol_Pos.explode (s, pos))
        val (text, _) = Symbol_Pos.implode_range (Symbol_Pos.range content) content
      in
        text
      end
    val eval =
      Symbol.explode
      #> map raw_explode
      #> map (map (HOLogic.mk_number @{typ nat} o ord))
      #> map (HOLogic.mk_list @{typ nat})
      #> HOLogic.mk_list @{typ "nat list"}
  in
    case args of
      [(c as Const (@{syntax_const "_constrain"}, _)) $ Free (s, _) $ p] =>
        (case Term_Position.decode_position p of
          SOME (pos, _) => c $ (@{const Ustring} $ eval (input s pos)) $ p
        | NONE => err ())
    | _ => err ()
  end

fun print_translation args =
  let
    (* dest_num copied from Num.thy *)
    fun dest_num (Const (@{const_syntax Num.Bit0}, _) $ n) = 2 * dest_num n
      | dest_num (Const (@{const_syntax Num.Bit1}, _) $ n) = 2 * dest_num n + 1
      | dest_num (Const (@{const_syntax Num.One}, _)) = 1
    fun from_num (Const (@{const_syntax numeral}, _) $ t) = dest_num t
    fun dest_list (Const (@{const_syntax List.Nil}, _)) = []
      | dest_list (Const (@{const_syntax List.Cons}, _) $ t $ ts) = t :: dest_list ts
    fun chr' 92 = "\\\\" (* Backspace *)
      | chr' 127 = "\\127" (* DEL *)
      | chr' x = if x <= 31 then "\\0" ^ Value.print_int x else chr x (* Lower ASCII block *)
    val splice =
      dest_list
      #> map dest_list
      #> map (map (chr' o from_num))
      #> map implode
      #> implode
  in
    case args of
      [c] => Syntax.const @{syntax_const "_ustring"} $ Syntax.free ("\<open>" ^ splice c ^ "\<close>")
  end

end
