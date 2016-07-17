defmodule DockupUi.Router do
  use DockupUi.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DockupUi do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/oauth", DockupUi do
    pipe_through :browser

    get "/:provider", OAuthController, :index
    get "/:provider/callback", OAuthController, :callback
    delete "/logout", OAuthController, :delete
  end

  scope "/api", DockupUi do
    pipe_through :api

    resources "/deployments", DeploymentController, only: [:create, :index, :show]
  end
end
