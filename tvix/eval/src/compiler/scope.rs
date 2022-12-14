//! This module implements the scope-tracking logic of the Tvix
//! compiler.
//!
//! Scoping in Nix is fairly complicated, there are features like
//! mutually recursive bindings, `with`, upvalue capturing, builtin
//! poisoning and so on that introduce a fair bit of complexity.
//!
//! Tvix attempts to do as much of the heavy lifting of this at
//! compile time, and leave the runtime to mostly deal with known
//! stack indices. To do this, the compiler simulates where locals
//! will be at runtime using the data structures implemented here.

use std::{
    collections::{hash_map, HashMap},
    ops::Index,
};

use smol_str::SmolStr;

use crate::opcode::{StackIdx, UpvalueIdx};

#[derive(Debug)]
enum LocalName {
    /// Normally declared local with a statically known name.
    Ident(String),

    /// Phantom stack value (e.g. attribute set used for `with`) that
    /// must be accounted for to calculate correct stack offsets.
    Phantom,
}

/// Represents a single local already known to the compiler.
#[derive(Debug)]
pub struct Local {
    /// Identifier of this local. This is always a statically known
    /// value (Nix does not allow dynamic identifier names in locals),
    /// or a "phantom" value not accessible by users.
    name: LocalName,

    /// Source span at which this local was declared.
    pub span: codemap::Span,

    /// Scope depth of this local.
    pub depth: usize,

    /// Is this local initialised?
    pub initialised: bool,

    /// Is this local known to have been used at all?
    pub used: bool,

    /// Does this local need to be finalised after the enclosing scope
    /// is completely constructed?
    pub needs_finaliser: bool,

    /// Does this local's upvalues contain a reference to itself?
    pub must_thunk: bool,
}

impl Local {
    /// Does the name of this local match the given string?
    pub fn has_name(&self, other: &str) -> bool {
        match &self.name {
            LocalName::Ident(name) => name == other,

            // Phantoms are *never* accessible by a name.
            LocalName::Phantom => false,
        }
    }

    /// Retrieve the name of the given local (if available).
    pub fn name(&self) -> Option<SmolStr> {
        match &self.name {
            LocalName::Phantom => None,
            LocalName::Ident(name) => Some(SmolStr::new(name)),
        }
    }

    /// Is this local intentionally ignored? (i.e. name starts with `_`)
    pub fn is_ignored(&self) -> bool {
        match &self.name {
            LocalName::Ident(name) => name.starts_with('_'),
            LocalName::Phantom => false,
        }
    }
}

/// Represents the current position of a local as resolved in a scope.
pub enum LocalPosition {
    /// Local is not known in this scope.
    Unknown,

    /// Local is known at the given local index.
    Known(LocalIdx),

    /// Local is known, but is being accessed recursively within its
    /// own initialisation. Depending on context, this is either an
    /// error or forcing a closure/thunk.
    Recursive(LocalIdx),
}

/// Represents the different ways in which upvalues can be captured in
/// closures or thunks.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum UpvalueKind {
    /// This upvalue captures a local from the stack.
    Local(LocalIdx),

    /// This upvalue captures an enclosing upvalue.
    Upvalue(UpvalueIdx),
}

#[derive(Clone, Debug)]
pub struct Upvalue {
    pub kind: UpvalueKind,
    pub span: codemap::Span,
}

/// The index of a local in the scope's local array at compile time.
#[repr(transparent)]
#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd)]
pub struct LocalIdx(usize);

/// Represents a scope known during compilation, which can be resolved
/// directly to stack indices.
#[derive(Debug, Default)]
pub struct Scope {
    pub locals: Vec<Local>,
    pub upvalues: Vec<Upvalue>,

    /// How many scopes "deep" are these locals?
    scope_depth: usize,

    /// Current size of the `with`-stack at runtime.
    with_stack_size: usize,

    /// Users are allowed to override globally defined symbols like
    /// `true`, `false` or `null` in scopes. We call this "scope
    /// poisoning", as it requires runtime resolution of those tokens.
    ///
    /// To support this efficiently, the depth at which a poisoning
    /// occured is tracked here.
    poisoned_tokens: HashMap<&'static str, usize>,
}

impl Index<LocalIdx> for Scope {
    type Output = Local;

    fn index(&self, index: LocalIdx) -> &Self::Output {
        &self.locals[index.0]
    }
}

impl Scope {
    /// Mark a globally defined token as poisoned.
    pub fn poison(&mut self, name: &'static str, depth: usize) {
        match self.poisoned_tokens.entry(name) {
            hash_map::Entry::Occupied(_) => {
                /* do nothing, as the token is already poisoned at a
                 * lower scope depth */
            }
            hash_map::Entry::Vacant(entry) => {
                entry.insert(depth);
            }
        }
    }

    /// Inherit scope details from a parent scope (required for
    /// correctly nesting scopes in lambdas and thunks when special
    /// scope features like poisoning are present).
    pub fn inherit(&self) -> Self {
        Self {
            poisoned_tokens: self.poisoned_tokens.clone(),
            scope_depth: self.scope_depth + 1,
            with_stack_size: self.with_stack_size + 1,
            ..Default::default()
        }
    }

