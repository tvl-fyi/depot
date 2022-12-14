(*
  Rewriting the Python implementation of the register VM in OCaml to see how
  how much imperative/mutative programming OCaml allows.

  Note: Some of this code is intentionally not written in a functional style
  because one of the goals was to see how similar this OCaml implementation
  could be to the Python implementation.

  Conclusion: It's pretty easy to switch between the two languages.

  Usage: Recommended compilation settings I hastily found online:
  $ ocamlopt -w +A-42-48 -warn-error +A-3-44 ./register_vm.ml && ./a.out

  Formatting:
  $ ocamlformat --inplace --enable-outside-detected-project ./register_vm.ml
 *)

open Vec

type reg = X | Y | Res
type binop = int -> int -> int

type ast =
  | Const of int
  | Add of ast * ast
  | Sub of ast * ast
  | Mul of ast * ast
  | Div of ast * ast

type opcode0 =
  | Op0AssignRegLit of reg * int
  | Op0AssignRegReg of reg * reg
  | Op0BinOp of binop * reg * reg * reg
  | Op0PushReg of reg
  | Op0PopAndSet of reg
  | Op0Null

type opcode1 =
  | Op1AssignRegLit of int * int
  | Op1AssignRegReg of int * int
  | Op1BinOp of (int -> int -> int) * int * int * int
  | Op1PushReg of int
  | Op1PopAndSet of int
  | Op1Null

type opcodes0 = opcode0 vec
type opcodes1 = opcode1 vec

let registers : int vec = Vec.make 8 0
let stack : int Stack.t = Stack.create ()
let reg_idx (r : reg) : int = match r with X -> 0 | Y -> 1 | Res -> 2

let reg_name (r : reg) : string =
  match r with X -> "x" | Y -> "y" | Res -> "res"

let print_opcodes0 (xs : opcodes0) : opcodes0 =
  let print_opcode x =
    match x with
    | Op0AssignRegLit (r, x) -> Printf.printf "%s <- %d\n" (reg_name r) x
    | Op0AssignRegReg (dst, src) ->
        Printf.printf "%s <- $%s\n" (reg_name dst) (reg_name src)
    | Op0PushReg src -> Printf.printf "push $%s\n" (reg_name src)
    | Op0PopAndSet dst -> Printf.printf "%s <- pop\n" (reg_name dst)
    | Op0BinOp (_, lhs, rhs, dst) ->
        Printf.printf "%s <- $%s ? $%s\n" (reg_name dst) (reg_name lhs)
          (reg_name rhs)
    | Op0Null -> ()
  in
  Vec.iter print_opcode xs;
  xs

let rec compile (ast : ast) : opcodes0 =
  let result : opcodes0 = Vec.create () in
  (match ast with
   | Const x -> Vec.append (Op0AssignRegLit (Res, x)) result;
   | Add (lhs, rhs) -> compile_bin_op ( + ) lhs rhs result
   | Sub (lhs, rhs) -> compile_bin_op ( - ) lhs rhs result
   | Mul (lhs, rhs) -> compile_bin_op ( * ) lhs rhs result
   | Div (lhs, rhs) -> compile_bin_op ( / ) lhs rhs result);
  result

and compile_bin_op (f : binop) (lhs : ast) (rhs : ast) (result : opcodes0) =
  lhs |> compile |> Vec.append_to result;
  Vec.append (Op0PushReg Res) result;
  rhs |> compile |> Vec.append_to result;
  Vec.append (Op0PopAndSet X) result;
  Vec.append (Op0AssignRegReg (Y, Res)) result;
  Vec.append (Op0BinOp (f, X, Y, Res)) result

let compile_registers (xs : opcodes0) : opcodes1 =
  let do_compile x =
    match x with
    | Op0AssignRegLit (dst, x) -> Op1AssignRegLit (reg_idx dst, x)
    | Op0AssignRegReg (dst, src) -> Op1AssignRegReg (reg_idx dst, reg_idx src)
    | Op0PushReg src -> Op1PushReg (reg_idx src)
    | Op0PopAndSet dst -> Op1PopAndSet (reg_idx dst)
    | Op0BinOp (f, lhs, rhs, dst) -> Op1BinOp (f, reg_idx lhs, reg_idx rhs, reg_idx dst)
    | Op0Null -> Op1Null
  in
  Vec.map do_compile xs

let eval (xs : opcodes1) : int =
  let ip = ref 0 in
  while !ip < Vec.length xs do
    match Vec.get_unsafe !ip xs with
    | Op1AssignRegLit (dst, x) ->
        Vec.set dst x registers;
        ip := !ip + 1
    | Op1AssignRegReg (dst, src) ->
        Vec.set dst (Vec.get_unsafe src registers) registers;
        ip := !ip + 1
    | Op1PushReg src ->
        Stack.push (Vec.get_unsafe src registers) stack;
        ip := !ip + 1
    | Op1PopAndSet dst ->
        Vec.set dst (Stack.pop stack) registers;
        ip := !ip + 1
    | Op1BinOp (f, lhs, rhs, dst) ->
        let lhs = Vec.get_unsafe lhs registers in
        let rhs = Vec.get_unsafe rhs registers in
        Vec.set dst (f lhs rhs) registers;
        ip := !ip + 1
    | Op1Null -> ip := !ip + 1
  done;
  Vec.get_unsafe (reg_idx Res) registers
;;

Add (Mul (Const 2, Div (Const 100, Const 2)), Const 5)
|> compile |> print_opcodes0 |> compile_registers |> eval |> print_int
