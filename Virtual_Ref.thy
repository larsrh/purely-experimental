theory Virtual_Ref
  imports Pure
begin


ML\<open>
signature VIRTUAL_REF_STORE = sig
  type T
  val new: unit -> T
  val store: T -> exn -> unit
  val retrieve: T -> exn
end

signature VIRTUAL_REF = sig
  type 'a ref
  val vref: 'a -> 'a ref
  val := : ('a ref * 'a) -> unit
  val ! : 'a ref -> 'a
end

functor Virtual_Ref(Store: VIRTUAL_REF_STORE) :> VIRTUAL_REF = struct

abstype 'a ref = Token of Store.T * ('a -> exn) * (exn -> 'a) with

fun vref init =
  let
    val t = Store.new ()
    exception A of 'a
    val () = Store.store t (A init)
  in Token (t, A, fn A a => a) end

fun ! (Token (t, _, g)) = g (Store.retrieve t)

fun op := (Token (t, f, _), a) = Store.store t (f a)

val _ =
  ML_system_pp (fn _ => fn _ => fn Token _ => Pretty.to_polyml (Pretty.str "<vref>"))

end

end

structure Theory_Virtual_Ref_Store: VIRTUAL_REF_STORE = struct
  structure Data = Theory_Data
  (
    type T = exn Inttab.table
    val empty = Inttab.empty
    val merge = Inttab.merge (K false)
    val extend = I
  )

  type T = int
  val new = serial
  fun retrieve n = the (Inttab.lookup (Data.get (Context.the_global_context ())) n)
  fun store n exn = Theory.setup (Data.map (Inttab.update (n, exn)))
end

structure Theory_Virtual_Ref = Virtual_Ref(Theory_Virtual_Ref_Store)
open Theory_Virtual_Ref
\<close>

ML\<open>
val r1 = vref 1;
\<close>

ML\<open>r1 := (! r1 + 1)\<close>

ML\<open>! r1\<close>


end