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

    test "{:attach, _} supports adding multiple handlers to the same key in :ets table", %{
      state: state
    } do
      for _ <- 1..5 do
        assert {:reply, :ok, _new_state} =
                 Telemetry.HandlerTable.handle_call(
                   {:attach, {"test", [:test, :event], fn -> :ok end, nil}},
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
      for _ <- 1..5 do
        assert {:reply, :ok, _new_state} =
                 Telemetry.HandlerTable.handle_call(
                   {:attach, {"test", [:event], fn -> :ok end, nil}},
                   nil,
                   state
                 )
      end

      assert {:reply, returned_functions, _new_state} =
               Telemetry.HandlerTable.handle_call({:list, [:event]}, nil, state)

      assert length(returned_functions) == 5
      assert Enum.all?(returned_functions, &is_function/1)
    end
  end
end
