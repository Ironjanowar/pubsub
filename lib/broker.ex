defmodule Pubsub.Broker do
  require Logger

  def start() do
    pid = spawn fn -> loop(%{broadcast: MapSet.new, publisher: MapSet.new}) end
    {:ok, pid}
  end

  # def register_publisher(state, publisher) do
  #   Map.get(state, :publishers)
  #   |> (fn pubs -> Map.put(state, :publishers, MapSet.put(pubs, publisher)) end).()
  # end

  def register_subscriber(state, subscriber) do
    Map.get(state, :broadcast)
    |> (fn subs -> Map.put(state, :broadcast, MapSet.put(subs, subscriber)) end).()
  end

  def add_subscriber(state, topic, subscriber) do
    state = register_subscriber(state, subscriber)

    case Map.get(state, topic) do
      nil ->
        Map.put(state, topic, MapSet.new([subscriber]))
      subscribers ->
        Map.put(state, topic, MapSet.put(subscribers, subscriber))
    end
  end

  defp send_message(pid, message), do: send pid, {:notify, message}

  def send_message(state, topic, message) do
    Map.get(state, topic)
    |> Enum.map(fn pid -> send_message(pid, message) end)
  end

  def broadcast(state, sender, message) do
    Map.get(state, :broadcast)
    |> Enum.filter(fn sub -> sub != sender end)
    |> Enum.map(fn sub -> send sub, {:notify, message} end)
  end

  def loop(state) do
    receive do
      {:subscription, from, topic} ->
        Logger.info "BROKER[#{inspect self()}] -> Process #{inspect from} subscribes to #{topic}"
        add_subscriber(state, topic, from) |> loop
      {:get_state, from} ->
        Logger.info "BROKER[#{inspect self()}] -> State #{inspect state}"
        send from, state
        loop(state)
      {:send_message, topic, message} ->
        Logger.info "BROKER[#{inspect self()}] -> Sending message #{inspect message} to topic #{inspect topic}"
        send_message(state, topic, message)
        loop(state)
      {:broadcast, sender, message} ->
        Logger.info "BROKER[#{inspect self()}] -> Broadcasting #{inspect message}"
        broadcast(state, sender, message)
        loop(state)
      {:new_subscriber, from} ->
        Logger.info "BROKER[#{inspect self()}] -> New subscriber #{inspect from} added"
        register_subscriber(state, from) |> loop
      # {:new_publisher, from} ->
      #   Logger.info "BROKER[#{inspect self()}] -> New publisher #{inspect from} added"
      #   register_publisher(state, from) |> loop
      _ ->
        Logger.error "BROKER[#{inspect self()}] -> Unexpected message"
        loop(state)
    end
  end
end
