defmodule PhQuantifiedSelfWeb.MealRequestTest do
  use PhQuantifiedSelfWeb.ConnCase
  alias PhQuantifiedSelf.{Meal, Food}
  alias PhQuantifiedSelf.Repo
  import Ecto.Changeset

  # You can remove some duplication here:

  @breakfast 1
  @snack     2
  @lunch     3

  @banana    100
  @grape     101
  @toast     102

  defp add_to_meal(meal, foods) do
    meal
    |> Repo.preload(:foods)
    |> change()
    |> put_assoc(:foods, foods)
    |> Repo.update!
  end

  defp setup_meals_with_foods() do
    breakfast = Repo.insert!(%Meal{name: "Breakfast", id: @breakfast})
    snack     = Repo.insert!(%Meal{name: "Snack",     id: @snack})
    lunch     = Repo.insert!(%Meal{name: "Lunch",     id: @lunch})

    banana = Repo.insert!(%Food{name: "Bannana", calories: 150, id: @banana})
    grape  = Repo.insert!(%Food{name: "Grape",   calories: 200, id: @grape})
    _toast = Repo.insert!(%Food{name: "Toast",   calories: 250, id: @toast})

    add_to_meal(breakfast, [ banana, grape ])
    add_to_meal(lunch,     [ grape ])
    add_to_meal(snack,     [ grape ])
  end

  setup do
    setup_meals_with_foods()
    :ok
  end

  describe "get queries" do
    test "get /api/v1/meals", %{conn: conn} do
      conn = get conn, "/api/v1/meals"
      response = json_response(conn, 200)
      assert length(response) == length(Meal.all)
      [meal|_] = response
      assert meal["name"] == "Breakfast"
      assert length(meal["foods"]) == 2
    end

    test "get /api/v1/meals/:id/foods", %{conn: conn} do
      conn = get conn, "/api/v1/meals/#{@breakfast}/foods"
      response = json_response(conn, 200)
      assert response["name"] == "Breakfast"
      assert length(response["foods"]) == 2
    end
  end
  describe "create/update queries" do
    test "post api/v1/meals/:id/foods/:id success", %{conn: conn} do
      conn = post conn, "/api/v1/meals/#{@breakfast}/foods/#{@toast}"
      response = json_response(conn, 201)
      creation_message =  response["message"]
      assert creation_message == "Successfully added Toast to Breakfast"
    end

    test "post api/v1/foods failure", %{conn: conn} do
      conn = post conn, "/api/v1/meals/#{@breakfast}/foods/9999"
      response = json_response(conn, 404)
      assert response
    end
  end
  describe "destroy queries" do

    test "DELETE /api/v1/meals/:id/foods/:id", %{conn: conn} do
      conn = delete conn, "/api/v1/meals/#{@breakfast}/foods/#{@banana}"
      response = json_response(conn, 200)
      message = response["message"]
      assert message == "Successfully removed Bannana to Breakfast"
    end

    test "DELETE /api/v1/meals/:id/foods/:id non success", %{conn: conn} do
      conn = delete conn, "/api/v1/meals/#{@breakfast}/foods/999"
      response = json_response(conn, 404)
      error = response["error"]
      assert error == "Not Found"
    end
  end
end
