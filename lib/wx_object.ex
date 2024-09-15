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

      defoverridable child_spec: 1, handle_call: 3
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

  def start_link(module, args, options \\ []) do
    case options[:name] do
      nil ->
        :wx_object.start_link(module, args, options)

      name when is_atom(name) ->
        :wx_object.start_link({:local, name}, module, args, Keyword.delete(options, :name))
    end
  end

  @doc """
  Makes a synchronous call to the `server` and waits for its reply.

  The client sends the given `request` to the server and waits until a reply
  arrives or a timeout occurs. `c:handle_call/3` will be called on the server
  to handle the request.

  `server` can be any of the values described in the "Name registration"
  section of the documentation for this module.

  ## Timeouts

  `timeout` is an integer greater than zero which specifies how many
  milliseconds to wait for a reply, or the atom `:infinity` to wait
  indefinitely. The default value is `5000`. If no reply is received within
  the specified time, the function call fails and the caller exits. If the
  caller catches the failure and continues running, and the server is just late
  with the reply, it may arrive at any time later into the caller's message
  queue. The caller must in this case be prepared for this and discard any such
  garbage messages that are two-element tuples with a reference as the first
  element.
  """
  @spec call(GenServer.server(), term(), timeout()) :: term
  def call(server, request, timeout \\ 5000)
      when (is_integer(timeout) and timeout >= 0) or timeout == :infinity do
    case GenServer.whereis(server) do
      nil ->
        exit({:noproc, {__MODULE__, :call, [server, request, timeout]}})

      pid ->
        try do
          :wx_object.call(pid, request, timeout)
        rescue
          e ->
            case e do
              %{original: {{%RuntimeError{} = error, stacktrace}, _call}} ->
                reraise error, stacktrace

              _ ->
                reraise e, __STACKTRACE__
            end
        catch
          :exit, reason ->
            exit({reason, {__MODULE__, :call, [server, request, timeout]}})
          {:ok, res} -> res
        end
    end
  end

  defdelegate get_pid(ref), to: :wx_object
end
