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

//! This module contains the implementation of converse's actix-web
//! HTTP handlers.
//!
//! Most handlers have an associated rendering function using one of
//! the tera templates stored in the `/templates` directory in the
//! project root.

use crate::db::*;
use crate::errors::{ConverseError, ConverseResult};
use crate::models::*;
use crate::oidc::*;
use crate::render::*;
use actix::prelude::*;
use actix_web;
use actix_web::http::Method;
use actix_web::middleware::identity::RequestIdentity;
use actix_web::middleware::{Middleware, Started};
use actix_web::*;
use futures::Future;

use rouille::{Request, Response};

type ConverseResponse = Box<dyn Future<Item = HttpResponse, Error = ConverseError>>;

const HTML: &'static str = "text/html";
const ANONYMOUS: i32 = 1;
const NEW_THREAD_LENGTH_ERR: &'static str = "Title and body can not be empty!";

/// Represents the state carried by the web server actors.
pub struct AppState {
    /// Address of the database actor
    pub db: Addr<DbExecutor>,

    /// Address of the OIDC actor
    pub oidc: Addr<OidcExecutor>,

    /// Address of the rendering actor
    pub renderer: Addr<Renderer>,
}

/// Serve the forum's index page.
pub fn forum_index_rouille(db: &DbExecutor) -> ConverseResult<Response> {
    let threads = db.list_threads()?;
    Ok(Response::html(index_page(threads)?))
}

pub fn forum_index(_: State<AppState>) -> ConverseResponse {
    unimplemented!()
}

/// Returns the ID of the currently logged in user. If there is no ID
/// present, the ID of the anonymous user will be returned.
pub fn get_user_id(req: &HttpRequest<AppState>) -> i32 {
    if let Some(id) = req.identity() {
        // If this .expect() call is triggered, someone is likely
        // attempting to mess with their cookies. These requests can
        // be allowed to fail without further ado.
        id.parse().expect("Session cookie contained invalid data!")
    } else {
        ANONYMOUS
    }
}

pub fn get_user_id_rouille(_req: &Request) -> i32 {
    // TODO(tazjin): Implement session support in rouille somehow.
    ANONYMOUS
}

pub fn forum_thread_rouille(
    req: &Request,
    db: &DbExecutor,
    thread_id: i32,
) -> ConverseResult<Response> {
    let user = get_user_id_rouille(&req);
    let thread = db.get_thread(thread_id)?;
    Ok(Response::html(thread_page(user, thread.0, thread.1)?))
}

/// This handler retrieves and displays a single forum thread.
pub fn forum_thread(
    _: State<AppState>,
    _: HttpRequest<AppState>,
    _: Path<i32>,
) -> ConverseResponse {
    unimplemented!()
}

/// This handler presents the user with the "New Thread" form.
pub fn new_thread(state: State<AppState>) -> ConverseResponse {
    state
        .renderer
        .send(NewThreadPage::default())
        .flatten()
        .map(|res| HttpResponse::Ok().content_type(HTML).body(res))
        .responder()
}

#[derive(Deserialize)]
pub struct NewThreadForm {
    pub title: String,
    pub post: String,
}

/// This handler receives a "New thread"-form and redirects the user
/// to the new thread after creation.
pub fn submit_thread(
    (state, input, req): (State<AppState>, Form<NewThreadForm>, HttpRequest<AppState>),
) -> ConverseResponse {
    // Trim whitespace out of inputs:
    let input = NewThreadForm {
        title: input.title.trim().into(),
        post: input.post.trim().into(),
    };

    // Perform simple validation and abort here if it fails:
    if input.title.is_empty() || input.post.is_empty() {
        return state
            .renderer
            .send(NewThreadPage {
                alerts: vec![NEW_THREAD_LENGTH_ERR],
                title: Some(input.title),
                post: Some(input.post),
            })
            .flatten()
            .map(|res| HttpResponse::Ok().content_type(HTML).body(res))
            .responder();
    }

    let user_id = get_user_id(&req);

    let new_thread = NewThread {
        user_id,
        title: input.title,
    };

    let msg = CreateThread {
        new_thread,
        post: input.post,
    };

    state
        .db
        .send(msg)
        .from_err()
        .and_then(move |res| {
            let thread = res?;
            info!(
                "Created new thread \"{}\" with ID {}",
                thread.title, thread.id
            );
            Ok(HttpResponse::SeeOther()
                .header("Location", format!("/thread/{}", thread.id))
                .finish())
        })
        .responder()
}

#[derive(Deserialize)]
pub struct NewPostForm {
    pub thread_id: i32,
    pub post: String,
}

/// This handler receives a "Reply"-form and redirects the user to the
/// new post after creation.
pub fn reply_thread(
    state: State<AppState>,
    input: Form<NewPostForm>,
    req: HttpRequest<AppState>,
) -> ConverseResponse {
    let user_id = get_user_id(&req);

    let new_post = NewPost {
        user_id,
        thread_id: input.thread_id,
        body: input.post.trim().into(),
    };

    state
        .db
        .send(CreatePost(new_post))
        .flatten()
        .from_err()
        .and_then(move |post| {
            info!("Posted reply {} to thread {}", post.id, post.thread_id);
            Ok(HttpResponse::SeeOther()
                .header(
                    "Location",
                    format!("/thread/{}#post-{}", post.thread_id, post.id),
                )
                .finish())
        })
        .responder()
}

