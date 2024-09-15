defmodule WxObject do
  @moduledoc """
  An Elixir wrapper for Erlang’s `:wx_object` behaviour, inspired by (blatantly
  ripped off from) `GenServer` etc.
  """

  import WxEx.Records

  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      @behaviour WxObject
      use WxEx

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

      @doc false
      def handle_call(msg, _from, state) do
        proc =
          case Process.info(self(), :registered_name) do
            {_, []} -> self()
            {_, name} -> name
          end

        # We do this to trick Dialyzer to not complain about non-local returns.
        case :erlang.phash2(1, 1) do
          0 ->
            raise RuntimeError,
                  "attempted to call WxObject #{inspect(proc)} but no handle_call/3 clause was provided"

          1 ->
            {:stop, {:bad_call, msg}, state}
        end
      end

      @doc false
      def handle_cast(msg, state) do
        proc =
          case Process.info(self(), :registered_name) do
            {_, []} -> self()
            {_, name} -> name
          end

        # We do this to trick Dialyzer to not complain about non-local returns.
        case :erlang.phash2(1, 1) do
          0 ->
            raise "attempted to cast WxObject #{inspect(proc)} but no handle_cast/2 clause was provided"

          1 ->
            {:stop, {:bad_cast, msg}, state}
        end
      end

      defoverridable child_spec: 1, handle_call: 3, handle_cast: 2
    end
  end

  @callback init(args :: term()) ::
              {record(:wx_ref, ref: term(), type: term(), state: term()), state: term()}
              | {record(:wx_ref, ref: term(), type: term(), state: term()), state :: term(),
                 timeout() | :hibernate}
              | {:stop, reason :: term()}
              | :ignore

  @callback handle_call(request :: term(), from :: GenServer.server(), state :: term()) ::
              {:reply, reply, new_state}
              | {:reply, reply, new_state,
                 timeout | :hibernate | {:continue, continue_arg :: term()}}
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

  def start_link(module, args, options \\ []) do
    case options[:name] do
      nil ->
        :wx_object.start_link(module, args, options)

      name when is_atom(name) ->
        :wx_object.start_link({:local, name}, module, args, Keyword.delete(options, :name))
    end
  end

  @doc """
  Makes a synchronous call to the server and waits for its reply (see
  `GenServer.call/3` for details).
  """
  @spec call(GenServer.server(), term(), timeout()) :: term
  def call(server, request, timeout \\ 5000) do
    GenServer.call(server, request, timeout)
  catch
    :exit, {{error, stacktrace}, _call} -> reraise error, stacktrace
  end

  @doc """
  Casts a request to the server without waiting for a response (see
  `GenServer.cast/2` for details).
  """
  @spec cast(GenServer.server(), term()) :: term
  def cast(server, request) do
    GenServer.cast(server, request)
  end

  defdelegate get_pid(ref), to: :wx_object
end
