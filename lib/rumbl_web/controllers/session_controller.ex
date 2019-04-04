defmodule RumblWeb.SessionController do
  use RumblWeb, :controller

  def new(conn, _) do
    render(conn, "new.html")
  end

  def create(conn, %{"email" => email, "password" => pass}) do
    case RumblWeb.Auth.login_by_email_and_pass(conn, email, pass) do
      {:ok, token} ->
        conn
        |> put_status(:created)
        |> json(%{token: token})

      {:error, _reason} ->
        conn
        |> put_status(401)
        |> json(%{error: "Invalid email/password combination"})
    end
  end
end
