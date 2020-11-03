defmodule TelemetryTest do
  use ExUnit.Case

  describe "attach/4" do
    test "returns :ok" do
      assert :ok =
               Telemetry.attach(
                 "test-handler-id",
                 [:example, :event],
                 fn _, _, _ -> :ok end,
                 nil
               )
    end
  end

  describe "execute/3" do
    test "returns :ok" do
      assert :ok = Telemetry.execute([:example, :event], %{latency: 100}, %{status_code: "200"})
    end

    test "returns :ok, any attached handlers are executed" do
      test_process = self()

      assert :ok =
               Telemetry.attach(
                 "test-handler-id",
                 [:example, :event],
                 fn _, _, _ ->
                   send(test_process, :first_handler_executed)
                 end,
                 nil
               )

      assert :ok =
               Telemetry.attach(
                 "test-handler-id",
                 [:example, :event],
                 fn _, _, _ ->
                   send(test_process, :second_handler_executed)
                 end,
                 nil
               )

      assert :ok = Telemetry.execute([:example, :event], %{latency: 100}, %{status_code: "200"})

      assert_received(:first_handler_executed)
      assert_received(:second_handler_executed)
    end
  end
end
