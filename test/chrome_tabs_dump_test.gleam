import chrome_tabs_dump
import gleam/erlang/process
import gleam/io
import gleam/list
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

// Open a new Chrome window with example.com and gleam.run as tabs.
pub fn open_front_page_with_two_tabs() -> Nil {
  os_cmd(
    "open -na \"Google Chrome\" --args --new-window https://example.com https://gleam.run",
  )
  Nil
}

// gleeunit test functions end in `_test`
pub fn a_open_front_page_with_two_tabs_test() {
  open_front_page_with_two_tabs()
  Nil
}

pub fn b_front_window_has_example_and_gleam_test() {
  open_front_page_with_two_tabs()
  let urls = case fetch_urls_with_retry(10) {
    Ok(urls) -> urls
    Error(message) -> {
      io.println_error(message)
      []
    }
  }

  let correct_count = list.length(urls) == 2
  let has_example = list.contains(urls, "https://example.com")
  let has_gleam = list.contains(urls, "https://gleam.run")

  assert correct_count && has_example && has_gleam
}

pub fn c_parse_urls_trims_trailing_slash_test() {
  let output = "https://example.com/\nhttps://gleam.run/\n"
  let urls = chrome_tabs_dump.parse_urls_for_test(output)

  assert urls == ["https://example.com", "https://gleam.run"]
}

// Retry fetching URLs to allow Chrome to finish opening tabs.
fn fetch_urls_with_retry(attempts: Int) -> Result(List(String), String) {
  case chrome_tabs_dump.fetch_chrome_urls() {
    Ok(urls) -> Ok(urls)
    Error(message) ->
      case attempts <= 1 {
        True -> Error(message)
        False -> {
          process.sleep(1000)
          fetch_urls_with_retry(attempts - 1)
        }
      }
  }
}

@external(erlang, "chrome_tabs_dump_ffi", "os_cmd")
fn os_cmd(command: String) -> String
