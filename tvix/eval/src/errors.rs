use crate::spans::ToSpan;
use crate::value::CoercionKind;
use std::path::PathBuf;
use std::rc::Rc;
use std::sync::Arc;
use std::{fmt::Display, num::ParseIntError};

use codemap::{File, Span};
use codemap_diagnostic::{ColorConfig, Diagnostic, Emitter, Level, SpanLabel, SpanStyle};
use smol_str::SmolStr;

use crate::{SourceCode, Value};

#[derive(Clone, Debug)]
pub enum ErrorKind {
    /// These are user-generated errors through builtins.
    Throw(String),
    Abort(String),
    AssertionFailed,

    DuplicateAttrsKey {
        key: String,
    },

    /// Attempted to specify an invalid key type (e.g. integer) in a
    /// dynamic attribute name.
    InvalidAttributeName(Value),

    AttributeNotFound {
        name: String,
    },

    /// Attempted to index into a list beyond its boundaries.
    IndexOutOfBounds {
        index: i64,
    },

    /// Attempted to call `builtins.tail` on an empty list.
    TailEmptyList,

    TypeError {
        expected: &'static str,
        actual: &'static str,
    },

    Incomparable {
        lhs: &'static str,
        rhs: &'static str,
    },

    /// Resolving a user-supplied path literal failed in some way.
    PathResolution(String),

