defmodule Telemetry.HandlerTable do
  use GenServer

  defmodule State do
    defstruct table: nil
  end

  # == Top level APIs ==
  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def attach(id, event, function, options) do
    GenServer.call(__MODULE__, {:attach, {id, event, function, options}})
  end

  def list_handlers(event) do
    GenServer.call(__MODULE__, {:list, event})
  end

  # == Callbacks ==

  @impl GenServer
  def init(_args) do
    table = :ets.new(__MODULE__, [:protected, :duplicate_bag, read_concurrency: true])
    {:ok, %State{table: table}}
  end

  @impl GenServer
  def handle_call({:attach, {id, event, function, options}}, _from, %State{} = state) do
    true = :ets.insert(state.table, {event, {id, function, options}})
    {:reply, :ok, state}
  end

  @impl GenServer
  def handle_call({:list, event}, _from, %State{} = state) do
    handler_functions =
      Enum.map(:ets.lookup(state.table, event), fn {^event, {_id, function, _opts}} ->
        function
      end)

    {:reply, handler_functions, state}
  end
end
