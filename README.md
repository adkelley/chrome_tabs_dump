# chrome_tabs_dump

This utility is a macOS-only command-line tool that extracts open tab URLs from the frontmost Google Chrome window and prints them to stdout. It works by invoking
AppleScript via the system osascript command to query Chrome’s window and tab model, returning each tab’s URL as plain text. The program then processes this output,
splitting it into lines and trimming whitespace before printing the URLs to stdout.

The tool is intentionally small and dependency-light. The operating system handles browser introspection (via AppleScript), while the implementation language (e.g.,
Gleam) focuses on orchestration: executing the external command and parsing its output. This avoids fragile browser automation, extensions, or internal Chrome APIs,
making the utility stable across Chrome versions.

The result is a simple but powerful workflow tool: run a single command and get a clean snapshot of your current Chrome browsing context for the frontmost window.
Typical use cases include research session capture, tab cleanup, bookmarking, sharing reading lists, or feeding URLs into other tools (scrapers, archivers, LLM
pipelines). The design leaves room for future extensions—such as exporting JSON/CSV or adding Safari support—without complicating the core functionality.

If something goes wrong (for example, Chrome is not running), the tool prints a helpful error message to stderr.

```sh
gleam add chrome_tabs_dump@1
```
```gleam
import chrome_tabs_dump
import gleam/io
import gleam/list

pub fn main() -> Nil {
  // Fetches the frontmost Chrome window's tab URLs and prints them to stdout
  case chrome_tabs_dump.fetch_chrome_urls() {
    Ok(urls) -> {
      urls
      |> list.each(io.println)
      Nil
    }
    Error(message) -> io.println_error(message)
  }
}
```

Further documentation can be found at <https://hexdocs.pm/chrome_tabs_dump>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
