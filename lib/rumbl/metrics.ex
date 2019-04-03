defmodule Rumbl.Metrics do
  @moduledoc false

  import Telemetry.Metrics

  def child_spec(_) do
    metrics = vm_metrics() ++ http_metrics() ++ controller_metrics() ++ db_metrics()

    TelemetryMetricsStatsd.child_spec(
      metrics: metrics,
      prefix: "rumbl"
    )
  end

  defp vm_metrics() do
    [
      last_value("vm.memory.total"),
      last_value("vm.memory.processes_used"),
      last_value("vm.memory.ets"),
      last_value("vm.memory.binary"),
      last_value("vm.total_run_queue_lengths.cpu"),
      last_value("vm.total_run_queue_lengths.io")
    ]
  end

  defp http_metrics() do
    [
      counter("http.requests.count", event_name: "rumbl.endpoint.start"),
      counter("http.responses.count",
        event_name: "rumbl.endpoint.stop",
        tags: [:status],
        tag_values: &http_response_tags/1
      ),
      distribution("http.responses.duration",
        event_name: "rumbl.endpoint.stop",
        tags: [:status],
        tag_values: &http_response_tags/1,
        unit: {:native, :millisecond},
        buckets: [0, 100, 200]
      )
    ]
  end

  defp controller_metrics() do
    [
      counter("controller.calls.count",
        event_name: "phoenix.controller.call.start",
        tags: [:controller, :action],
        tag_values: &controller_tags/1
      ),
      distribution("controller.calls.duration",
        event_name: "phoenix.controller.call.stop",
        tags: [:controller, :action, :status],
        tag_values: &controller_tags/1,
        unit: {:native, :millisecond},
        buckets: [0, 100, 200]
      )
    ]
  end

  defp db_metrics() do
    [
      counter("db.query.count", event_name: "rumbl.repo.query", tags: [:source]),
      distribution("db.query.total_time",
        event_name: "rumbl.repo.query",
        tags: [:source],
        unit: {:native, :millisecond},
        buckets: [0, 100, 200]
      )
    ]
  end

  defp http_response_tags(%{conn: conn}) do
    %{status: conn.status}
  end

  defp controller_tags(%{conn: conn}) do
    controller = conn |> Phoenix.Controller.controller_module() |> Module.split() |> List.last()
    action = Phoenix.Controller.action_name(conn)
    status = conn.status
    %{controller: controller, action: action, status: status}
  end
end
