defmodule WxObjectTest do
  use ExUnit.Case, async: true

  defmodule WxObjectOne do
    use WxObject

    def start_link(args) do
      wx_ref() = ref = WxObject.start_link(__MODULE__, args)
      {:ok, WxObject.get_pid(ref)}
    end

    def init(_arg) do
      :wx.new()
      frame = :wxFrame.new(:wx.null(), 1, "")
      {frame, nil}
    end
  end

  test "Wraps :wx_object.start_link/3, and generates a default child_spec/1 implementation" do
    {:ok, pid} = start_supervised(WxObjectOne)
    assert is_pid(pid)
  end
end
