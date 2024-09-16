defmodule WxObject do
  @moduledoc """
  An Elixir wrapper for Erlang’s `:wx_object` behaviour, inspired by
  `GenServer` etc.

  Does not yet support 100% of `:wx_object`’s API.

  TODO: add note about root object having to return a pid to be supervised.
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

  @optional_callbacks handle_call: 3, handle_cast: 2, handle_info: 2

  def start_link(module, args, options \\ []) do
    :wx_object.start_link(module, args, options)
  end

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
end
