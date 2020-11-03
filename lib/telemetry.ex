defmodule Telemetry do
  @moduledoc """
  `Telemetry` acts as an interface to calling functions you define in
  response to certain events being raised.

  The expected flow is that `execute/3` is called in your business logic,
  which causes any attached event handlers to be executed synchronously.
  """

  alias Telemetry.HandlerTable

  defdelegate attach(handler_id, event, function, opts), to: HandlerTable

  defdelegate list_handlers(event), to: HandlerTable

  def execute(_event, _measurements, _metadata) do
    :ok
  end
end
