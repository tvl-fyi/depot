use std::cell::RefCell;
use std::fmt::Write;
use std::rc::Rc;

use serde::{Deserialize, Serialize};
use tvix_eval::observer::TracingObserver;
use tvix_eval::observer::{DisassemblingObserver, NoOpObserver};
use tvix_eval::SourceCode;
use web_sys::HtmlDetailsElement;
use web_sys::HtmlTextAreaElement;
use yew::prelude::*;
use yew::TargetCast;
use yew_router::{prelude::*, AnyRoute};

#[derive(Clone)]
enum Msg {
    CodeChange(String),
    ToggleTrace(bool),
    ToggleDisplayAst(bool),

    // Required because browsers are stupid and it's easy to get into
    // infinite loops with `ontoggle` events.
    NoOp,
}

#[derive(Clone, Serialize, Deserialize)]
struct Model {
    code: String,

    // #[serde(skip_serializing)]
    trace: bool,

    // #[serde(skip_serializing)]
    display_ast: bool,
}

fn tvixbolt_overview() -> Html {
    html! {
        <>
          <p>
            {"This page lets you explore the bytecode generated by the "}
            <a href="https://cs.tvl.fyi/depot/-/tree/tvix">{"Tvix"}</a>
            {" compiler for the Nix language. See the "}
            <a href="https://tvl.fyi/blog/rewriting-nix">{"Tvix announcement"}</a>
            {" for some background information on Tvix itself."}
          </p>
          <p>
            {"Tvix is still "}<i>{"extremely work-in-progress"}</i>{" and you "}
            {"should expect to be able to cause bugs and errors in this tool."}
          </p>
        </>
    }
}

/// This renders an ad in the Tvixbolt footer. Most people that end up
/// on Tvixbolt will probably block this anyways, but might as well.
fn ad() -> Html {
    let ad_code = r#"
window.yaContextCb.push(()=>{
  Ya.Context.AdvManager.render({
    renderTo: 'yandex_rtb_R-A-1943274-1',
    blockId: 'R-A-1943274-1'
  })
})
"#;

    html! {
        <div id="ad">
            <div id="yandex_rtb_R-A-1943274-1"></div>
            <script>{ad_code}</script>
        </div>
    }
}

fn footer_link(location: &'static str, name: &str) -> Html {
    html! {
        <>
            <a class="uncoloured-link" href={location}>{name}</a>{" | "}
        </>
    }
}

fn footer() -> Html {
    html! {
        <>
        <hr/>
        <footer>
          <p class="footer">
            {footer_link("https://tvl.su", "home")}
            {footer_link("https://cs.tvl.fyi", "code")}
            {footer_link("https://tvl.fyi/builds", "ci")}
            {footer_link("https://b.tvl.fyi", "bugs")}
            {"© ООО ТВЛ"}
          </p>
          <p class="lod">{"ಠ_ಠ"}</p>
          {ad()}
        </footer>
        </>
    }
}

impl Component for Model {
    type Message = Msg;
    type Properties = ();

    fn create(_: &Context<Self>) -> Self {
        BrowserHistory::new()
            .location()
            .query::<Self>()
            .unwrap_or_else(|_| Self {
                code: String::new(),
                trace: false,
                display_ast: false,
            })
    }

    fn update(&mut self, _: &Context<Self>, msg: Self::Message) -> bool {
        match msg {
            Msg::ToggleTrace(trace) => {
                self.trace = trace;
            }

            Msg::ToggleDisplayAst(display_ast) => {
                self.display_ast = display_ast;
            }

            Msg::CodeChange(new_code) => {
                self.code = new_code;
            }

            Msg::NoOp => {}
        }

        let _ = BrowserHistory::new().replace_with_query(AnyRoute::new("/"), self.clone());

        true
    }

    fn view(&self, ctx: &Context<Self>) -> Html {
        // This gives us a component's "`Scope`" which allows us to send messages, etc to the component.
        let link = ctx.link();
        html! {
            <>
            <div class="container">
                <h1>{"tvixbolt 0.1-alpha"}</h1>
                {tvixbolt_overview()}
                <form>
                  <fieldset>
                    <legend>{"Input"}</legend>

                    <div class="form-group">
                        <label for="code">{"Nix code:"}</label>
                        <textarea
                         oninput={link.callback(|e: InputEvent| {
                             let ta = e.target_unchecked_into::<HtmlTextAreaElement>().value();
                             Msg::CodeChange(ta)

                         })}
                         id="code" cols="30" rows="10" value={self.code.clone()}>
                         </textarea>
                    </div>
                  </fieldset>
                </form>
                <hr />
                {self.run(ctx)}
                {footer()}
            </div>
            </>
        }
    }
}

impl Model {
    fn run(&self, ctx: &Context<Self>) -> Html {
        if self.code.is_empty() {
            return html! {
                <p>
                  {"Enter some Nix code above to get started. Don't know Nix yet? "}
                  {"Check out "}
                  <a href="https://code.tvl.fyi/about/nix/nix-1p/README.md">{"nix-1p"}</a>
                  {"!"}
                </p>
            };
        }

        html! {
            <>
              <h2>{"Result:"}</h2>
            {eval(self).display(ctx, self)}
            </>
        }
    }
}

