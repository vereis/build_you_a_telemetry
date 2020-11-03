defmodule Telemetry do
  @moduledoc """
  `Telemetry` acts as an interface to calling functions you define in
  response to certain events being raised.

  The expected flow is that `execute/3` is called in your business logic,
  which causes any attached event handlers to be executed synchronously.
  """

  @type handler_id :: String.t()
  @type event :: list(atom)
  @type measurements :: map()
  @type metadata :: map()

  alias Telemetry.HandlerTable

  require Logger

  @spec attach(handler_id(), event(), function(), opts :: keyword()) :: :ok
  defdelegate attach(handler_id, event, function, opts), to: HandlerTable

  @spec list_handlers(event()) :: list(function())
  defdelegate list_handlers(event), to: HandlerTable

  @spec detach_handler(handler_id(), event()) :: :ok
  defdelegate detach_handler(handler_id, event), to: HandlerTable

  @spec execute(event(), measurements(), metadata()) :: :ok
  def execute(event, measurements, metadata) do
    for {handler_id, handler_function} <- list_handlers(event) do
      try do
        handler_function.(event, measurements, metadata)
      rescue
        error ->
          log_error(event, handler_id, error, __STACKTRACE__)

          detach_handler(handler_id, event)
      catch
        error ->
          log_error(event, handler_id, error, __STACKTRACE__)

          detach_handler(handler_id, event)
      end
    end

    :ok
  end

  defp log_error(event, handler, error, stacktrace) do
    Logger.error("""
    Handler #{inspect(handler)} for event #{inspect(event)} has failed and has been detached.
    Error: #{inspect(error)}
    Stacktrace: #{inspect(stacktrace)}
    """)
  end
end
