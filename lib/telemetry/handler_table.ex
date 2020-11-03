defmodule Telemetry.HandlerTable do
  @moduledoc """
  GenServer responsible for owning the ETS table that we use to persist
  any event handlers registered for any given events.
  """

  use GenServer

  defmodule State do
    @moduledoc false

    defstruct table: nil
  end

  # == Top level APIs ==
  @spec start_link(any()) :: {:ok, pid()} | {:error, reason :: any()} | :ignore
  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @spec attach(handler_id :: String.t(), Telemetry.event(), function(), options :: keyword()) ::
          :ok | {:error, :already_exists}
  def attach(handler_id, event, function, options) do
    GenServer.call(__MODULE__, {:attach, {handler_id, event, function, options}})
  end

  @spec list_handlers(Telemetry.event()) :: list(function())
  def list_handlers(event) do
    GenServer.call(__MODULE__, {:list, event})
  end

  @spec detach_handler(handler_id :: String.t(), Telemetry.event()) :: :ok | {:error, :not_found}
  def detach_handler(handler_id, event) do
    GenServer.call(__MODULE__, {:detach, {handler_id, event}})
  end

  # == Callbacks ==

  @impl GenServer
  def init(_args) do
    table = :ets.new(__MODULE__, [:protected, :duplicate_bag, read_concurrency: true])
    {:ok, %State{table: table}}
  end

  @impl GenServer
  def handle_call({:attach, {handler_id, event, function, options}}, _from, %State{} = state) do
    case :ets.match(state.table, {event, {handler_id, :_, :_}}) do
      [] ->
        true = :ets.insert(state.table, {event, {handler_id, function, options}})
        {:reply, :ok, state}

      _duplicate_id ->
        {:reply, {:error, :already_exists}, state}
    end
  end

  @impl GenServer
  def handle_call({:list, event}, _from, %State{} = state) do
    response =
      Enum.map(:ets.lookup(state.table, event), fn {^event, {handler_id, function, _opts}} ->
        {handler_id, function}
      end)

    {:reply, response, state}
  end

  @impl GenServer
  def handle_call({:detach, {handler_id, event}}, _from, %State{} = state) do
    case :ets.select_delete(state.table, [{{event, {handler_id, :_, :_}}, [], [true]}]) do
      0 ->
        {:reply, {:error, :not_found}, state}

      _deleted_count ->
        {:reply, :ok, state}
    end
  end
end
