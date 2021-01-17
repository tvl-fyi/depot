//! Bytecode interpreter for Lox.
//!
//! https://craftinginterpreters.com/chunks-of-bytecode.html

mod chunk;
mod opcode;
mod value;

use chunk::Chunk;
use opcode::OpCode;

pub fn main() {
    let mut chunk: Chunk = Default::default();

    let constant = chunk.add_constant(1.2);
    chunk.add_op(OpCode::OpConstant(constant), 1);
    chunk.add_op(OpCode::OpReturn, 1);

    chunk::disassemble(&chunk, "test chunk");
}
