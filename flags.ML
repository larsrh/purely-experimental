signature FLAG_ARGS = sig
  type T
  val from_string: string -> T option
  val empty: T
  val merge: T -> T -> T
end

signature FLAGS = sig
  type T
  val parse: T parser
end

functor Flags(Args: FLAG_ARGS): FLAGS = struct

type T = Args.T

val parse =
  let
    val parse1: T parser =
      Parse.text :|-- (fn str => case Args.from_string str of
        NONE => Scan.fail_with (K (K ("Unknown flag " ^ str)))
      | SOME t => Scan.succeed t)
    fun merge ts =
      fold Args.merge ts Args.empty
  in
    Scan.optional (@{keyword "["} |-- Parse.list1 parse1 --| @{keyword "]"}) [] >> merge
  end

end