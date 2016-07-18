defmodule DockupUi.PageControllerTest do
  use DockupUi.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Dockup"
  end
end
