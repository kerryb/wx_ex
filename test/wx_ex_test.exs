defmodule WxExTest do
  use ExUnit.Case, async: true
  import Record
  require WxEx.Records

  describe "WxEx" do
    test "Generates wrappers for :ex constant macros" do
      assert WxEx.Constants.wxALL() == 240
    end

    test "Generates wrappers for records in include files" do
      assert is_record(WxEx.Records.wx())
    end

    test "Generates wrappers for records in src files" do
      assert is_record(WxEx.Records.wx_ref())
    end

    test "Imports all constants and macros with `use WxEx`" do
      use WxEx
      assert wxALL() == 240
      assert is_record(wx())
    end
  end
end
