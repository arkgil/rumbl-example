defmodule RumblWeb.Auth do
  import Plug.Conn

  alias Rumbl.Accounts

  @salt "user"
  @token_max_age 10 * 60

  def init(opts), do: opts

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, user_id} <- Phoenix.Token.verify(conn, @salt, token, max_age: @token_max_age),
         user when not is_nil(user) <- Accounts.get_user(user_id) do
      assign(conn, :current_user, user)
    else
      _ ->
        assign(conn, :current_user, nil)
    end
  end

  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> send_resp(401, Jason.encode!(%{error: "Unauthorized"}))
      |> halt()
    end
  end

  def login(conn, user) do
    token(conn, user)
  end

  def login_by_email_and_pass(conn, email, given_pass) do
    case Accounts.authenticate_by_email_and_pass(email, given_pass) do
      {:ok, user} -> {:ok, token(conn, user)}
      {:error, :unauthorized} -> {:error, :unauthorized}
      {:error, :not_found} -> {:error, :not_found}
    end
  end

  defp token(conn, user) do
    Phoenix.Token.sign(conn, @salt, user.id)
  end
end
