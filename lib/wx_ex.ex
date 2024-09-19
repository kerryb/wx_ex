defmodule WxEx do
  @moduledoc false
  defmacro __using__(_opts) do
    quote do
      import WxEx.Constants.Gl
      import WxEx.Constants.Wx
      import WxEx.Records
    end
  end
end
