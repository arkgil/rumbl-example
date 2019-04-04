defmodule RumblWeb.UserController do
  use RumblWeb, :controller

  alias Rumbl.Accounts

  plug :authenticate_user when action in [:index, :show]

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.json", users: users)
  end

  def show(conn, %{"id" => id}) do
    case Accounts.get_user(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{status: "not found"})
      user ->
        render(conn, "show.json", user: user)
    end
  end

  def create(conn, user_params) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        token = RumblWeb.Auth.login(conn, user)
        conn
        |> put_status(:created)
        |> json(%{token: token})

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:bad_request)
        |> json(%{errors: changeset_errors(changeset)})
    end
  end
end
