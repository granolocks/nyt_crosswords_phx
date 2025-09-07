defmodule NytWeb.PageController do
  use NytWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
