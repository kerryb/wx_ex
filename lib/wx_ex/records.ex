defmodule WxEx.Records do
  @moduledoc """
  `Record` wrappers for all the records defined in any header files under
  `include` and `src` in `:wx`.

  ## Usage

  ```elixir
  import WxEx.Records

  event = wx() #=> {:wx, :undefined, :undefined, :undefined, :undefined}
  wx(event) #=> [id: :undefined, obj: :undefined, userData: :undefined, event: :undefined]
  ```
  """

  require Record

  @lib_dir ~C"wx" |> :code.lib_dir() |> to_string()

  @lib_dir
  |> Path.join("{include,src}/**/*.hrl")
  |> Path.wildcard()
  |> Enum.flat_map(&Record.extract_all(from_lib: "wx/#{Path.relative_to(&1, @lib_dir)}"))
  |> Enum.each(fn {name, fields} -> Record.defrecord(name, fields) end)
end
