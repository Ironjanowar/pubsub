defmodule Pubsub.Publisher do
  @broker :broker

  require Logger

  def start() do
    pid = spawn fn -> loop() end
    # register_publisher(pid)
    {:ok, pid}
  end

  def loop() do
    receive do
      {:send, topic, message} ->
        Logger.info "PUBLISHER[#{inspect self()}] -> Sending #{inspect message}"
        send_message(topic, message)
        loop()
      _ ->
        Logger.error "PUBLISHER[#{inspect self()}] -> Unexpected message"
        loop()
    end
  end

  def send_message(topic, message), do: send @broker, {:send_message, topic, message}

  # def register_publisher(pid), do: send @broker, {:new_publisher, pid}
end
