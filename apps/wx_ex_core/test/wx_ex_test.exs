defmodule WxExTest do
  use ExUnit.Case, async: true

  describe "WxEx" do
    test "Generates wrappers for :ex constant macros" do
      assert WxEx.Constants.wxALL == 240
    end
  end
end
