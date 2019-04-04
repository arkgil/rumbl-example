defmodule RumblWeb.UserView do
  use RumblWeb, :view
  alias Rumbl.Accounts

  def first_name(%Accounts.User{name: name}) do
    name
    |> String.split(" ")
    |> Enum.at(0)
  end

  def render("index.json", %{users: users}) do
    render_many(users, __MODULE__, "show.json")
  end

  def render("show.json", %{user: user}) do
    %{id: user.id, username: user.username, name: user.name}
  end
end
