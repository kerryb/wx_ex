defmodule WxObjectTest do
  use ExUnit.Case, async: true

  defmodule BasicWxObject do
    @moduledoc false
    use WxObject

    def start_link(_arg), do: WxObject.start_link(__MODULE__, [], name: __MODULE__)

    @impl WxObject
    def init(_args), do: {:wxFrame.new(:wx.null(), 1, ""), %{}}

    @impl WxObject
    def handle_event(_event, state), do: {:noreply, state}
  end

  defmodule FullWxObject do
    @moduledoc false
    use WxObject

    require Record

    def start_link(parent_pid), do: WxObject.start_link(__MODULE__, [parent_pid])

    @impl WxObject
    def init(parent_pid), do: {:wxFrame.new(:wx.null(), 1, ""), %{parent: parent_pid}}

    @impl WxObject
    def handle_event({:wx, _, _, _, _}, state) do
      send(state.parent, :pong)
      {:noreply, state}
    end

    @impl WxObject
    def handle_call(:ping, _from, state), do: {:reply, :pong, state}

    @impl WxObject
    def handle_cast(:ping, state) do
      send(state.parent, :pong)
      {:noreply, state}
    end

    @impl WxObject
    def handle_info(:ping, state) do
      send(state.parent, :pong)
      {:noreply, state}
    end

    @impl WxObject
    def terminate(reason, state) do
      send(state.parent, {:terminated, reason})
    end
  end

  describe "WxObject" do
    setup do
      :wx.new()
      :ok
    end

    test "allows a name and options to be specified" do
      obj = WxObject.start_link(:my_object, BasicWxObject, [], [])
      assert WxObject.get_pid(obj) == Process.whereis(:my_object)
    end

    test "allows name and options to be omitted" do
      obj = WxObject.start_link(BasicWxObject, [])
      assert is_pid(WxObject.get_pid(obj))
    end

    test "allows a name but no options to be specified" do
      obj = WxObject.start_link(:my_object, BasicWxObject, [])
      assert WxObject.get_pid(obj) == Process.whereis(:my_object)
    end

    test "allows options but no name to be specified" do
      obj = WxObject.start_link(BasicWxObject, [], [])
      assert is_pid(WxObject.get_pid(obj))
    end

    test "forwards events" do
      obj = WxObject.start_link(FullWxObject, self())
      obj |> WxObject.get_pid() |> send({:wx, 1, {:wx_ref, 35, :wxFrame, []}, [], {:wxClose, :close_window}})
      assert_receive :pong
    end

    test "forwards calls" do
      obj = WxObject.start_link(FullWxObject, self())
      assert WxObject.call(obj, :ping) == :pong
    end

    test "forwards casts" do
      obj = WxObject.start_link(FullWxObject, self())
      WxObject.cast(obj, :ping)
      assert_receive :pong
    end

    test "forwards other messages" do
      obj = WxObject.start_link(FullWxObject, self())
      obj |> WxObject.get_pid() |> send(:ping)
      assert_receive :pong
    end

    test "ignores messages when handle_info/2 is not implemented" do
      obj = WxObject.start_link(FullWxObject, self())
      obj |> WxObject.get_pid() |> send(:ping)
      assert Process.alive?(WxObject.get_pid(obj))
    end

    test "implements stop/3, with a terminate/2 callback" do
      obj = WxObject.start_link(FullWxObject, self())
      WxObject.stop(obj)
      assert_receive {:terminated, :normal}
    end

    # Can’t figure out how to test the stuff below with actual events.

    test "has a handle_sync_event/3 callback" do
      assert {:handle_sync_event, 3} in WxObject.behaviour_info(:callbacks)
    end

    test "has a code_change/3 callback" do
      assert {:code_change, 3} in WxObject.behaviour_info(:callbacks)
    end
  end
end
