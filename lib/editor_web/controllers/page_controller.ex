defmodule EditorWeb.PageController do
  use EditorWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
