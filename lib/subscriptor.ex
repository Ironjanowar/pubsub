defmodule Pubsub.Subscriptor do
  require Logger

  @broker :broker

  def start(subscriptions \\ []) when is_list(subscriptions) do

    pid = spawn fn -> accept_loop(MapSet.new) end
    MapSet.new(subscriptions) |> Enum.map(fn x -> send @broker, {:subscription, pid, x} end)
    {:ok, pid}
  end

  def accept_loop(state) do
    receive do
      {:notify, from, message} ->
        Logger.info "    Subscriptor[#{inspect self()}] -> Message \"#{message}\" arrived from #{inspect from}"
        accept_loop(state)
      {:subscriptions, _from} ->
        Logger.info "    Subscriptor[#{inspect self()}] -> Subscriptions #{inspect state}"
        accept_loop(state)
      {:subscribe, topic} ->
        Logger.info "    Subscriptor[#{inspect self()}] -> Subscribed to #{topic}"
        send @broker, {:subscription, self(), topic}
        accept_loop(MapSet.put(state, topic))
      _ ->
        Logger.error "Unexpected message"
        accept_loop(state)
    end
  end

  def subscribe_to(topic) do
    send @broker, {:subscribe, topic}
    # send broker, {:subscription, self(), topic}
  end
end
