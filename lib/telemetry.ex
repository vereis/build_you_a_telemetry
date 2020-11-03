defmodule Telemetry do
  @moduledoc """
  `Telemetry` acts as an interface to calling functions you define in
  response to certain events being raised.

  The expected flow is that `execute/3` is called in your business logic,
  which causes any attached event handlers to be executed synchronously.
  """

  def execute(_event, _measurements, _metadata) do
    :ok
  end
end
