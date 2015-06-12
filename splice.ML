signature SPLICE = sig
  val eval_term: Input.source -> Proof.context -> term
  val eval_term_res: Input.source -> Proof.context -> term
  val term_translation: bool -> Proof.context -> term list -> term

  val eval_thm: Input.source -> Proof.context -> thm
  val thm_attribute: Input.source -> Thm.attribute
end

structure Splice: SPLICE = struct

val eval_term = Typed_Evaluation.eval @{token splice_term}
val eval_thm = Typed_Evaluation.eval @{token splice_thm}

fun eval_term_res ctxt source =
  case Typed_Evaluation.eval_exn @{token splice_term} ctxt source of
    Exn.Res t =>
      Const (@{const_name Splice.Res}, dummyT) $ t
  | Exn.Exn exn =>
      Const (@{const_name Splice.Exn}, dummyT) $
        HOLogic.mk_string (YXML.content_of (@{make_string} exn))

fun term_translation res ctxt args =
  let
    fun err () = raise TERM ("Splice.term_translation", args)
    fun input s pos =
      let
        val content = Symbol_Pos.cartouche_content (Symbol_Pos.explode (s, pos))
        val (text, range) = Symbol_Pos.implode_range (Symbol_Pos.range content) content
      in
        Input.source true text range
      end
    val eval = if res then eval_term_res else eval_term
  in
    case args of
      [(c as Const (@{syntax_const "_constrain"}, _)) $ Free (s, _) $ p] =>
        (case Term_Position.decode_position p of
          SOME (pos, _) => c $ eval (input s pos) ctxt $ p
        | NONE => err ())
    | _ => err ()
  end

fun thm_attribute input =
  Thm.rule_attribute (fn context => K (eval_thm input (Context.proof_of context)))

end