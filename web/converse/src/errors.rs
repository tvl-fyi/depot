// Copyright (C) 2018-2021 Vincent Ambo <tazjin@tvl.su>
//
// This file is part of Converse.
//
// This program is free software: you can redistribute it and/or
// modify it under the terms of the GNU General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see
// <https://www.gnu.org/licenses/>.

//! This module defines custom error types using the `failure`-crate.
//! Links to foreign error types (such as database connection errors)
//! are established in a similar way as was tradition in
//! `error_chain`, albeit manually.

use actix_web::http::StatusCode;
use actix_web::{HttpResponse, ResponseError};
use std::result;

// Modules with foreign errors:
use {actix, actix_web, askama, diesel, r2d2, tokio_timer};

pub type Result<T> = result::Result<T, ConverseError>;
pub type ConverseResult<T> = result::Result<T, ConverseError>;

#[derive(Debug, Fail)]
pub enum ConverseError {
    #[fail(display = "an internal Converse error occured: {}", reason)]
    InternalError { reason: String },

    #[fail(display = "a database error occured: {}", error)]
    Database { error: diesel::result::Error },

    #[fail(display = "a database connection pool error occured: {}", error)]
    ConnectionPool { error: r2d2::Error },

    #[fail(display = "a template rendering error occured: {}", reason)]
    Template { reason: String },

    #[fail(display = "error occured during request handling: {}", error)]
    ActixWeb { error: actix_web::Error },

    #[fail(display = "error occured running timer: {}", error)]
    Timer { error: tokio_timer::Error },

    #[fail(display = "user {} does not have permission to edit post {}", user, id)]
    PostEditForbidden { user: i32, id: i32 },

    #[fail(display = "thread {} is closed and can not be responded to", id)]
    ThreadClosed { id: i32 },

    #[fail(display = "JSON serialisation failed: {}", error)]
    Serialisation { error: serde_json::Error },

    // This variant is used as a catch-all for wrapping
    // actix-web-compatible response errors, such as the errors it
    // throws itself.
    #[fail(display = "Actix response error: {}", error)]
    Actix { error: Box<dyn ResponseError> },
}

// Establish conversion links to foreign errors:

impl From<diesel::result::Error> for ConverseError {
    fn from(error: diesel::result::Error) -> ConverseError {
        ConverseError::Database { error }
    }
}

impl From<r2d2::Error> for ConverseError {
    fn from(error: r2d2::Error) -> ConverseError {
        ConverseError::ConnectionPool { error }
    }
}

impl From<askama::Error> for ConverseError {
    fn from(error: askama::Error) -> ConverseError {
        ConverseError::Template {
            reason: format!("{}", error),
        }
    }
}

impl From<actix::MailboxError> for ConverseError {
    fn from(error: actix::MailboxError) -> ConverseError {
        ConverseError::Actix {
            error: Box::new(error),
        }
    }
}

impl From<actix_web::Error> for ConverseError {
    fn from(error: actix_web::Error) -> ConverseError {
        ConverseError::ActixWeb { error }
    }
}

impl From<serde_json::Error> for ConverseError {
    fn from(error: serde_json::Error) -> ConverseError {
        ConverseError::Serialisation { error }
    }
}

impl From<curl::Error> for ConverseError {
    fn from(error: curl::Error) -> ConverseError {
        ConverseError::InternalError {
            reason: format!("error during HTTP request: {}", error),
        }
    }
}

impl From<tokio_timer::Error> for ConverseError {
    fn from(error: tokio_timer::Error) -> ConverseError {
        ConverseError::Timer { error }
    }
}

// Support conversion of error type into HTTP error responses:

impl ResponseError for ConverseError {
    fn error_response(&self) -> HttpResponse {
        // Everything is mapped to internal server errors for now.
        match *self {
            ConverseError::ThreadClosed { id } => HttpResponse::SeeOther()
                .header("Location", format!("/thread/{}#post-reply", id))
                .finish(),
            _ => HttpResponse::build(StatusCode::INTERNAL_SERVER_ERROR)
                .body(format!("An error occured: {}", self)),
        }
    }
}
