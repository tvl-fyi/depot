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

extern crate askama;

#[macro_use]
extern crate diesel;

#[macro_use]
extern crate failure;

#[macro_use]
extern crate log;

#[macro_use]
extern crate serde_derive;

extern crate actix;
extern crate actix_web;
extern crate chrono;
extern crate comrak;
extern crate crimp;
extern crate curl;
extern crate env_logger;
extern crate futures;
extern crate hyper;
extern crate md5;
extern crate mime_guess;
extern crate r2d2;
extern crate rand;
extern crate rouille;
extern crate serde;
extern crate serde_json;
extern crate tokio;
extern crate tokio_timer;
extern crate url;
extern crate url_serde;

/// Simple macro used to reduce boilerplate when defining actor
/// message types.
macro_rules! message {
    ( $t:ty, $r:ty ) => {
        impl Message for $t {
            type Result = $r;
        }
    };
}

pub mod db;
pub mod errors;
pub mod handlers;
pub mod models;
pub mod oidc;
pub mod render;
pub mod schema;

use crate::db::*;
use crate::handlers::*;
use crate::oidc::OidcExecutor;
use crate::render::Renderer;
use actix::prelude::*;
use actix_web::http::Method;
use actix_web::middleware::identity::{CookieIdentityPolicy, IdentityService};
use actix_web::middleware::Logger;
use actix_web::*;
use diesel::pg::PgConnection;
use diesel::r2d2::{ConnectionManager, Pool};
use rand::{OsRng, Rng};
use std::env;

fn config(name: &str) -> String {
    env::var(name).expect(&format!("{} must be set", name))
}

fn config_default(name: &str, default: &str) -> String {
    env::var(name).unwrap_or(default.into())
}

fn start_db_executor() -> Addr<DbExecutor> {
    info!("Initialising database connection pool ...");
    let db_url = config("DATABASE_URL");

    let manager = ConnectionManager::<PgConnection>::new(db_url);
    let pool = Pool::builder()
        .build(manager)
        .expect("Failed to initialise DB pool");

    SyncArbiter::start(2, move || DbExecutor(pool.clone()))
}

fn schedule_search_refresh(db: Addr<DbExecutor>) {
    use std::thread;
    use std::time::{Duration, Instant};
    use tokio::prelude::*;
    use tokio::timer::Interval;

    let task = Interval::new(Instant::now(), Duration::from_secs(60))
        .from_err()
        .for_each(move |_| db.send(db::RefreshSearchView).flatten())
        .map_err(|err| error!("Error while updating search view: {}", err));

    thread::spawn(|| tokio::run(task));
}

fn start_oidc_executor(base_url: &str) -> Addr<OidcExecutor> {
    info!("Initialising OIDC integration ...");
    let oidc_url = config("OIDC_DISCOVERY_URL");
    let oidc_config =
        oidc::load_oidc(&oidc_url).expect("Failed to retrieve OIDC discovery document");

    let oidc = oidc::OidcExecutor {
        oidc_config,
        client_id: config("OIDC_CLIENT_ID"),
        client_secret: config("OIDC_CLIENT_SECRET"),
        redirect_uri: format!("{}/oidc/callback", base_url),
    };

    oidc.start()
}

fn start_renderer() -> Addr<Renderer> {
    let comrak = comrak::ComrakOptions {
        github_pre_lang: true,
        ext_strikethrough: true,
        ext_table: true,
        ext_autolink: true,
        ext_tasklist: true,
        ext_footnotes: true,
        ext_tagfilter: true,
        ..Default::default()
    };

    Renderer { comrak }.start()
}

fn gen_session_key() -> [u8; 64] {
    let mut key_bytes = [0; 64];
    let mut rng = OsRng::new().expect("Failed to retrieve RNG for key generation");
    rng.fill_bytes(&mut key_bytes);

    key_bytes
}

fn start_http_server(
    base_url: String,
    db_addr: Addr<DbExecutor>,
    oidc_addr: Addr<OidcExecutor>,
    renderer_addr: Addr<Renderer>,
) {
    info!("Initialising HTTP server ...");
    let bind_host = config_default("CONVERSE_BIND_HOST", "127.0.0.1:4567");
    let key = gen_session_key();
    let require_login = config_default("REQUIRE_LOGIN", "true".into()) == "true";

    server::new(move || {
        let state = AppState {
            db: db_addr.clone(),
            oidc: oidc_addr.clone(),
            renderer: renderer_addr.clone(),
        };

        let identity = IdentityService::new(
            CookieIdentityPolicy::new(&key)
                .name("converse_auth")
                .path("/")
                .secure(base_url.starts_with("https")),
        );

        let app = App::with_state(state)
            .middleware(Logger::default())
            .middleware(identity)
            .resource("/", |r| r.method(Method::GET).with(forum_index))
            .resource("/thread/new", |r| r.method(Method::GET).with(new_thread))
            .resource("/thread/submit", |r| {
                r.method(Method::POST).with(submit_thread)
            })
            .resource("/thread/reply", |r| {
                r.method(Method::POST).with(reply_thread)
            })
            .resource("/thread/{id}", |r| r.method(Method::GET).with(forum_thread))
            .resource("/post/{id}/edit", |r| r.method(Method::GET).with(edit_form))
            .resource("/post/edit", |r| r.method(Method::POST).with(edit_post))
            .resource("/search", |r| r.method(Method::GET).with(search_forum))
            .resource("/oidc/login", |r| r.method(Method::GET).with(login))
            .resource("/oidc/callback", |r| r.method(Method::POST).with(callback))
            .static_file(
                "/static/highlight.css",
                include_bytes!("../static/highlight.css"),
            )
            .static_file(
                "/static/highlight.js",
                include_bytes!("../static/highlight.js"),
            )
            .static_file("/static/styles.css", include_bytes!("../static/styles.css"));

        if require_login {
            app.middleware(RequireLogin)
        } else {
            app
        }
    })
    .bind(&bind_host)
    .expect(&format!("Could not bind on '{}'", bind_host))
    .start();
}

fn main() {
    env_logger::init();

    info!("Welcome to Converse! Hold on tight while we're getting ready.");
    let sys = actix::System::new("converse");

    let base_url = config("BASE_URL");

    let db_addr = start_db_executor();
    let oidc_addr = start_oidc_executor(&base_url);
    let renderer_addr = start_renderer();

    schedule_search_refresh(db_addr.clone());

    start_http_server(base_url, db_addr, oidc_addr, renderer_addr);

    sys.run();
}
