defmodule WxObjectTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureLog

  defmodule BasicWxObject do
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

  defmodule FullWxObject do
    use WxObject

    def start_link(args) do
      wx_ref() = ref = WxObject.start_link(__MODULE__, args, name: __MODULE__)
      {:ok, WxObject.get_pid(ref)}
    end

    def init(_arg) do
      :wx.new()
      frame = :wxFrame.new(:wx.null(), 1, "")
      {frame, nil}
    end

    def handle_call(:ping, _from, state) do
      {:reply, :pong, state}
    end

    def handle_cast({:ping, from}, state) do
      send(from, :pong)
      {:noreply, state}
    end
  end

  describe "WxObject" do
    test "Wraps :wx_object.start_link/3, and generates a default child_spec/1 implementation" do
      pid = start_supervised!(BasicWxObject)
      assert is_pid(pid)
    end

    test "Allows specification of a server name" do
      start_supervised!(FullWxObject)
      assert is_pid(GenServer.whereis(FullWxObject))
    end

    test "forwards calls" do
      pid = start_supervised!(FullWxObject)
      assert WxObject.call(pid, :ping) == :pong
    end

    test "raises a helpful error on call when handle_call/3 is not implemented" do
      pid = start_supervised!(BasicWxObject)

      assert_raise(
        RuntimeError,
        "attempted to call WxObject #{inspect(pid)} but no handle_call/3 clause was provided",
        fn -> capture_log(fn -> WxObject.call(pid, :ping) end) end
      )
    end

    test "forwards casts" do
      pid = start_supervised!(FullWxObject)
      WxObject.cast(pid, {:ping, self()})
      assert_receive :pong
    end

    test "raises a helpful error on cast when handle_cast/2 is not implemented" do
      pid = start_supervised!(BasicWxObject)

      assert capture_log(fn ->
               WxObject.cast(pid, :ping)
               refute_receive(:pong)
             end) =~
               "attempted to cast WxObject #{inspect(pid)} but no handle_cast/2 clause was provided"

    end
  end
end
