defmodule Mix.Tasks.Compile.Wx do
  @moduledoc """
  Compiler to produce an erlang source file in `src/wx_constants.erl`,
  containing wrapper functions for all the wxWidgets static macros.
  """
  use Mix.Task.Compiler

  @wx_header_path :code.lib_dir(~C"wx") |> to_string() |> Path.join("include/wx.hrl")
  @wx_constants_path "src/wx_constants.erl"

  def run(_args) do
    @wx_constants_path |> Path.dirname() |> File.mkdir_p!()

    File.open(@wx_constants_path, [:write], fn file ->
      IO.write(file, """
      %% @doc Function wrappers for the macros defined in wx.hrl. Note that all
      %% functions begin with lower case "wx": for example WXK_NONE is wrapped
      %% with the function wxK_NONE/0.

      -module(wx_constants).
      -compile(nowarn_export_all).
      -compile(export_all).
      -include_lib("wx/include/wx.hrl").

      """)

      @wx_header_path
      |> File.stream!(:line)
      |> generate_functions()
      |> Enum.each(&IO.write(file, &1))
    end)

    :ok
  end

  defp generate_functions(stream) do
    stream
    |> Stream.filter(&is_constant_macro?/1)
    |> Stream.map(&generate_function/1)
  end

  defp is_constant_macro?("-define(" <> _), do: true
  defp is_constant_macro?(_), do: false

  defp generate_function(line),
    do: String.replace(line, ~r/-define\((wx)(\w*).*/i, "wx\\2() -> ?\\1\\2.")

  # defp generate_function(line) do
  #   String.replace(line, ~r/-define\((\w*).*/, fn macro ->
  #     "#{String.replace(macro, ~r/^WX/, "wx")}() -> ?#{macro}."
  #   end)
  # end

  def clean do
    File.rm_rf!(@wx_constants_path)
  end
end
