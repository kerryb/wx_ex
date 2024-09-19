defmodule WxEx do
  @moduledoc false
  defmacro __using__(_opts) do
    quote do
      import WxEx.Constants.OpenGL
      import WxEx.Constants.WxWidgets
      import WxEx.Records
    end
  end
end
