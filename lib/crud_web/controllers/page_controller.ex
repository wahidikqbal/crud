defmodule CrudWeb.PageController do
  use CrudWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
