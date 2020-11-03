defmodule TelemetryTest do
  use ExUnit.Case

  describe "attach/4" do
    test "returns :ok" do
      assert :ok = Telemetry.attach("test-handler-id", [:example, :event], fn -> :ok end, nil)
    end
  end

  describe "execute/3" do
    test "returns :ok" do
      assert :ok = Telemetry.execute([:example, :event], %{latency: 100}, %{status_code: "200"})
    end
  end
end
