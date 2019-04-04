defmodule Load.WorkerSupervisor do
  @moduledoc false

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {
        Supervisor,
        :start_link,
        [
          [%{
            id: Load.Worker,
            start: {Load.Worker, :start_link, []}
          }],
          [name: __MODULE__, strategy: :simple_one_for_one]
        ]
      }
    }
  end
end
