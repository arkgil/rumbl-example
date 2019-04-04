defmodule Load.Worker do
  @moduledoc false

  use GenServer

  alias Load.Requests

  def child_spec(interval) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [interval]}
    }
  end

  def start_link(interval) do
    GenServer.start_link(__MODULE__, interval)
  end

  @impl true
  def init(interval) do
    {token, credential} = register()
    schedule_action(interval)
    {:ok, %{interval: interval, token: token, credential: credential}}
  end

  @impl true
  def handle_info(:act, state) do
    r = :rand.uniform(100)

    state =
      cond do
        r in 1..20 ->
          Requests.create_video(state.token)
          state

        r in 21..25 ->
          authenticate(state)

        r in 26..80 ->
          Requests.videos(state.token)
          state

        true ->
          Requests.users(state.token)
          state
      end

    schedule_action(state.interval)
    {:noreply, state}
  end

  defp register() do
    credential =
      "#{System.unique_integer([:positive])}"
      |> String.pad_trailing(10, "0")

    token =
      case Requests.register(credential, credential) do
        {:ok, token} ->
          token

        _ ->
          nil
      end

    {token, credential}
  end

  defp schedule_action(interval) do
    Process.send_after(self(), :act, interval)
  end

  defp authenticate(state) do
    token =
      case Requests.authenticate(state.credential, state.credential) do
        {:ok, token} ->
          token

        _ ->
          nil
      end

    %{state | token: token}
  end
end
