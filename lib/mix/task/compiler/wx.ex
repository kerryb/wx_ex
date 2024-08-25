defmodule Mix.Tasks.Compile.Wx do
  @moduledoc """
  Compiler to produce an erlang source file in `src/wx_constants.erl`,
  containing wrapper functions for all the wxWidgets static macros.
  """
  use Mix.Task.Compiler

  @wx_header_path :code.lib_dir(~C"wx") |> to_string() |> Path.join("include/wx.hrl")
  @wx_constants_erl_path "src/wx_constants.erl"
  @wx_constants_ex_path "lib/generated/wx_ex/constants.ex"

  def run(_args) do
    @wx_constants_erl_path |> Path.dirname() |> File.mkdir_p!()
    wx_erl_constants = File.open!(@wx_constants_erl_path, [:write])

    @wx_constants_ex_path |> Path.dirname() |> File.mkdir_p!()
    wx_ex_constants = File.open!(@wx_constants_ex_path, [:write])

    IO.write(wx_erl_constants, """
    %% THIS FILE IS AUTOMATICALLY GENERATED
    %%
    %% @doc Function wrappers for the macros defined in wx.hrl. Note that all
    %% functions begin with lower case "wx": for example WXK_NONE is wrapped
    %% with the function wxK_NONE/0.

    -module(wx_constants).
    -compile(nowarn_export_all).
    -compile(export_all).
    -include_lib("wx/include/wx.hrl").

    """)

    IO.write(wx_ex_constants, ~S'''
    # THIS FILE IS AUTOMATICALLY GENERATED

    defmodule WxEx.Constants do
      @moduledoc """
      Function wrappers for the macros defined in `wx.hrl`. Note that all
      functions begin with lower case "wx": for example `WXK_NONE` is wrapped
      with the function `wxK_NONE/0`.
      """

    ''')

    @wx_header_path
    |> File.stream!(:line)
    |> Stream.filter(&is_constant_macro?/1)
    |> Enum.each(fn line ->
      IO.write(wx_erl_constants, generate_erl_function(line))
      IO.write(wx_ex_constants, generate_ex_function(line))
    end)

    IO.puts(wx_ex_constants, "end")

    File.close(wx_erl_constants)
    File.close(wx_ex_constants)
    :ok
  end

  defp is_constant_macro?("-define(" <> _), do: true
  defp is_constant_macro?(_), do: false

  defp generate_erl_function(line) do
    String.replace(line, ~r/-define\((wx)(\w*).*/i, "wx\\2() -> ?\\1\\2.")
  end

  defp generate_ex_function(line) do
    String.replace(line, ~r/-define\((wx)(\w*).*/i, "  def wx\\2, do: :wx_constants.wx\\2()")
  end

  def clean do
    File.rm_rf!(@wx_constants_erl_path)
    File.rm_rf!(@wx_constants_ex_path)
  end
end
