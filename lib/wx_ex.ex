defmodule WxEx do
  defmacro __using__(_opts) do
    quote do
      import WxEx.Constants
      import WxEx.Records
    end
  end
end
