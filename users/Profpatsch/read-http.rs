extern crate arglib_netencode;
extern crate ascii;
extern crate exec_helpers;
extern crate httparse;
extern crate netencode;

use exec_helpers::{die_expected_error, die_temporary, die_user_error};
use std::collections::HashMap;
use std::io::{Read, Write};
use std::os::unix::io::FromRawFd;

use netencode::dec::Decoder;
use netencode::{dec, T, U};

enum What {
    Request,
    Response,
}

// reads a http request (stdin), and writes all headers to stdout, as netencoded record.
// The keys are text, but can be lists of text iff headers appear multiple times, so beware.
fn main() -> std::io::Result<()> {
    exec_helpers::no_args("read-http");

    let args = dec::RecordDot {
        field: "what",
        inner: dec::OneOf {
            list: vec!["request", "response"],
            inner: dec::Text,
        },
    };
    let what: What = match args.dec(arglib_netencode::arglib_netencode("read-http", None).to_u()) {
        Ok("request") => What::Request,
        Ok("response") => What::Response,
        Ok(v) => panic!("shouldn’t happen!, value was: {}", v),
        Err(dec::DecodeError(err)) => die_user_error("read-http", err),
    };

    fn read_stdin_to_complete<F>(mut parse: F) -> ()
    where
        F: FnMut(&[u8]) -> httparse::Result<usize>,
    {
        let mut res = httparse::Status::Partial;
        loop {
            if let httparse::Status::Complete(_) = res {
                return;
            }
            let mut buf = [0; 2048];
            match std::io::stdin().read(&mut buf[..]) {
                Ok(size) => {
                    if size == 0 {
                        break;
                    }
                }
                Err(err) => {
                    die_temporary("read-http", format!("could not read from stdin, {:?}", err))
                }
            }
            match parse(&buf) {
                Ok(status) => {
                    res = status;
                }
                Err(err) => {
                    die_temporary("read-http", format!("httparse parsing failed: {:#?}", err))
                }
            }
        }
    }

    fn normalize_headers<'a>(headers: &'a [httparse::Header]) -> HashMap<String, U<'a>> {
        let mut res = HashMap::new();
        for httparse::Header { name, value } in headers {
            let val = ascii::AsciiStr::from_ascii(*value)
                .expect(&format!(
                    "read-http: we require header values to be ASCII, but the header {} was {:?}",
                    name, value
                ))
                .as_str();
            // lowercase the header names, since the standard doesn’t care
            // and we want unique strings to match against
            let name_lower = name.to_lowercase();
            match res.insert(name_lower, U::Text(val)) {
                None => (),
                Some(U::Text(t)) => {
                    let name_lower = name.to_lowercase();
                    let _ = res.insert(name_lower, U::List(vec![U::Text(t), U::Text(val)]));
                    ()
                }
                Some(U::List(mut l)) => {
                    let name_lower = name.to_lowercase();
                    l.push(U::Text(val));
                    let _ = res.insert(name_lower, U::List(l));
                    ()
                }
                Some(o) => panic!("read-http: header not text nor list: {:?}", o),
            }
        }
        res
    }

    // tries to read until the end of the http header (deliniated by two newlines "\r\n\r\n")
    fn read_till_end_of_header<R: Read>(buf: &mut Vec<u8>, reader: R) -> Option<()> {
        let mut chonker = Chunkyboi::new(reader, 4096);
        loop {
            // TODO: attacker can send looooong input, set upper maximum
            match chonker.next() {
                Some(Ok(chunk)) => {
                    buf.extend_from_slice(&chunk);
                    if chunk.windows(4).any(|c| c == b"\r\n\r\n") {
                        return Some(());
                    }
                }
                Some(Err(err)) => {
                    die_temporary("read-http", format!("error reading from stdin: {:?}", err))
                }
                None => return None,
            }
        }
    }

    // max header size chosen arbitrarily
    let mut headers = [httparse::EMPTY_HEADER; 128];
    let stdin = std::io::stdin();

    match what {
        Request => {
            let mut req = httparse::Request::new(&mut headers);
            let mut buf: Vec<u8> = vec![];
            match read_till_end_of_header(&mut buf, stdin.lock()) {
                Some(()) => match req.parse(&buf) {
                    Ok(httparse::Status::Complete(_body_start)) => {}
                    Ok(httparse::Status::Partial) => {
                        die_expected_error("read-http", "httparse should have gotten a full header")
                    }
                    Err(err) => die_expected_error(
                        "read-http",
                        format!("httparse response parsing failed: {:#?}", err),
                    ),
                },
                None => die_expected_error(
                    "read-http",
                    format!("httparse end of stdin reached before able to parse request headers"),
                ),
            }
            let method = req.method.expect("method must be filled on complete parse");
            let path = req.path.expect("path must be filled on complete parse");
            write_dict_req(method, path, &normalize_headers(req.headers))
        }
        Response => {
            let mut resp = httparse::Response::new(&mut headers);
            let mut buf: Vec<u8> = vec![];
            match read_till_end_of_header(&mut buf, stdin.lock()) {
                Some(()) => match resp.parse(&buf) {
                    Ok(httparse::Status::Complete(_body_start)) => {}
                    Ok(httparse::Status::Partial) => {
                        die_expected_error("read-http", "httparse should have gotten a full header")
                    }
                    Err(err) => die_expected_error(
                        "read-http",
                        format!("httparse response parsing failed: {:#?}", err),
                    ),
                },
                None => die_expected_error(
                    "read-http",
                    format!("httparse end of stdin reached before able to parse response headers"),
                ),
            }
            let code = resp.code.expect("code must be filled on complete parse");
            let reason = resp
                .reason
                .expect("reason must be filled on complete parse");
            write_dict_resp(code, reason, &normalize_headers(resp.headers))
        }
    }
}