/// This handler presents the user with the form to edit a post. If
/// the user attempts to edit a post that they do not have access to,
/// they are currently ungracefully redirected back to the post
/// itself.
pub fn edit_form(
    state: State<AppState>,
    req: HttpRequest<AppState>,
    query: Path<GetPost>,
) -> ConverseResponse {
    let user_id = get_user_id(&req);

    state
        .db
        .send(query.into_inner())
        .flatten()
        .from_err()
        .and_then(move |post| {
            if user_id != 1 && post.user_id == user_id {
                return Ok(post);
            }

            Err(ConverseError::PostEditForbidden {
                user: user_id,
                id: post.id,
            })
        })
        .and_then(move |post| {
            let edit_msg = EditPostPage {
                id: post.id,
                post: post.body,
            };

            state.renderer.send(edit_msg).from_err()
        })
        .flatten()
        .map(|page| HttpResponse::Ok().content_type(HTML).body(page))
        .responder()
}

/// This handler "executes" an edit to a post if the current user owns
/// the edited post.
pub fn edit_post(
    state: State<AppState>,
    req: HttpRequest<AppState>,
    update: Form<UpdatePost>,
) -> ConverseResponse {
    let user_id = get_user_id(&req);

    state
        .db
        .send(GetPost { id: update.post_id })
        .flatten()
        .from_err()
        .and_then(move |post| {
            if user_id != 1 && post.user_id == user_id {
                Ok(())
            } else {
                Err(ConverseError::PostEditForbidden {
                    user: user_id,
                    id: post.id,
                })
            }
        })
        .and_then(move |_| state.db.send(update.0).from_err())
        .flatten()
        .map(|updated| {
            HttpResponse::SeeOther()
                .header(
                    "Location",
                    format!("/thread/{}#post-{}", updated.thread_id, updated.id),
                )
                .finish()
        })
        .responder()
}

/// This handler executes a full-text search on the forum database and
/// displays the results to the user.
pub fn search_forum(state: State<AppState>, query: Query<SearchPosts>) -> ConverseResponse {
    let query_string = query.query.clone();
    state
        .db
        .send(query.into_inner())
        .flatten()
        .and_then(move |results| {
            state
                .renderer
                .send(SearchResultPage {
                    results,
                    query: query_string,
                })
                .from_err()
        })
        .flatten()
        .map(|res| HttpResponse::Ok().content_type(HTML).body(res))
        .responder()
}

/// This handler initiates an OIDC login.
pub fn login(state: State<AppState>) -> ConverseResponse {
    state
        .oidc
        .send(GetLoginUrl)
        .from_err()
        .and_then(|url| {
            Ok(HttpResponse::TemporaryRedirect()
                .header("Location", url)
                .finish())
        })
        .responder()
}

/// This handler handles an OIDC callback (i.e. completed login).
///
/// Upon receiving the callback, a token is retrieved from the OIDC
/// provider and a user lookup is performed. If a user with a matching
/// email-address is found in the database, it is logged in -
/// otherwise a new user is created.
pub fn callback(
    state: State<AppState>,
    data: Form<CodeResponse>,
    req: HttpRequest<AppState>,
) -> ConverseResponse {
    state
        .oidc
        .send(RetrieveToken(data.0))
        .flatten()
        .map(|author| LookupOrCreateUser {
            email: author.email,
            name: author.name,
        })
        .and_then(move |msg| state.db.send(msg).from_err())
        .flatten()
        .and_then(move |user| {
            info!("Completed login for user {} ({})", user.email, user.id);
            req.remember(user.id.to_string());
            Ok(HttpResponse::SeeOther().header("Location", "/").finish())
        })
        .responder()
}

/// This is an extension trait to enable easy serving of embedded
/// static content.
///
/// It is intended to be called with `include_bytes!()` when setting
/// up the actix-web application.
pub trait EmbeddedFile {
    fn static_file(self, path: &'static str, content: &'static [u8]) -> Self;
}

impl EmbeddedFile for App<AppState> {
    fn static_file(self, path: &'static str, content: &'static [u8]) -> Self {
        self.route(path, Method::GET, move |_: HttpRequest<_>| {
            let mime = format!("{}", mime_guess::from_path(path).first_or_octet_stream());
            HttpResponse::Ok().content_type(mime.as_str()).body(content)
        })
    }
}

/// Middleware used to enforce logins unceremoniously.
pub struct RequireLogin;

impl<S> Middleware<S> for RequireLogin {
    fn start(&self, req: &HttpRequest<S>) -> actix_web::Result<Started> {
        let logged_in = req.identity().is_some();
        let is_oidc_req = req.path().starts_with("/oidc");

        if !is_oidc_req && !logged_in {
            Ok(Started::Response(
                HttpResponse::SeeOther()
                    .header("Location", "/oidc/login")
                    .finish(),
            ))
        } else {
            Ok(Started::Done)
        }
    }
}
