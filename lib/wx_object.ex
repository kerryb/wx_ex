defmodule WxObject do
  @moduledoc """
  An Elixir wrapper for Erlang’s `:wx_object` behaviour, inspired by
  `GenServer` etc.

  Does not yet support 100% of `:wx_object`’s API. Specifically,
  `handle_sync_event/2` is not yet implemented.

  Unlike `GenServer`, `WxObject` returns a `wxWindow` reference rather than a
  pid. If you want to include your top level object in your supervision tree,
  you will need to return the pid from `start_link`. For example:

  ```elixir
  def start_link(_arg) do
    ref = WxObject.start_link(__MODULE__, nil, name: __MODULE__)
    {:ok, WxObject.get_pid(ref)}
  end
  ```
  """

  import WxEx.Records

  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      @behaviour WxObject

      use WxEx

      require Logger

      unless Module.has_attribute?(__MODULE__, :doc) do
        @doc """
        Returns a specification to start this module under a supervisor.

        See `Supervisor`.
        """
      end

      def child_spec(init_arg) do
        default = %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [init_arg]}
        }

        Supervisor.child_spec(default, unquote(Macro.escape(opts)))
      end

      defoverridable child_spec: 1
    end
  end

  @callback init(args :: term()) ::
              {record(:wx_ref, ref: term(), type: term(), state: term()), state: term()}
              | {record(:wx_ref, ref: term(), type: term(), state: term()), state :: term(), timeout() | :hibernate}
              | {:stop, reason :: term()}
              | :ignore

  @callback handle_event(
              request :: record(:wx, id: integer(), obj: :wx.wx_object(), userData: term(), event: tuple()),
              state :: term()
            ) ::
              {:noreply, new_state :: term()}
              | {:noreply, new_state :: term(), timeout() | :hibernate}
              | {:stop, reason :: term(), new_state :: term()}

  @callback handle_sync_event(
              request :: record(:wx, id: integer(), obj: :wx.wx_object(), userData: term(), event: tuple()),
              ref :: record(:wx_ref, ref: term(), type: term(), state: term()),
              state :: term()
            ) :: :ok

  @callback handle_call(request :: term(), from :: GenServer.server(), state :: term()) ::
              {:reply, reply, new_state}
              | {:reply, reply, new_state, timeout | :hibernate | {:continue, continue_arg :: term()}}
              | {:noreply, new_state}
              | {:noreply, new_state, timeout | :hibernate | {:continue, continue_arg :: term()}}
              | {:stop, reason, reply, new_state}
              | {:stop, reason, new_state}
            when reply: term(), new_state: term(), reason: term()

  @callback handle_cast(request :: term(), state :: term()) ::
              {:noreply, new_state}
              | {:noreply, new_state, timeout | :hibernate | {:continue, continue_arg :: term()}}
              | {:stop, reason :: term(), new_state}
            when new_state: term()

  @callback handle_info(msg :: :timeout | term(), state :: term()) ::
              {:noreply, new_state}
              | {:noreply, new_state, timeout | :hibernate | {:continue, continue_arg :: term()}}
              | {:stop, reason :: term(), new_state}
            when new_state: term()

  @callback terminate(reason, state :: term()) :: term()
            when reason: :normal | :shutdown | {:shutdown, term()} | term()

  @optional_callbacks handle_sync_event: 3, handle_call: 3, handle_cast: 2, handle_info: 2, terminate: 2

  def start_link(name, module, args, options) when is_atom(module),
    do: :wx_object.start_link({:local, name}, module, args, options)

  def start_link(name, module, args) when is_atom(module), do: :wx_object.start_link({:local, name}, module, args, [])
  def start_link(module, args, options), do: :wx_object.start_link(module, args, options)
  def start_link(module, args), do: :wx_object.start_link(module, args, [])

  @doc """
  Make a synchronous call to the server and wait for its reply.
  """
  @spec call(:wx.wx_object(), term(), timeout()) :: term
  defdelegate call(obj, request, timeout \\ 5000), to: :wx_object

  @doc """
  Cast a request to the server without waiting for a response.
  """
  @spec cast(:wx.wx_object(), term()) :: term
  defdelegate cast(obj, request), to: :wx_object

  @spec get_pid(:wx.wx_object() | atom() | pid()) :: pid()
  defdelegate get_pid(obj), to: :wx_object

  @spec stop(:wx.wx_object(), term(), timeout()) :: :ok
  defdelegate stop(server, reason \\ :normal, timeout \\ :infinity), to: :wx_object
end