    /// Check whether a given token is poisoned.
    pub fn is_poisoned(&self, name: &str) -> bool {
        self.poisoned_tokens.contains_key(name)
    }

    /// "Unpoison" tokens that were poisoned at the current depth.
    /// Used when scopes are closed.
    fn unpoison(&mut self) {
        self.poisoned_tokens
            .retain(|_, poisoned_at| *poisoned_at != self.scope_depth);
    }

    /// Increase the `with`-stack size of this scope.
    pub fn push_with(&mut self) {
        self.with_stack_size += 1;
    }

    /// Decrease the `with`-stack size of this scope.
    pub fn pop_with(&mut self) {
        self.with_stack_size -= 1;
    }

    /// Does this scope currently require dynamic runtime resolution
    /// of identifiers that could not be found?
    pub fn has_with(&self) -> bool {
        self.with_stack_size > 0
    }

    /// Resolve the stack index of a statically known local.
    pub fn resolve_local(&mut self, name: &str) -> LocalPosition {
        for (idx, local) in self.locals.iter_mut().enumerate().rev() {
            if local.has_name(name) {
                local.used = true;

                // This local is still being initialised, meaning that
                // we know its final runtime stack position, but it is
                // not yet on the stack.
                if !local.initialised {
                    return LocalPosition::Recursive(LocalIdx(idx));
                }

                return LocalPosition::Known(LocalIdx(idx));
            }
        }

        LocalPosition::Unknown
    }

    /// Declare a local variable that occupies a stack slot and should
    /// be accounted for, but is not directly accessible by users
    /// (e.g. attribute sets used for `with`).
    pub fn declare_phantom(&mut self, span: codemap::Span, initialised: bool) -> LocalIdx {
        let idx = self.locals.len();
        self.locals.push(Local {
            initialised,
            span,
            name: LocalName::Phantom,
            depth: self.scope_depth,
            needs_finaliser: false,
            must_thunk: false,
            used: true,
        });

        LocalIdx(idx)
    }

    /// Declare an uninitialised local variable.
    pub fn declare_local(&mut self, name: String, span: codemap::Span) -> LocalIdx {
        let idx = self.locals.len();
        self.locals.push(Local {
            name: LocalName::Ident(name),
            span,
            depth: self.scope_depth,
            initialised: false,
            needs_finaliser: false,
            must_thunk: false,
            used: false,
        });

        LocalIdx(idx)
    }

    /// Mark local as initialised after compiling its expression.
    pub fn mark_initialised(&mut self, idx: LocalIdx) {
        self.locals[idx.0].initialised = true;
    }

    /// Mark local as needing a finaliser.
    pub fn mark_needs_finaliser(&mut self, idx: LocalIdx) {
        self.locals[idx.0].needs_finaliser = true;
    }

    /// Mark local as must be wrapped in a thunk.  This happens if
    /// the local has a reference to itself in its upvalues.
    pub fn mark_must_thunk(&mut self, idx: LocalIdx) {
        self.locals[idx.0].must_thunk = true;
    }

    /// Compute the runtime stack index for a given local by
    /// accounting for uninitialised variables at scopes below this
    /// one.
    pub fn stack_index(&self, idx: LocalIdx) -> StackIdx {
        let uninitialised_count = self.locals[..(idx.0)]
            .iter()
            .filter(|l| !l.initialised && self[idx].depth > l.depth)
            .count();

        StackIdx(idx.0 - uninitialised_count)
    }

    /// Increase the current scope depth (e.g. within a new bindings
    /// block, or `with`-scope).
    pub fn begin_scope(&mut self) {
        self.scope_depth += 1;
    }

    /// Decrease the scope depth and remove all locals still tracked
    /// for the current scope.
    ///
    /// Returns the count of locals that were dropped while marked as
    /// initialised (used by the compiler to determine whether to emit
    /// scope cleanup operations), as well as the spans of the
    /// definitions of unused locals (used by the compiler to emit
    /// unused binding warnings).
    pub fn end_scope(&mut self) -> (usize, Vec<codemap::Span>) {
        debug_assert!(self.scope_depth != 0, "can not end top scope");

        // If this scope poisoned any builtins or special identifiers,
        // they need to be reset.
        self.unpoison();

        let mut pops = 0;
        let mut unused_spans = vec![];

        // TL;DR - iterate from the back while things belonging to the
        // ended scope still exist.
        while self.locals.last().unwrap().depth == self.scope_depth {
            if let Some(local) = self.locals.pop() {
                // pop the local from the stack if it was actually
                // initialised
                if local.initialised {
                    pops += 1;
                }

                // analyse whether the local was accessed during its
                // lifetime, and emit a warning otherwise (unless the
                // user explicitly chose to ignore it by prefixing the
                // identifier with `_`)
                if !local.used && !local.is_ignored() {
                    unused_spans.push(local.span);
                }
            }
        }

        self.scope_depth -= 1;

        (pops, unused_spans)
    }

    /// Access the current scope depth.
    pub fn scope_depth(&self) -> usize {
        self.scope_depth
    }
}
