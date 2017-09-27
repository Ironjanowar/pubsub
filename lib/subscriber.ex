defmodule Pubsub.Subscriber do
  require Logger

  @broker :broker

  def start(subscriptions \\ []) when is_list(subscriptions) do
    # Create subscriber
    pid = spawn fn -> loop(MapSet.new) end
    # Subscribe to initial topics
    MapSet.new(subscriptions) |> Enum.map(fn topic -> subscribe_to(pid, topic) end)
    # Register in broker
    register(pid)

    {:ok, pid}
  end

  def loop(state) do
    receive do
      {:notify, message} ->
        Logger.info "    SUBSCRIBER[#{inspect self()}] -> Message \"#{message}\" arrived"
        loop(state)
      {:subscribe, topic} ->
        Logger.info "    SUBSCRIBER[#{inspect self()}] -> Subscribed to #{topic}"
        subscribe_to(self(), topic)
        loop(MapSet.put(state, topic))
      _ ->
        Logger.error "    SUBSCRIBER[#{inspect self()}]Unexpected message"
        loop(state)
    end
  end

  def subscribe_to(pid, topic), do: send @broker, {:subscription, pid, topic}

  def register(pid), do: send @broker, {:new_subscriber, pid}
end
