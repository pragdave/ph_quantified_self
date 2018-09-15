defmodule PhQuantifiedSelf.Meal.Food do
  use Ecto.Schema
  import Ecto.Changeset


  schema "meal_foods" do
    field :meal_id, :id
    field :food_id, :id
  end

  @doc false
  def changeset(food, attrs) do
    food
    |> cast(attrs, [])
    |> validate_required([])
  end
end
