defmodule PhQuantifiedSelfWeb.Router do
  use PhQuantifiedSelfWeb, :router

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

  scope "/api", PhQuantifiedSelfWeb, as: :api do
    scope "/v1", Api.V1, as: :v1 do
      pipe_through :api
      resources "/foods", FoodController
      get "/meals", MealController, :index
      get "/meals/:id/foods", MealController, :show
    end
  end

  scope "/", PhQuantifiedSelfWeb do
    pipe_through :browser # Use the default browser stack
    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", PhQuantifiedSelfWeb do
  #   pipe_through :api
  # end
end
