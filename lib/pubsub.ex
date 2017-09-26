defmodule Pubsub do
  use Supervisor

  def start_link do
    Supervisor.start_link __MODULE__, :ok
  end

  def init(:ok) do
    children = [
      worker(Pubsub.Broker, []),
      worker(Pubsub.Subscriptor, [])
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
