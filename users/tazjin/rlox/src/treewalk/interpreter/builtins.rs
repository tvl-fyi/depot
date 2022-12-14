use std::fmt;
use std::time::{SystemTime, UNIX_EPOCH};

use crate::treewalk::errors::Error;
use crate::treewalk::interpreter::Value;
use crate::treewalk::parser::Literal;

pub trait Builtin: fmt::Debug {
    fn arity(&self) -> usize;
    fn call(&self, args: Vec<Value>) -> Result<Value, Error>;
}

// Builtin to return the current timestamp.
#[derive(Debug)]
pub struct Clock {}
impl Builtin for Clock {
    fn arity(&self) -> usize {
        0
    }

    fn call(&self, _args: Vec<Value>) -> Result<Value, Error> {
        let now = SystemTime::now().duration_since(UNIX_EPOCH).unwrap();
        Ok(Value::Literal(Literal::Number(now.as_secs() as f64)))
    }
}
