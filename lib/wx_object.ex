defmodule WxObject do
  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      @behaviour GenServer
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

      defoverridable child_spec: 1
    end
  end

  def start_link(module, args, options \\ []) do
    # case options[:name] do
    # nil ->
    :wx_object.start_link(module, args, options)

    # name when is_atom(name) -> :wx_object.start_link({:local, name}, module, args, Keyword.delete(options, :name))
    # end
  end

  defdelegate get_pid(ref), to: :wx_object
end
