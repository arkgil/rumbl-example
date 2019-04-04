defmodule Load.Coordinator do
  @moduledoc false

  def start(count, interval) do
    for _ <- 1..count do
      Supervisor.start_child(
        Load.WorkerSupervisor,
        [interval]
      )

      Process.sleep(:rand.uniform(5000))
    end
  end
end
