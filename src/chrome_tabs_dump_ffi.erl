%% FFI helpers for Gleam.
-module(chrome_tabs_dump_ffi).
-export([os_cmd/1]).

os_cmd(Command) when is_binary(Command) ->
  os_cmd(binary_to_list(Command));
os_cmd(Command) when is_list(Command) ->
  list_to_binary(os:cmd(Command)).
