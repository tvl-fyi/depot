use crate::errors::{report, Error, ErrorKind};
use crate::parser::{self, Expr, Literal};
use crate::scanner::{self, Token, TokenKind};

// Run some Lox code and print it to stdout
pub fn run(code: &str) {
    let chars: Vec<char> = code.chars().collect();

    match scanner::scan(&chars) {
        Ok(tokens) => {
            print_tokens(&tokens);
            match parser::parse(tokens) {
                Ok(expr) => {
                    println!("Expression:\n{:?}", expr);
                    println!("Result: {:?}", eval(&expr));
                }
                Err(errors) => report_errors(errors),
            }
        }
        Err(errors) => report_errors(errors),
    }
}

fn print_tokens<'a>(tokens: &Vec<Token<'a>>) {
    println!("Tokens:");
    for token in tokens {
        println!("{:?}", token);
    }
}

fn report_errors(errors: Vec<Error>) {
    for error in errors {
        report(&error);
    }
}

// Tree-walk interpreter

fn eval_truthy(lit: &Literal) -> bool {
    match lit {
        Literal::Nil => false,
        Literal::Boolean(b) => *b,
        _ => true,
    }
}

fn eval_unary<'a>(expr: &parser::Unary<'a>) -> Result<Literal, Error> {
    let right = eval(&*expr.right)?;

    match (&expr.operator.kind, right) {
        (TokenKind::Minus, Literal::Number(num)) => Ok(Literal::Number(-num)),
        (TokenKind::Bang, right) => Ok(Literal::Boolean(!eval_truthy(&right))),

        (op, right) => Err(Error {
            line: expr.operator.line,
            kind: ErrorKind::TypeError(format!(
                "Operator '{:?}' can not be called with argument '{:?}'",
                op, right
            )),
        }),
    }
}

fn eval_binary<'a>(expr: &parser::Binary<'a>) -> Result<Literal, Error> {
    let left = eval(&*expr.left)?;
    let right = eval(&*expr.right)?;

    let result = match (&expr.operator.kind, left, right) {
        // Numeric
        (TokenKind::Minus, Literal::Number(l), Literal::Number(r)) => Literal::Number(l - r),
        (TokenKind::Slash, Literal::Number(l), Literal::Number(r)) => Literal::Number(l / r),
        (TokenKind::Star, Literal::Number(l), Literal::Number(r)) => Literal::Number(l * r),
        (TokenKind::Plus, Literal::Number(l), Literal::Number(r)) => Literal::Number(l + r),

        // Strings
        (TokenKind::Plus, Literal::String(l), Literal::String(r)) => {
            Literal::String(format!("{}{}", l, r))
        }

        // Comparators (on numbers only?)
        (TokenKind::Greater, Literal::Number(l), Literal::Number(r)) => Literal::Boolean(l > r),
        (TokenKind::GreaterEqual, Literal::Number(l), Literal::Number(r)) => {
            Literal::Boolean(l >= r)
        }
        (TokenKind::Less, Literal::Number(l), Literal::Number(r)) => Literal::Boolean(l < r),
        (TokenKind::LessEqual, Literal::Number(l), Literal::Number(r)) => Literal::Boolean(l <= r),

        // Equality
        (TokenKind::Equal, l, r) => Literal::Boolean(l == r),
        (TokenKind::BangEqual, l, r) => Literal::Boolean(l != r),

        (op, left, right) => {
            return Err(Error {
                line: expr.operator.line,
                kind: ErrorKind::TypeError(format!(
                    "Operator '{:?}' can not be called with arguments '({:?}, {:?})'",
                    op, left, right
                )),
            })
        }
    };

    Ok(result)
}

fn eval<'a>(expr: &Expr<'a>) -> Result<Literal, Error> {
    match expr {
        Expr::Literal(lit) => Ok(lit.clone()),
        Expr::Grouping(grouping) => eval(&*grouping.0),
        Expr::Unary(unary) => eval_unary(unary),
        Expr::Binary(binary) => eval_binary(binary),
    }
}
