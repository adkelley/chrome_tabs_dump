# chrome_tabs_dump

macOS CLI that prints the frontmost Google Chrome window’s tab URLs to stdout, or writes them to a file if you provide a filename.

If something goes wrong (for example, Chrome is not running), the tool prints a helpful error message to stderr.
If you pass an output filename without an extension, `.txt` is appended automatically.

Run with an optional output file:

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
