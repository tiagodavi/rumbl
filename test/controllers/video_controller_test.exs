defmodule Rumbl.VideoControllerTest do
  use Rumbl.ConnCase

  setup do
    user = insert_user(username: "Max")
    conn = assign(conn, :current_user, user)
    {:ok, conn: conn, user: user}
  end

  test "list all user's videos on index", %{conn: conn, user: user} do
    user_video  = insert_video(user, title: "Funny cats")
    other_video = insert_video(insert_user(username: "Other"), title: "Another video")

    conn = get conn, video_path(conn, :index)
    assert html_response(conn, 200) =~ ~r/Listing videos/
    assert String.contains?(conn.resp_body, user_video.title)
    refute String.contains?(conn.resp_body, other_video.title)
  end

  test "requires user authentication on all actions", %{conn: conn} do
    Enum.each([
      get(conn, video_path(conn, :index)),
      get(conn, video_path(conn, :show, "123")),
      get(conn, video_path(conn, :edit, "123")),
      put(conn, video_path(conn, :update, "123", %{})),
      post(conn, video_path(conn, :create, %{})),
      delete(conn, video_path(conn, :delete, "123")),
    ], fn conn ->
        assert html_response(conn, 302)
        assert conn.halted
    end)
  end
end
