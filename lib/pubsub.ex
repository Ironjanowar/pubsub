defmodule Pubsub do
  require Logger

  def start() do
    {:ok, broker} = Pubsub.Broker.start()
    :erlang.register(:broker, broker)
  end
end