    /// Dynamic keys are not allowed in some scopes.
    DynamicKeyInScope(&'static str),

    /// Unknown variable in statically known scope.
    UnknownStaticVariable,

    /// Unknown variable in dynamic scope (with, rec, ...).
    UnknownDynamicVariable(String),

    /// User is defining the same variable twice at the same depth.
    VariableAlreadyDefined(Span),

    /// Attempt to call something that is not callable.
    NotCallable(&'static str),

    /// Infinite recursion encountered while forcing thunks.
    InfiniteRecursion,

    ParseErrors(Vec<rnix::parser::ParseError>),

    /// An error occured while forcing a thunk, and needs to be
    /// chained up.
    ThunkForce(Box<Error>),

    /// Given type can't be coerced to a string in the respective context
    NotCoercibleToString {
        from: &'static str,
        kind: CoercionKind,
    },

    /// The given string doesn't represent an absolute path
    NotAnAbsolutePath(PathBuf),

    /// An error occurred when parsing an integer
    ParseIntError(ParseIntError),

    /// A negative integer was used as a value representing length.
    NegativeLength {
        length: i64,
    },

    // Errors specific to nested attribute sets and merges thereof.
    /// Nested attributes can not be merged with an inherited value.
    UnmergeableInherit {
        name: SmolStr,
    },

    /// Nested attributes can not be merged with values that are not
    /// literal attribute sets.
    UnmergeableValue,

    /// Tvix failed to read a file from disk for some reason.
    ReadFileError {
        path: PathBuf,
        error: Rc<std::io::Error>,
    },

    /// Parse errors occured while importing a file.
    ImportParseError {
        path: PathBuf,
        file: Arc<File>,
        errors: Vec<rnix::parser::ParseError>,
    },

    /// Compilation errors occured while importing a file.
    ImportCompilerError {
        path: PathBuf,
        errors: Vec<Error>,
    },

    /// Tvix internal warning for features triggered by users that are
    /// not actually implemented yet, and without which eval can not
    /// proceed.
    NotImplemented(&'static str),
}

impl From<ParseIntError> for ErrorKind {
    fn from(e: ParseIntError) -> Self {
        Self::ParseIntError(e)
    }
}

/// Implementation used if errors occur while forcing thunks (which
/// can potentially be threaded through a few contexts, i.e. nested
/// thunks).
impl From<Error> for ErrorKind {
    fn from(e: Error) -> Self {
        Self::ThunkForce(Box::new(e))
    }
}

#[derive(Clone, Debug)]
pub struct Error {
    pub kind: ErrorKind,
    pub span: Span,
}

impl Display for Error {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        writeln!(f, "{:?}", self.kind)
    }
}

pub type EvalResult<T> = Result<T, Error>;

/// Human-readable names for rnix syntaxes.
fn name_for_syntax(syntax: &rnix::SyntaxKind) -> &'static str {
    match syntax {
        rnix::SyntaxKind::TOKEN_COMMENT => "a comment",
        rnix::SyntaxKind::TOKEN_WHITESPACE => "whitespace",
        rnix::SyntaxKind::TOKEN_ASSERT => "`assert`-keyword",
        rnix::SyntaxKind::TOKEN_ELSE => "`else`-keyword",
        rnix::SyntaxKind::TOKEN_IN => "`in`-keyword",
        rnix::SyntaxKind::TOKEN_IF => "`if`-keyword",
        rnix::SyntaxKind::TOKEN_INHERIT => "`inherit`-keyword",
        rnix::SyntaxKind::TOKEN_LET => "`let`-keyword",
        rnix::SyntaxKind::TOKEN_OR => "`or`-keyword",
        rnix::SyntaxKind::TOKEN_REC => "`rec`-keyword",
        rnix::SyntaxKind::TOKEN_THEN => "`then`-keyword",
        rnix::SyntaxKind::TOKEN_WITH => "`with`-keyword",
        rnix::SyntaxKind::TOKEN_L_BRACE => "{",
        rnix::SyntaxKind::TOKEN_R_BRACE => "}",
        rnix::SyntaxKind::TOKEN_L_BRACK => "[",
        rnix::SyntaxKind::TOKEN_R_BRACK => "]",
        rnix::SyntaxKind::TOKEN_ASSIGN => "=",
        rnix::SyntaxKind::TOKEN_AT => "@",
        rnix::SyntaxKind::TOKEN_COLON => ":",
        rnix::SyntaxKind::TOKEN_COMMA => "`,`",
        rnix::SyntaxKind::TOKEN_DOT => ".",
        rnix::SyntaxKind::TOKEN_ELLIPSIS => "...",
        rnix::SyntaxKind::TOKEN_QUESTION => "?",
        rnix::SyntaxKind::TOKEN_SEMICOLON => ";",
        rnix::SyntaxKind::TOKEN_L_PAREN => "(",
        rnix::SyntaxKind::TOKEN_R_PAREN => ")",
        rnix::SyntaxKind::TOKEN_CONCAT => "++",
        rnix::SyntaxKind::TOKEN_INVERT => "!",
        rnix::SyntaxKind::TOKEN_UPDATE => "//",
        rnix::SyntaxKind::TOKEN_ADD => "+",
        rnix::SyntaxKind::TOKEN_SUB => "-",
        rnix::SyntaxKind::TOKEN_MUL => "*",
        rnix::SyntaxKind::TOKEN_DIV => "/",
        rnix::SyntaxKind::TOKEN_AND_AND => "&&",
        rnix::SyntaxKind::TOKEN_EQUAL => "==",
        rnix::SyntaxKind::TOKEN_IMPLICATION => "->",
        rnix::SyntaxKind::TOKEN_LESS => "<",
        rnix::SyntaxKind::TOKEN_LESS_OR_EQ => "<=",
        rnix::SyntaxKind::TOKEN_MORE => ">",
        rnix::SyntaxKind::TOKEN_MORE_OR_EQ => ">=",
        rnix::SyntaxKind::TOKEN_NOT_EQUAL => "!=",
        rnix::SyntaxKind::TOKEN_OR_OR => "||",
        rnix::SyntaxKind::TOKEN_FLOAT => "a float",
        rnix::SyntaxKind::TOKEN_IDENT => "an identifier",
        rnix::SyntaxKind::TOKEN_INTEGER => "an integer",
        rnix::SyntaxKind::TOKEN_INTERPOL_END => "}",
        rnix::SyntaxKind::TOKEN_INTERPOL_START => "${",
        rnix::SyntaxKind::TOKEN_PATH => "a path",
        rnix::SyntaxKind::TOKEN_URI => "a literal URI",
        rnix::SyntaxKind::TOKEN_STRING_CONTENT => "content of a string",
        rnix::SyntaxKind::TOKEN_STRING_END => "\"",
        rnix::SyntaxKind::TOKEN_STRING_START => "\"",

        rnix::SyntaxKind::NODE_APPLY => "a function application",
        rnix::SyntaxKind::NODE_ASSERT => "an assertion",
        rnix::SyntaxKind::NODE_ATTRPATH => "an attribute path",
        rnix::SyntaxKind::NODE_DYNAMIC => "a dynamic identifier",

        rnix::SyntaxKind::NODE_IDENT => "an identifier",
        rnix::SyntaxKind::NODE_IF_ELSE => "an `if`-expression",
        rnix::SyntaxKind::NODE_SELECT => "a `select`-expression",
        rnix::SyntaxKind::NODE_INHERIT => "inherited values",
        rnix::SyntaxKind::NODE_INHERIT_FROM => "inherited values",
        rnix::SyntaxKind::NODE_STRING => "a string",
        rnix::SyntaxKind::NODE_INTERPOL => "an interpolation",
        rnix::SyntaxKind::NODE_LAMBDA => "a function",
        rnix::SyntaxKind::NODE_IDENT_PARAM => "a function parameter",
        rnix::SyntaxKind::NODE_LEGACY_LET => "a legacy `let`-expression",
        rnix::SyntaxKind::NODE_LET_IN => "a `let`-expression",
        rnix::SyntaxKind::NODE_LIST => "a list",
        rnix::SyntaxKind::NODE_BIN_OP => "a binary operator",
        rnix::SyntaxKind::NODE_PAREN => "a parenthesised expression",
        rnix::SyntaxKind::NODE_PATTERN => "a function argument pattern",
        rnix::SyntaxKind::NODE_PAT_BIND => "an argument pattern binding",
        rnix::SyntaxKind::NODE_PAT_ENTRY => "an argument pattern entry",
        rnix::SyntaxKind::NODE_ROOT => "a Nix expression",
        rnix::SyntaxKind::NODE_ATTR_SET => "an attribute set",
        rnix::SyntaxKind::NODE_ATTRPATH_VALUE => "an attribute set entry",
        rnix::SyntaxKind::NODE_UNARY_OP => "a unary operator",
        rnix::SyntaxKind::NODE_LITERAL => "a literal value",
        rnix::SyntaxKind::NODE_WITH => "a `with`-expression",
        rnix::SyntaxKind::NODE_PATH => "a path",
        rnix::SyntaxKind::NODE_HAS_ATTR => "`?`-operator",

        // TODO(tazjin): unsure what these variants are, lets crash!
        rnix::SyntaxKind::NODE_ERROR => todo!("NODE_ERROR found, tell tazjin!"),
        rnix::SyntaxKind::TOKEN_ERROR => todo!("TOKEN_ERROR found, tell tazjin!"),
        _ => todo!(),
    }
}

/// Construct the string representation for a list of expected parser tokens.
fn expected_syntax(one_of: &[rnix::SyntaxKind]) -> String {
    match one_of.len() {
        0 => "nothing".into(),
        1 => format!("'{}'", name_for_syntax(&one_of[0])),
        _ => {
            let mut out: String = "one of: ".into();
            let end = one_of.len() - 1;

            for (idx, item) in one_of.iter().enumerate() {
                if idx != 0 {
                    out.push_str(", ");
                } else if idx == end {
                    out.push_str(", or ");
                };

                out.push_str(name_for_syntax(item));
            }

            out
        }
    }
}

/// Process a list of parse errors into a set of span labels, annotating parse
/// errors.
fn spans_for_parse_errors(file: &File, errors: &[rnix::parser::ParseError]) -> Vec<SpanLabel> {
    // rnix has a tendency to emit some identical errors more than once, but
    // they do not enhance the user experience necessarily, so we filter them
    // out
    let mut had_eof = false;

    errors
        .iter()
        .enumerate()
        .filter_map(|(idx, err)| {
            let (span, label): (Span, String) = match err {
                rnix::parser::ParseError::Unexpected(range) => (
                    range.span_for(file),
                    "found an unexpected syntax element here".into(),
                ),

                rnix::parser::ParseError::UnexpectedExtra(range) => (
                    range.span_for(file),
                    "found unexpected extra elements at the root of the expression".into(),
                ),

                rnix::parser::ParseError::UnexpectedWanted(found, range, wanted) => {
                    let span = range.span_for(file);
                    (
                        span,
                        format!(
                            "found '{}', but expected {}",
                            name_for_syntax(&found),
                            expected_syntax(&wanted),
                        ),
                    )
                }

                rnix::parser::ParseError::UnexpectedEOF => {
                    if had_eof {
                        return None;
                    }

                    had_eof = true;

                    (
                        file.span,
                        "code ended unexpectedly while the parser still expected more".into(),
                    )
                }

                rnix::parser::ParseError::UnexpectedEOFWanted(wanted) => {
                    had_eof = true;

                    (
                        file.span,
                        format!(
                            "code ended unexpectedly, but wanted {}",
                            expected_syntax(&wanted)
                        ),
                    )
                }

                rnix::parser::ParseError::DuplicatedArgs(range, name) => (
                    range.span_for(file),
                    format!(
                        "the function argument pattern '{}' was bound more than once",
                        name
                    ),
                ),

                rnix::parser::ParseError::RecursionLimitExceeded => (
                    file.span,
                    format!(
                        "this code exceeds the parser's recursion limit, please report a Tvix bug"
                    ),
                ),

                // TODO: can rnix even still throw this? it's semantic!
                rnix::parser::ParseError::UnexpectedDoubleBind(range) => (
                    range.span_for(file),
                    "this pattern was bound more than once".into(),
                ),

                // The error enum is marked as `#[non_exhaustive]` in rnix,
                // which disables the compiler error for missing a variant. This
                // feature makes it possible for users to miss critical updates
                // of enum variants for a more exciting runtime experience.
                new => todo!("new parse error variant: {}", new),
            };

            Some(SpanLabel {
                span,
                label: Some(label),
                style: if idx == 0 {
                    SpanStyle::Primary
                } else {
                    SpanStyle::Secondary
                },
            })
        })
        .collect()
}

impl Error {
    pub fn fancy_format_str(&self, source: &SourceCode) -> String {
        let mut out = vec![];
        Emitter::vec(&mut out, Some(&*source.codemap())).emit(&[self.diagnostic(source)]);
        String::from_utf8_lossy(&out).to_string()
    }

