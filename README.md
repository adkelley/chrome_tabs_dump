# chrome_tabs_dump

This utility is a macOS-only command-line tool that extracts open tab URLs from the frontmost Google Chrome window and prints them to stdout (or writes them to a file
if a filename is provided). It works by invoking AppleScript via the system osascript command to query Chrome’s window and tab model, returning each tab’s URL as
plain text. The program then processes this output, splitting it into lines and trimming whitespace before printing the URLs to stdout.

The tool is intentionally small and dependency-light. The operating system handles browser introspection (via AppleScript), while the implementation language
focuses on orchestration: executing the external command and parsing its output. This avoids fragile browser automation, extensions, or internal Chrome APIs, making
the utility stable across Chrome versions.

The result is a simple but powerful workflow tool: run a single command and get a clean snapshot of your current Chrome browsing context for the frontmost window.
Typical use cases include research session capture, tab cleanup, bookmarking, sharing reading lists, or feeding URLs into other tools (scrapers, archivers, LLM
pipelines). The design leaves room for future extensions—such as exporting JSON/CSV or adding Safari support—without complicating the core functionality.

If something goes wrong (for example, Chrome is not running), the tool prints a helpful error message to stderr.
If you pass an output filename without an extension, `.txt` is appended automatically.

You can also run the CLI with an optional output file:

```sh
gleam run -- tabs
```

This writes `tabs.txt`. If you include an extension (e.g. `tabs.md`), it is used as-is.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```

## Executable

You can build a standalone executable using `gleescript`:

```sh
gleam run -m gleescript
```

By default (no name provided), this generates `./chrome_tabs_dump`. Run it directly:

```sh
./chrome_tabs_dump
```
