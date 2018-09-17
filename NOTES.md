I have to say, I'm really impressed. There's a whole lot to like about
this, and as Elixir code goes, it's up there with the stuff that the
folks with years of experience write.

I've jotted down a few comments inline. But I also have two global
points.

First, you're doing the many-to-many stuff the hard way, by updating
the join table yourself. Have a look at the Elixir guide for this:
https://hexdocs.pm/ecto/associations.html#many-to-many; you can use
changesets to do it all for you.

If you do that, then you can also think about simplifying your
controllers. Right now, you have what amounts to business logic in
there:

~~~ eliir
  def update(conn, params) do\
    [{food_id, ""}, {meal_id, ""}] = [Integer.parse(params["food_id"]), Integer.parse(params["meal_id"])]
    [food, meal] = [Food.find(food_id), Meal.find(meal_id)]
    if (food && meal) do
      Meal.add_food(meal, food)
      conn
      |> put_status(201)
      |> json(%{message: "Successfully added #{food.name} to #{meal.name}"})
    else
      conn
      |> put_status(404)
      |> json(%{error: "Meal or Food not found"})
    end
  end
  ~~~

  You could delegate the checking to the Meal module, and common up the
  response handling across all controller functions:5

~~~ elixir
  def update(conn, %{ "meal" => meal_id, "food" => food_id}) do
    if Meal.add_food(meal_id, food_id) do
      food = Food.find(food_id)
      respond_with(conn, 201,  "Successfully added #{food.name} to #{meal.name}")
    else
      respond_with(conn, 404, "meal or food not found")
  end


 # untested...

 defp respond_with(conn, 404, reason) do
  conn
  |> put_status(404)
  |> json(%{error: reason})
 end

 defp respond_with(conn, status, message) do
  conn
  |> put_status(status)
  |> json(%{message: message})
 end
~~~

Then the delete function would change from

~~~ elixir
 def delete(conn, params) do
    [{food_id, ""}, {meal_id, ""}] = [Integer.parse(params["food_id"]), Integer.parse(params["meal_id"])]
    [food, meal] = [Food.find(food_id), Meal.find(meal_id)]
    if (food && meal && Meal.assoc?(meal, food)) do
      Meal.remove_food(meal, food)
      conn
      |> put_status(200)
      |> json(%{message: "Successfully removed #{food.name} to #{meal.name}"})
    else
      conn
      |> put_status(404)
      |> json(%{error: "Not Found"})
    end
  end
~~~

to

~~~ elixir
 def delete(conn, %{ "meal" => meal_id, "food" => food_id}) do
    if Meal.remove_food(meal_id, food_id) do
      respond_with(conn, 200, "Successfully removed #{food.name} to #{meal.name}"})
    else
      respond_with(conn, 404, "Not Found")
    end
  end
  ~~~
