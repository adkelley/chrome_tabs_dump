import gleam/int
import gleam/io
import gleam/list
import gleam/string

pub fn main() -> Nil {
  case fetch_chrome_urls() {
    Ok(urls) -> {
      urls
      |> list.each(io.println)
      Nil
    }
    Error(message) -> io.println_error(message)
  }
}

/// Fetch tab URLs from the frontmost Google Chrome window.
pub fn fetch_chrome_urls() -> Result(List(String), String) {
  let raw_output = os_cmd(osascript_command())
  case split_exit_code(raw_output) {
    Ok(#(output, 0)) -> Ok(parse_urls(output))
    Ok(#(output, code)) -> {
      let message = case string.trim(output) {
        "" ->
          "Failed to read Chrome tabs. osascript exited with code "
          <> int.to_string(code)
        trimmed -> "Failed to read Chrome tabs: " <> trimmed
      }
      Error(message)
    }
    Error(message) -> Error(message)
  }
}

// Parse newline-separated URLs into a clean list.
fn parse_urls(output: String) -> List(String) {
  output
  |> string.split(on: "\n")
  |> list.map(string.trim)
  |> list.map(trim_trailing_slash)
  |> list.filter(fn(url) { url != "" })
}

/// Parse newline-separated URLs into a clean list.
/// This is marked internal for tests and is not part of the public API.
@internal
pub fn parse_urls_for_test(output: String) -> List(String) {
  parse_urls(output)
}

// Remove a single trailing slash for consistent comparisons.
fn trim_trailing_slash(url: String) -> String {
  case string.ends_with(url, "/") {
    True -> string.slice(from: url, at_index: 0, length: string.length(url) - 1)
    False -> url
  }
}

// Separate the osascript output from the appended exit code marker.
fn split_exit_code(output: String) -> Result(#(String, Int), String) {
  let marker = "__EXIT:"
  case string.split_once(output, on: marker) {
    Ok(#(body, rest)) ->
      case string.split_once(rest, on: "__") {
        Ok(#(code_string, _)) ->
          case int.parse(string.trim(code_string)) {
            Ok(code) -> Ok(#(body, code))
            Error(_) -> Error("Failed to parse osascript exit code.")
          }
        Error(_) -> Error("Missing osascript exit code marker.")
      }
    Error(_) -> Error("Missing osascript exit code marker.")
  }
}

// Build the osascript command for reading the frontmost Chrome window.
fn osascript_command() -> String {
  "osascript "
  <> "-e 'tell application \"Google Chrome\"' "
  <> "-e 'set _out to \"\"' "
  <> "-e 'set w to front window' "
  <> "-e 'repeat with t in tabs of w' "
  <> "-e 'set _out to _out & (URL of t) & linefeed' "
  <> "-e 'end repeat' "
  <> "-e 'return _out' "
  <> "-e 'end tell' "
  <> "2>&1; printf '__EXIT:%s__' $?"
}

// Execute a shell command and capture its stdout/stderr as a string.
@external(erlang, "chrome_tabs_dump_ffi", "os_cmd")
fn os_cmd(command: String) -> String
