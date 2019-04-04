defmodule Load.Requests do
  @moduledoc false

  def register(email, password) do
    credential = %{email: email, password: password}

    params = %{
      username: :crypto.strong_rand_bytes(12) |> Base.encode64(),
      name: :crypto.strong_rand_bytes(12) |> Base.encode64(),
      credential: credential
    }

    case post("/users", params) do
      {:ok, 201, %{"token" => token}} ->
        {:ok, token}

      {:ok, 400, errors} ->
        email_errors = errors["errors"]["credential"]["email"]

        if is_list(email_errors) and "has already been taken" in email_errors do
          authenticate(email, password)
        else
          {:error, errors}
        end

      {:ok, _, _} ->
        authenticate(email, password)

      {:error, _} = err ->
        err
    end
  end

  def authenticate(email, password) do
    credentials = %{email: email, password: password}

    case post("/sessions", credentials) do
      {:ok, 201, %{"token" => token}} ->
        {:ok, token}

      {:ok, _, body} ->
        {:error, body}

      {:error, _} = err ->
        err
    end
  end

  def users(token) do
    case get("/users", token) do
      {:ok, 200, users} ->
        {:ok, users}

      {:ok, 401, error} ->
        {:error, error}

      {:error, _} = err ->
        err
    end
  end

  def videos(token) do
    case get("/manage/videos", token) do
      {:ok, 200, videos} ->
        {:ok, videos}

      {:ok, 401, error} ->
        {:error, error}

      {:error, _} = err ->
        err
    end
  end

  def create_video(token) do
    params = %{
      description: "Watch that great video",
      title: "Great video",
      url: "http://#{System.unique_integer()}.com"
    }

    case post("/manage/videos", params, token) do
      {:ok, 201, video} ->
        {:ok, video}

      {:ok, 401, error} ->
        {:error, error}

      {:error, _} = err ->
        err
    end
  end

  defp endpoint() do
    Application.fetch_env!(:load, :endpoint)
  end

  defp get(path, token \\ nil) do
    headers = maybe_add_auth_header([{"Accept", "application/json"}], token)
    body = ""
    url = Path.join(endpoint(), path)
    {:ok, status, _, request} = :hackney.get(url, headers, body, [])

    {:ok, body} = :hackney.body(request)

    case Jason.decode(body) do
      {:ok, response} ->
        {:ok, status, response}

      _ ->
        {:error, :invalid_json}
    end
  end

  defp post(path, params, token \\ nil) do
    headers =
      [{"Accept", "application/json"}, {"Content-Type", "application/json"}]
      |> maybe_add_auth_header(token)

    body = Jason.encode!(params)
    url = Path.join(endpoint(), path)
    {:ok, status, _, request} = :hackney.post(url, headers, body, [])

    {:ok, body} = :hackney.body(request)

    case Jason.decode(body) do
      {:ok, response} ->
        {:ok, status, response}

      _ ->
        {:error, :invalid_json}
    end
  end

  defp maybe_add_auth_header(headers, nil), do: headers

  defp maybe_add_auth_header(headers, token) do
    [{"Authorization", "Bearer #{token}"} | headers]
  end
end