    /// Render a fancy, human-readable output of this error and print
    /// it to stderr.
    pub fn fancy_format_stderr(&self, source: &SourceCode) {
        Emitter::stderr(ColorConfig::Auto, Some(&*source.codemap()))
            .emit(&[self.diagnostic(source)]);
    }

    /// Create the optional span label displayed as an annotation on
    /// the underlined span of the error.
    fn span_label(&self) -> Option<String> {
        None
    }

    /// Create the primary error message displayed to users.
    fn message(&self) -> String {
        match &self.kind {
            ErrorKind::Throw(msg) => format!("error thrown: {}", msg),
            ErrorKind::Abort(msg) => format!("evaluation aborted: {}", msg),
            ErrorKind::AssertionFailed => "assertion failed".to_string(),

            ErrorKind::DuplicateAttrsKey { key } => {
                format!("attribute key '{}' already defined", key)
            }

            ErrorKind::InvalidAttributeName(val) => format!(
                "found attribute name '{}' of type '{}', but attribute names must be strings",
                val,
                val.type_of()
            ),

            ErrorKind::AttributeNotFound { name } => format!(
                "attribute with name '{}' could not be found in the set",
                name
            ),

            ErrorKind::IndexOutOfBounds { index } => {
                format!("list index '{}' is out of bounds", index)
            }

            ErrorKind::TailEmptyList => "'tail' called on an empty list".to_string(),

            ErrorKind::TypeError { expected, actual } => format!(
                "expected value of type '{}', but found a '{}'",
                expected, actual
            ),

            ErrorKind::Incomparable { lhs, rhs } => {
                format!("can not compare a {} with a {}", lhs, rhs)
            }

            ErrorKind::PathResolution(err) => format!("could not resolve path: {}", err),

            ErrorKind::DynamicKeyInScope(scope) => {
                format!("dynamically evaluated keys are not allowed in {}", scope)
            }

            ErrorKind::UnknownStaticVariable => "variable not found".to_string(),

            ErrorKind::UnknownDynamicVariable(name) => format!(
                r#"variable '{}' could not be found

Note that this occured within a `with`-expression. The problem may be related
to a missing value in the attribute set(s) included via `with`."#,
                name
            ),

            ErrorKind::VariableAlreadyDefined(_) => "variable has already been defined".to_string(),

            ErrorKind::NotCallable(other_type) => {
                format!(
                    "only functions and builtins can be called, but this is a '{}'",
                    other_type
                )
            }

            ErrorKind::InfiniteRecursion => "infinite recursion encountered".to_string(),

            // Errors themselves ignored here & handled in Self::spans instead
            ErrorKind::ParseErrors(_) => format!("failed to parse Nix code:"),

            // TODO(tazjin): trace through the whole chain of thunk
            // forcing errors with secondary spans, instead of just
            // delegating to the inner error
            ErrorKind::ThunkForce(err) => err.message(),

            ErrorKind::NotCoercibleToString { kind, from } => {
                let kindly = match kind {
                    CoercionKind::Strong => "strongly",
                    CoercionKind::Weak => "weakly",
                };

                let hint = if *from == "set" {
                    ", missing a `__toString` or `outPath` attribute"
                } else {
                    ""
                };

                format!("cannot ({kindly}) coerce {from} to a string{hint}")
            }

            ErrorKind::NotAnAbsolutePath(given) => {
                format!(
                    "string '{}' does not represent an absolute path",
                    given.to_string_lossy()
                )
            }

            ErrorKind::ParseIntError(err) => {
                format!("invalid integer: {}", err)
            }

            ErrorKind::NegativeLength { length } => {
                format!(
                    "cannot use a negative integer, {}, for a value representing length",
                    length
                )
            }

            ErrorKind::UnmergeableInherit { name } => {
                format!(
                    "cannot merge a nested attribute set into the inherited entry '{}'",
                    name
                )
            }

            ErrorKind::UnmergeableValue => {
                "nested attribute sets or keys can only be merged with literal attribute sets"
                    .into()
            }

            ErrorKind::ReadFileError { path, error } => {
                format!(
                    "failed to read file '{}': {}",
                    path.to_string_lossy(),
                    error
                )
            }

            // Errors themselves ignored here & handled in Self::spans instead
            ErrorKind::ImportParseError { path, .. } => {
                format!(
                    "parse errors occured while importing '{}'",
                    path.to_string_lossy()
                )
            }

            ErrorKind::ImportCompilerError { errors, path } => {
                // TODO: chain display of these errors, though this is
                // probably not the right place for that (should
                // branch into a more elaborate diagnostic() call
                // below).
                format!(
                    "{} errors occured while importing '{}'",
                    errors.len(),
                    path.to_string_lossy()
                )
            }

            ErrorKind::NotImplemented(feature) => {
                format!("feature not yet implemented in Tvix: {}", feature)
            }
        }
    }