fn write_dict_req<'a, 'buf>(
    method: &'buf str,
    path: &'buf str,
    headers: &'a HashMap<String, U<'a>>,
) -> std::io::Result<()> {
    let mut http = vec![("method", U::Text(method)), ("path", U::Text(path))]
        .into_iter()
        .collect();
    write_dict(http, headers)
}

fn write_dict_resp<'a, 'buf>(
    code: u16,
    reason: &'buf str,
    headers: &'a HashMap<String, U<'a>>,
) -> std::io::Result<()> {
    let mut http = vec![
        ("status", U::N6(code as u64)),
        ("status-text", U::Text(reason)),
    ]
    .into_iter()
    .collect();
    write_dict(http, headers)
}

fn write_dict<'buf, 'a>(
    mut http: HashMap<&str, U<'a>>,
    headers: &'a HashMap<String, U<'a>>,
) -> std::io::Result<()> {
    match http.insert(
        "headers",
        U::Record(
            headers
                .iter()
                .map(|(k, v)| (k.as_str(), v.clone()))
                .collect(),
        ),
    ) {
        None => (),
        Some(_) => panic!("read-http: headers already in dict"),
    };
    netencode::encode(&mut std::io::stdout(), &U::Record(http))?;
    Ok(())
}

// iter helper
// TODO: put into its own module
struct Chunkyboi<T> {
    inner: T,
    buf: Vec<u8>,
}

impl<R: Read> Chunkyboi<R> {
    fn new(inner: R, chunksize: usize) -> Self {
        let buf = vec![0; chunksize];
        Chunkyboi { inner, buf }
    }
}

impl<R: Read> Iterator for Chunkyboi<R> {
    type Item = std::io::Result<Vec<u8>>;

    fn next(&mut self) -> Option<std::io::Result<Vec<u8>>> {
        match self.inner.read(&mut self.buf) {
            Ok(0) => None,
            Ok(read) => {
                // clone a new buffer so we can reuse the internal one
                Some(Ok(self.buf[..read].to_owned()))
            }
            Err(err) => Some(Err(err)),
        }
    }
}
