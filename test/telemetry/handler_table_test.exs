defmodule Telemetry.HandlerTableTest do
  use ExUnit.Case

  describe "init/1" do
    test "returns :ok and creates :ets table" do
      assert {:ok, %Telemetry.HandlerTable.State{table: table}} = Telemetry.HandlerTable.init([])
      refute :ets.info(table) == :undefined
    end
  end

  describe "handle_call/3" do
    setup do
      {:ok, %Telemetry.HandlerTable.State{} = state} = Telemetry.HandlerTable.init([])
      {:ok, state: state}
    end

    test "{:attach, _} adds handler function to :ets table", %{state: state} do
      assert {:reply, :ok, _new_state} =
               Telemetry.HandlerTable.handle_call(
                 {:attach, {"test", [:test, :event], fn -> :ok end, nil}},
                 nil,
                 state
               )

      assert length(:ets.tab2list(state.table)) == 1
    end

    test "{:attach, _} returns {:error, :already_exists} when trying to add duplicate handlers",
         %{state: state} do
      assert {:reply, :ok, _new_state} =
               Telemetry.HandlerTable.handle_call(
                 {:attach, {"test", [:test, :event], fn -> :ok end, nil}},
                 nil,
                 state
               )

      assert {:reply, {:error, :already_exists}, _new_state} =
               Telemetry.HandlerTable.handle_call(
                 {:attach, {"test", [:test, :event], fn -> :ok end, nil}},
                 nil,
                 state
               )
    end

    test "{:attach, _} supports adding multiple handlers to the same key in :ets table if they have unique ids",
         %{
           state: state
         } do
      for n <- 1..5 do
        assert {:reply, :ok, _new_state} =
                 Telemetry.HandlerTable.handle_call(
                   {:attach, {"test_#{n}", [:test, :event], fn -> :ok end, nil}},
                   nil,
                   state
                 )
      end

      assert length(:ets.tab2list(state.table)) == 5
    end

    test "{:list, [:event]} returns [] when no functions for event [:event] are attached", %{
      state: state
    } do
      assert {:reply, [], _new_state} =
               Telemetry.HandlerTable.handle_call({:list, [:event]}, nil, state)
    end

    test "{:list, [:event]} returns a list of functions when functions for event [:event] are attached",
         %{
           state: state
         } do
      for n <- 1..5 do
        assert {:reply, :ok, _new_state} =
                 Telemetry.HandlerTable.handle_call(
                   {:attach, {"test_#{n}", [:event], fn -> :ok end, nil}},
                   nil,
                   state
                 )
      end

      assert {:reply, response, _new_state} =
               Telemetry.HandlerTable.handle_call({:list, [:event]}, nil, state)

      assert length(response) == 5

      assert Enum.all?(response, fn
               {handler_id, function} when is_binary(handler_id) and is_function(function) -> true
               _ -> false
             end)
    end

    test "{:detach, {event, handler}} returns :ok when trying to add delete attached handler", %{
      state: state
    } do
      assert {:reply, :ok, _new_state} =
               Telemetry.HandlerTable.handle_call(
                 {:attach, {"my-event", [:event], fn -> :ok end, nil}},
                 nil,
                 state
               )

      assert {:reply, :ok, _new_state} =
               Telemetry.HandlerTable.handle_call({:detach, {"my-event", [:event]}}, nil, state)

      assert Enum.empty?(:ets.tab2list(state.table))
    end

    test "{:detach, {event, handler}} returns {:error, :not_found} when trying to add delete unattached handler",
         %{
           state: state
         } do
      assert {:reply, {:error, :not_found}, _new_state} =
               Telemetry.HandlerTable.handle_call({:detach, {"my-event", [:event]}}, nil, state)

      assert Enum.empty?(:ets.tab2list(state.table))
    end
  end
end
