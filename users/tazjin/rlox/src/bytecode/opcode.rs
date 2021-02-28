#[derive(Debug)]
pub enum OpCode {
    /// Push a constant onto the stack.
    OpConstant(usize),

    // Literal pushes
    OpNil,
    OpTrue,
    OpFalse,

    /// Return from the current function.
    OpReturn,

    /// Unary negation
    OpNegate,

    // Arithmetic operators
    OpAdd,
    OpSubtract,
    OpMultiply,
    OpDivide,
}
