defmodule WxObjectTest do
  use ExUnit.Case, async: true

  defmodule AnonymousWxObject do
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

  defmodule NamedWxObject do
    use WxObject

    def start_link(args) do
      wx_ref() = ref = WxObject.start_link(__MODULE__, args, name: NamedWxObject)
      {:ok, WxObject.get_pid(ref)}
    end

    def init(_arg) do
      :wx.new()
      frame = :wxFrame.new(:wx.null(), 1, "")
      {frame, nil}
    end
  end

  describe "WxObject" do
    test "Wraps :wx_object.start_link/3, and generates a default child_spec/1 implementation" do
      {:ok, pid} = start_supervised(AnonymousWxObject)
      assert is_pid(pid)
    end

    test "Allows specification of a server name" do
      start_supervised!(NamedWxObject)
      assert is_pid(GenServer.whereis(NamedWxObject))
    end
  end
end
