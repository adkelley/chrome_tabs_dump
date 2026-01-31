import argv
import filepath
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() -> Nil {
  let args = argv.load().arguments
  case fetch_chrome_urls() {
    Ok(urls) ->
      case args {
        [] -> {
          urls
          |> list.each(io.println)
          Nil
        }
        [path] -> write_urls_to_file(path, urls)
        _ ->
          io.println_error(
            "Usage: chrome_tabs_dump [output_file]",
          )
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

// Write URLs to a file, adding a .txt extension if none is provided.
fn write_urls_to_file(path: String, urls: List(String)) -> Nil {
  let output_path = ensure_extension(path)
  let contents = string.join(urls, with: "\n") <> "\n"
  case simplifile.write(to: output_path, contents: contents) {
    Ok(Nil) -> Nil
    Error(error) ->
      io.println_error(
        "Failed to write file: " <> simplifile.describe_error(error),
      )
  }
}

// Ensure a filename has an extension, defaulting to .txt.
fn ensure_extension(path: String) -> String {
  case filepath.extension(path) {
    Ok(_) -> path
    Error(_) -> path <> ".txt"
  }
}

/// Ensure a filename has an extension, defaulting to .txt.
/// This is marked internal for tests and is not part of the public API.
@internal
pub fn ensure_extension_for_test(path: String) -> String {
  ensure_extension(path)
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
