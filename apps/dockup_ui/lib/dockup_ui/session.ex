defmodule DockupUi.Session do

  # TODO: This can be changed to user id once we
  # persist users in the DB
  def current_user_name(conn) do
    user = Plug.Conn.get_session(conn, :current_user)
    if user do
      user[:name]
    end
  end
end