    /// Return the unique error code for this variant which can be
    /// used to refer users to documentation.
    fn code(&self) -> &'static str {
        match self.kind {
            ErrorKind::Throw(_) => "E001",
            ErrorKind::Abort(_) => "E002",
            ErrorKind::AssertionFailed => "E003",
            ErrorKind::InvalidAttributeName { .. } => "E004",
            ErrorKind::AttributeNotFound { .. } => "E005",
            ErrorKind::TypeError { .. } => "E006",
            ErrorKind::Incomparable { .. } => "E007",
            ErrorKind::PathResolution(_) => "E008",
            ErrorKind::DynamicKeyInScope(_) => "E009",
            ErrorKind::UnknownStaticVariable => "E010",
            ErrorKind::UnknownDynamicVariable(_) => "E011",
            ErrorKind::VariableAlreadyDefined(_) => "E012",
            ErrorKind::NotCallable(_) => "E013",
            ErrorKind::InfiniteRecursion => "E014",
            ErrorKind::ParseErrors(_) => "E015",
            ErrorKind::DuplicateAttrsKey { .. } => "E016",
            ErrorKind::NotCoercibleToString { .. } => "E018",
            ErrorKind::IndexOutOfBounds { .. } => "E019",
            ErrorKind::NotAnAbsolutePath(_) => "E020",
            ErrorKind::ParseIntError(_) => "E021",
            ErrorKind::NegativeLength { .. } => "E022",
            ErrorKind::TailEmptyList { .. } => "E023",
            ErrorKind::UnmergeableInherit { .. } => "E024",
            ErrorKind::UnmergeableValue => "E025",
            ErrorKind::ReadFileError { .. } => "E026",
            ErrorKind::ImportParseError { .. } => "E027",
            ErrorKind::ImportCompilerError { .. } => "E028",

            // Placeholder error while Tvix is under construction.
            ErrorKind::NotImplemented(_) => "E999",

            // TODO: thunk force errors should yield a chained
            // diagnostic, but until then we just forward the error
            // code from the inner error.
            //
            // The error code for thunk forces is E017.
            ErrorKind::ThunkForce(ref err) => err.code(),
        }
    }

    fn spans(&self, source: &SourceCode) -> Vec<SpanLabel> {
        match &self.kind {
            ErrorKind::ImportParseError { errors, file, .. } => {
                spans_for_parse_errors(&file, errors)
            }

            ErrorKind::ParseErrors(errors) => {
                let file = source.get_file(self.span);
                spans_for_parse_errors(&file, errors)
            }

            // All other errors pretty much have the same shape.
            _ => {
                vec![SpanLabel {
                    label: self.span_label(),
                    span: self.span,
                    style: SpanStyle::Primary,
                }]
            }
        }
    }

    fn diagnostic(&self, source: &SourceCode) -> Diagnostic {
        Diagnostic {
            level: Level::Error,
            message: self.message(),
            spans: self.spans(source),
            code: Some(self.code().into()),
        }
    }
}
