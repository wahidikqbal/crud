defmodule CrudWeb.Router do
  use CrudWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CrudWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CrudWeb do
    pipe_through :browser

    get "/", PageController, :home

    # Routes for the Post resource
    live "/posts", PostLive.Index, :index
    live "/posts/new", PostLive.Form, :new
    # live "/posts/:id", PostLive.Show, :show
    live "/posts/:id/edit", PostLive.Form, :edit
    get "/posts/:id", PostController, :show

    # Routes for the Category resource
    live "/categories", CategoryLive.Index, :index
    live "/categories/new", CategoryLive.Form, :new
    live "/categories/:id/edit", CategoryLive.Form, :edit
    live "/categories/:id", CategoryLive.Show, :show

    # Routes for the Tag resource
    live "/tags", TagLive.Index, :index
    live "/tags/new", TagLive.Form, :new
    live "/tags/:id", TagLive.Show, :show
    live "/tags/:id/edit", TagLive.Form, :edit

  end

  # Other scopes may use custom stacks.
  # scope "/api", CrudWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:crud, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: CrudWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
