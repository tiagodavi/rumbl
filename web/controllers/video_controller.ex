defmodule Rumbl.VideoController do
  use Rumbl.Web, :controller
  alias Rumbl.Video

  plug :scrub_params, "video" when action in [:create, :update]
  plug :load_categories when action in [:new, :create, :edit, :update]

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
          [conn, conn.params, conn.assigns.current_user])
  end

  def index(conn, _params, user) do
    videos = get_all_videos(user)

    render(conn, "index.html", videos: videos)
  end

  def new(conn, _params, user) do
    changeset = build_changeset(user)

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"video" => video_params}, user) do
    changeset = build_changeset(user, video_params)

    case Repo.insert(changeset) do
      {:ok, _video} ->
        conn
        |> put_flash(:info, "Video created successfully.")
        |> redirect(to: video_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, user) do
    video = get_video(user, id)

    render(conn, "show.html", video: video)
  end

  def edit(conn, %{"id" => id}, user) do
    video = get_video(user, id)
    changeset = Video.changeset(video)

    render(conn, "edit.html", video: video, changeset: changeset)
  end

  def update(conn, %{"id" => id, "video" => video_params}, user) do
    video = get_video(user, id)
    changeset = Video.changeset(video, video_params)

    case Repo.update(changeset) do
      {:ok, video} ->
        conn
        |> put_flash(:info, "Video updated successfully.")
        |> redirect(to: video_path(conn, :show, video))
      {:error, changeset} ->
        render(conn, "edit.html", video: video, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    video = get_video(user, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(video)

    conn
    |> put_flash(:info, "Video deleted successfully.")
    |> redirect(to: video_path(conn, :index))
  end

  defp user_videos(user) do
    assoc(user, :videos)
  end

  defp build_changeset(user) do
     user
     |> build(:videos)
     |> Video.changeset
  end

  defp build_changeset(user, params) do
    user
    |> build(:videos)
    |> Video.changeset(params)
  end

  defp get_video(user, id) do
    user
    |> user_videos
    |> Repo.get!(id)
  end

  defp get_all_videos(user) do
    user
    |> user_videos
    |> Repo.all
  end

  defp load_categories(conn, _) do
    categories = Repo.all(
      from c in Rumbl.Category.alphabetical,
      select: {c.name, c.id}
    )
    assign(conn, :categories, categories)
  end
end
