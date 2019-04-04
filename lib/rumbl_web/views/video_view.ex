defmodule RumblWeb.VideoView do
  use RumblWeb, :view

  def category_select_options(categories) do
    for category <- categories, do: {category.name, category.id}
  end

  def render("show.json", %{video: video}) do
    %{
      description: video.description,
      title: video.title,
      url: video.url,
      slug: video.slug
    }
  end

  def render("index.json", %{videos: videos}) do
    render_many(videos, __MODULE__, "show.json")
  end
end
