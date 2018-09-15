defmodule PhQuantifiedSelf.Meal do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false
  @derive {Poison.Encoder, except: [:__meta__]}
  use Ecto.Schema
  import Ecto.Changeset

  import Ecto.Query, warn: false
  alias PhQuantifiedSelf.{Repo, Food, Meal}
  alias PhQuantifiedSelf.Meal.Food, as: Meal_Food

  schema "meals" do
    field :name, :string

    many_to_many :foods, Food, join_through: "meal_foods"
    timestamps()
  end

  def changeset(meal, attrs) do
    meal
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  def all do
    Meal
    |> select([:id, :name])
    |> Repo.all()
    |> Repo.preload(:foods)
  end

  # Why do the test here?
  def find(id) do
    Meal
    |> Repo.get(id)
    |> Repo.preload(:foods)
  end
  def find_old(id) do
    if (Repo.get(Meal, id)) do
      Meal
      |> select([:id, :name])
      |> Repo.get(id)
      |> Repo.preload(:foods)
    else
    end
  end

  def add_food(meal, food) do
    Repo.insert(%Meal_Food{meal_id: meal.id, food_id: food.id})
    Meal.find(meal.id)
  end

  def remove_food(meal, food) do
    Meal_Food
    |> Repo.get_by(meal_id: meal.id, food_id: food.id)
    |> Repo.delete()
  end

  # Two things I'd do differently here. First, layout. As you're assigning from
  # a pipeline, I'd indent the body:
  #
  #     assoc = Meal_Food
  #             |> Repo.get_by(meal_id: meal.id, food_id: food.id)
  #
  # Second, there's a trick to convert a value from truthy/falsy into actual
  # `true` or `false`. You can do `!!value`, which negates it twice, but the
  # first negation turns `nil`/`false` into `true` and anthing else into
  # `false`. The second negation then gets the logic the right way around.
  #
  # So...
   def assoc?(meal, food) do
    !!(Meal_Food |> Repo.get_by(meal_id: meal.id, food_id: food.id))
  end
end
