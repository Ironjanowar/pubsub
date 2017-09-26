defmodule Pubsub.Broker do
  require Logger

  def start(state \\ %{}) do
    pid = spawn fn -> accept_loop(state) end
    {:ok, pid}
  end

  def add_subscriptor(state, topic, subscriptor) do
    case Map.get(state, topic) do
      nil ->
        Map.put(state, topic, MapSet.new([subscriptor]))
      subscriptors ->
        Map.put(state, topic, MapSet.put(subscriptors, subscriptor))
    end
  end

  def accept_loop(state) do
    receive do
      {:subscription, from, topic} ->
        Logger.info "#{inspect self()} -> Process #{inspect from} subscribes to #{topic}"
        add_subscriptor(state, topic, from) |> accept_loop
      :get_state ->
        Logger.info "#{inspect self()} -> State #{inspect state}"
        accept_loop(state)
      _ ->
        Logger.info "Unhandled message"
        accept_loop(state)
    end
  end
end
