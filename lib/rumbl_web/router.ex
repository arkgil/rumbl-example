defmodule RumblWeb.Router do
  use RumblWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug RumblWeb.Auth
  end

  scope "/", RumblWeb do
    pipe_through :api

    resources "/users", UserController, only: [:index, :show, :create]
    resources "/sessions", SessionController, only: [:create]
    get "/watch/:id", WatchController, :show
  end

  scope "/manage", RumblWeb do
    pipe_through [:api, :authenticate_user]

    resources "/videos", VideoController
  end
end
