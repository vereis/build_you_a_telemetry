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

  @spec attach(handler_id(), event(), function(), opts :: keyword()) :: :ok
  defdelegate attach(handler_id, event, function, opts), to: HandlerTable

  @spec list_handlers(event()) :: list(function())
  defdelegate list_handlers(event), to: HandlerTable

  @spec execute(event(), measurements(), metadata()) :: :ok
  def execute(event, measurements, metadata) do
    for handler_function <- list_handlers(event),
        do: handler_function.(event, measurements, metadata)

    :ok
  end
end
