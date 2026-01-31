import gleam/io
import gleam/list
import chrome_tabs_dump/api

pub fn main() -> Nil {
  case api.fetch_chrome_urls() {
    Ok(urls) -> {
      urls
      |> list.each(io.println)
      Nil
    }
    Error(message) -> io.println_error(message)
  }
}
