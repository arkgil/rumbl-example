defmodule RumblWeb.VideoController do
  use RumblWeb, :controller

  alias Rumbl.Multimedia
  alias Rumbl.Multimedia.Video

  plug :load_categories when action in [:new, :create, :edit, :update]

  defp load_categories(conn, _) do
    assign(conn, :categories, Multimedia.list_alphabetical_categories())
  end

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.current_user])
  end

  def index(conn, _params, current_user) do
    videos = Multimedia.list_user_videos(current_user) # <label id="code.scoped-index"/>
    render(conn, "index.json", videos: videos)
  end

  def show(conn, %{"id" => id}, current_user) do
    video = Multimedia.get_user_video!(current_user, id) # <label id="code.scoped-show"/>
    render(conn, "show.json", video: video)
  end

  def update(conn, %{"id" => id, "video" => video_params}, current_user) do
    video = Multimedia.get_user_video!(current_user, id) # <label id="code.scoped-update"/>

    case Multimedia.update_video(video, video_params) do
      {:ok, video} ->
        conn
        |> render("show.json", video: video)

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(400)
        |> json(%{errors:  changeset_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}, current_user) do
    video = Multimedia.get_user_video!(current_user, id) # <label id="code.scoped-delete"/>
    {:ok, _video} = Multimedia.delete_video(video)

    conn
    |> json(%{status: "ok"})
  end

  def create(conn, video_params, current_user) do
    case Multimedia.create_video(current_user, video_params) do
      {:ok, video} ->
        conn
        |> put_status(:created)
        |> render("show.json", video: video)

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(400)
        |> json(%{errors:  changeset_errors(changeset)})
    end
  end
end
