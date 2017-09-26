defmodule Pubsub.Subscriptor do
  require Logger

  def start do
    pid = spawn fn -> accept_loop([]) end
    {:ok, pid}
  end

  def accept_loop(state) do
    receive do
      {:notify, from, message} ->
        Logger.info "    #{inspect self()} -> Message \"#{message}\" arrived from #{inspect from}"
        accept_loop(state)
      {:subscriptions, _from} ->
        Logger.info "    #{inspect self()} -> Subscriptions #{inspect state}"
        accept_loop(state)
      {:subscribe, topic} ->
        Logger.info "    #{inspect self()} -> Subscribed to #{topic}"
        accept_loop([topic | state])
      _ ->
        Logger.error "Unexpected message"
        accept_loop(state)
    end
  end

  def subscribe_to(pid, broker, topic) do
    send pid, {:subscribe, topic}
    send broker, {:subscription, self(), topic}
  end
end
