//! This module implements the backing representation of runtime
//! values in the Nix language.
use std::fmt::Display;
use std::rc::Rc;

mod attrs;
mod list;
mod string;

use crate::errors::{Error, EvalResult};
pub use attrs::NixAttrs;
pub use list::NixList;
pub use string::NixString;

#[derive(Clone, Debug)]
pub enum Value {
    Null,
    Bool(bool),
    Integer(i64),
    Float(f64),
    String(NixString),
    Attrs(Rc<NixAttrs>),
    List(NixList),

    // Internal values that, while they technically exist at runtime,
    // are never returned to or created directly by users.
    AttrPath(Vec<NixString>),
    Blackhole,
}

impl Value {
    pub fn is_number(&self) -> bool {
        match self {
            Value::Integer(_) => true,
            Value::Float(_) => true,
            _ => false,
        }
    }

    pub fn type_of(&self) -> &'static str {
        match self {
            Value::Null => "null",
            Value::Bool(_) => "bool",
            Value::Integer(_) => "int",
            Value::Float(_) => "float",
            Value::String(_) => "string",
            Value::Attrs(_) => "set",
            Value::List(_) => "list",

            // Internal types
            Value::AttrPath(_) | Value::Blackhole => "internal",
        }
    }

    pub fn as_bool(self) -> EvalResult<bool> {
        match self {
            Value::Bool(b) => Ok(b),
            other => Err(Error::TypeError {
                expected: "bool",
                actual: other.type_of(),
            }),
        }
    }

    pub fn as_string(self) -> EvalResult<NixString> {
        match self {
            Value::String(s) => Ok(s),
            other => Err(Error::TypeError {
                expected: "string",
                actual: other.type_of(),
            }),
        }
    }

    pub fn as_attrs(self) -> EvalResult<Rc<NixAttrs>> {
        match self {
            Value::Attrs(s) => Ok(s),
            other => Err(Error::TypeError {
                expected: "set",
                actual: other.type_of(),
            }),
        }
    }
}

impl Display for Value {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Value::Null => f.write_str("null"),
            Value::Bool(true) => f.write_str("true"),
            Value::Bool(false) => f.write_str("false"),
            Value::Integer(num) => f.write_fmt(format_args!("{}", num)),
            Value::String(s) => s.fmt(f),
            Value::Attrs(attrs) => attrs.fmt(f),
            Value::List(list) => list.fmt(f),

            // Nix prints floats with a maximum precision of 5 digits
            // only.
            Value::Float(num) => f.write_fmt(format_args!(
                "{}",
                format!("{:.5}", num).trim_end_matches(['.', '0'])
            )),

            // internal types
            Value::AttrPath(_) | Value::Blackhole => f.write_str("internal"),
        }
    }
}

impl PartialEq for Value {
    fn eq(&self, other: &Self) -> bool {
        match (self, other) {
            // Trivial comparisons
            (Value::Null, Value::Null) => true,
            (Value::Bool(b1), Value::Bool(b2)) => b1 == b2,
            (Value::List(l1), Value::List(l2)) => l1 == l2,
            (Value::String(s1), Value::String(s2)) => s1 == s2,

            // Numerical comparisons (they work between float & int)
            (Value::Integer(i1), Value::Integer(i2)) => i1 == i2,
            (Value::Integer(i), Value::Float(f)) => *i as f64 == *f,
            (Value::Float(f1), Value::Float(f2)) => f1 == f2,
            (Value::Float(f), Value::Integer(i)) => *i as f64 == *f,

            // Optimised attribute set comparison
            (Value::Attrs(a1), Value::Attrs(a2)) => Rc::ptr_eq(a1, a2) || { a1 == a2 },

            // Everything else is either incomparable (e.g. internal
            // types) or false.
            _ => false,
        }
    }
}
