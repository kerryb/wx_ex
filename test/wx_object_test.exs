defmodule WxObjectTest do
  use ExUnit.Case, async: true

  defmodule BasicWxObject do
    @moduledoc false
    use WxObject

    def start_link(args), do: WxObject.start_link(__MODULE__, args)

    def init(_arg), do: {:wxFrame.new(:wx.null(), 1, ""), :some_state}
  end

  defmodule FullWxObject do
    @moduledoc false
    use WxObject

    def start_link(args), do: WxObject.start_link(__MODULE__, args, name: __MODULE__)

    def init(_arg), do: {:wxFrame.new(:wx.null(), 1, ""), :some_state}

    def handle_call(:ping, _from, state), do: {:reply, :pong, state}

    def handle_cast({:ping, from}, state) do
      send(from, :pong)
      {:noreply, state}
    end

    def handle_info({:ding, from}, state) do
      send(from, :dong)
      {:noreply, state}
    end
  end

  describe "WxObject" do
    setup do
      :wx.new()
      :ok
    end

    test "Wraps :wx_object.start_link/3, and generates a default child_spec/1 implementation" do
      obj = WxObject.start_link(BasicWxObject, [])
      assert is_pid(WxObject.get_pid(obj))
    end

    test "forwards calls" do
      obj = WxObject.start_link(FullWxObject, [])
      assert WxObject.call(obj, :ping) == :pong
    end

    test "forwards casts" do
      obj = WxObject.start_link(FullWxObject, [])
      WxObject.cast(obj, {:ping, self()})
      assert_receive :pong
    end

    test "forwards other messages" do
      obj = WxObject.start_link(FullWxObject, [])
      obj |> WxObject.get_pid() |> send({:ding, self()})
      assert_receive :dong
    end

    test "ignores messages when handle_info/2 is not implemented" do
      obj = WxObject.start_link(BasicWxObject, [])
      obj |> WxObject.get_pid() |> send(:ping)
      refute_receive(:pong)
    end
  end
end
