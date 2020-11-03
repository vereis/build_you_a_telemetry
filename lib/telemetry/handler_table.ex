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
end