#[derive(Default)]
struct Output {
    parse_errors: String,
    warnings: String,
    compiler_errors: String,
    runtime_errors: String,
    output: String,
    bytecode: Vec<u8>,
    trace: Vec<u8>,
    ast: String,
}

fn maybe_show(title: &str, s: &str) -> Html {
    if s.is_empty() {
        html! {}
    } else {
        html! {
            <>
              <h3>{title}</h3>
              <pre>{s}</pre>
            </>
        }
    }
}

fn maybe_details(
    ctx: &Context<Model>,
    title: &str,
    s: &str,
    display: bool,
    toggle: fn(bool) -> Msg,
) -> Html {
    let link = ctx.link();
    if display {
        let msg = toggle(false);
        html! {
            <details open=true
                     ontoggle={link.callback(move |e: Event| {
                         let details = e.target_unchecked_into::<HtmlDetailsElement>();
                         if !details.open() {
                             msg.clone()
                         } else {
                             Msg::NoOp
                         }
                     })}>

              <summary><h3 style="display: inline;">{title}</h3></summary>
              <pre>{s}</pre>
            </details>
        }
    } else {
        let msg = toggle(true);
        html! {
            <details ontoggle={link.callback(move |e: Event| {
                         let details = e.target_unchecked_into::<HtmlDetailsElement>();
                         if details.open() {
                             msg.clone()
                         } else {
                             Msg::NoOp
                         }
                     })}>
              <summary><h3 style="display: inline;">{title}</h3></summary>
            </details>
        }
    }
}

impl Output {
    fn display(self, ctx: &Context<Model>, model: &Model) -> Html {
        html! {
            <>
            {maybe_show("Parse errors:", &self.parse_errors)}
            {maybe_show("Warnings:", &self.warnings)}
            {maybe_show("Output:", &self.output)}
            {maybe_show("Compiler errors:", &self.compiler_errors)}
            {maybe_show("Bytecode:", &String::from_utf8_lossy(&self.bytecode))}
            {maybe_show("Runtime errors:", &self.runtime_errors)}
            {maybe_details(ctx, "Runtime trace:", &String::from_utf8_lossy(&self.trace), model.trace, Msg::ToggleTrace)}
            {maybe_details(ctx, "Parsed AST:", &self.ast, model.display_ast, Msg::ToggleDisplayAst)}
            </>
        }
    }
}

fn eval(model: &Model) -> Output {
    let mut out = Output::default();

    if model.code.is_empty() {
        return out;
    }

    let parsed = rnix::ast::Root::parse(&model.code);
    let errors = parsed.errors();

    if !errors.is_empty() {
        for err in errors {
            writeln!(&mut out.parse_errors, "parse error: {}", err).unwrap();
        }

        return out;
    }

    // If we've reached this point, there are no errors.
    let root_expr = parsed
        .tree()
        .expr()
        .expect("expression should exist if no errors occured");

    if model.display_ast {
        out.ast = tvix_eval::pretty_print_expr(&root_expr);
    }

    let source = SourceCode::new();
    let file = source.add_file("nixbolt".to_string(), model.code.clone());

    let mut compilation_observer = DisassemblingObserver::new(source.clone(), &mut out.bytecode);

    let result = tvix_eval::compile(
        &root_expr,
        Some("/nixbolt".into()),
        file.clone(),
        Rc::new(RefCell::new(tvix_eval::global_builtins())),
        &mut compilation_observer,
    )
    .unwrap();

    for warning in result.warnings {
        writeln!(
            &mut out.warnings,
            "{}\n",
            warning.fancy_format_str(&source).trim(),
        )
        .unwrap();
    }

    if !result.errors.is_empty() {
        for error in &result.errors {
            writeln!(
                &mut out.compiler_errors,
                "{}\n",
                error.fancy_format_str(&source).trim(),
            )
            .unwrap();
        }

        return out;
    }

    let result = if model.trace {
        tvix_eval::run_lambda(
            Default::default(),
            &mut TracingObserver::new(&mut out.trace),
            result.lambda,
        )
    } else {
        tvix_eval::run_lambda(
            Default::default(),
            &mut NoOpObserver::default(),
            result.lambda,
        )
    };

    match result {
        Ok(result) => {
            for warning in result.warnings {
                writeln!(
                    &mut out.warnings,
                    "{}\n",
                    warning.fancy_format_str(&source).trim(),
                )
                .unwrap();
            }

            writeln!(&mut out.output, "{}", result.value).unwrap()
        }
        Err(err) => writeln!(
            &mut out.runtime_errors,
            "{}",
            err.fancy_format_str(&source).trim()
        )
        .unwrap(),
    };

    out
}

fn main() {
    yew::start_app::<Model>();
}
