defmodule WxExTest do
  use ExUnit.Case, async: true
  use WxEx

  import Record

  describe "WxEx" do
    test "Generates wrappers for :wx constant macros" do
      assert wxALL() == 240
    end

    test "Generates wrappers for :gl constant macros" do
      assert gl_POINT() == 6912
    end

    test "Generates wrappers for records in include files" do
      assert is_record(WxEx.Records.wx())
    end

    test "Generates wrappers for records in src files" do
      assert is_record(WxEx.Records.wx_ref())
    end
  end
end
