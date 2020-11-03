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
                 "test-handler-id-1",
                 [:example, :event],
                 fn _, _, _ ->
                   send(test_process, :first_handler_executed)
                 end,
                 nil
               )

      assert :ok =
               Telemetry.attach(
                 "test-handler-id-2",
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

    test "returns :ok, any attached handlers that raise exceptions are detached" do
      test_process = self()

      assert :ok =
               Telemetry.attach(
                 "detach-raise-handler-test-id-1",
                 [:detach, :raise, :event],
                 fn _, _, _ ->
                   send(test_process, :first_handler_executed)
                 end,
                 nil
               )

      assert :ok =
               Telemetry.attach(
                 "detach-raise-handler-test-id-2",
                 [:detach, :raise, :event],
                 fn _, _, _ ->
                   raise ArgumentError, message: "invalid argument foo"
                 end,
                 nil
               )

      assert length(Telemetry.list_handlers([:detach, :raise, :event])) == 2

      assert :ok =
               Telemetry.execute([:detach, :raise, :event], %{latency: 100}, %{status_code: "200"})

      assert_received(:first_handler_executed)

      assert length(Telemetry.list_handlers([:detach, :raise, :event])) == 1

      assert {:error, :not_found} =
               Telemetry.detach_handler("detach-raise-handler-test-id-2", [
                 :detach,
                 :raise,
                 :event
               ])
    end

    test "returns :ok, any attached handlers that throw exceptions are detached" do
      test_process = self()

      assert :ok =
               Telemetry.attach(
                 "detach-throw-handler-test-id-1",
                 [:detach, :throw, :event],
                 fn _, _, _ ->
                   send(test_process, :first_handler_executed)
                 end,
                 nil
               )

      assert :ok =
               Telemetry.attach(
                 "detach-throw-handler-test-id-2",
                 [:detach, :throw, :event],
                 fn _, _, _ ->
                   throw("exception")
                 end,
                 nil
               )

      assert length(Telemetry.list_handlers([:detach, :throw, :event])) == 2

      assert :ok =
               Telemetry.execute([:detach, :throw, :event], %{latency: 100}, %{status_code: "200"})

      assert_received(:first_handler_executed)

      assert length(Telemetry.list_handlers([:detach, :throw, :event])) == 1

      assert {:error, :not_found} =
               Telemetry.detach_handler("detach-throw-handler-test-id-2", [
                 :detach,
                 :throw,
                 :event
               ])
    end
  end
end
