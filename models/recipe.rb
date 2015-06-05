def db_connection
  begin
    connection = PG.connect(dbname: "recipes")
    yield(connection)
  ensure
    connection.close
  end
end

class Recipe

  attr_reader :id, :name, :description, :instructions, :ingredients

  def initialize(id, name, description, instructions, ingredients)
    @id = id
    @name = name
    @description = description
    @instructions = instructions
    @ingredients = ingredients
  end

  def self.all

    recipe_array = []
    ingredient_array = []
    db_connection do |conn|
      recipe_array = conn.exec("SELECT id, name, description, instructions FROM recipes")
      ingredient_array = conn.exec("SELECT id, name, recipe_id FROM ingredients")
    end

    all_recipes = []
    recipe_array.to_a.each do |item|

      this_item_ingredients = []
      ingredient_array.to_a.each do |food|
        if item["id"] == food["recipe_id"]
          this_item_ingredients << Ingredient.new(food["name"])
        end
      end

      all_recipes << Recipe.new(item["id"],
                                item["name"],
                                item["description"],
                                item["instructions"],
                                this_item_ingredients)
    end

    all_recipes
  end


  def self.find(int)
    self.all.each do |item|
      if item.id == int
        return item
      end
    end
  end
end

##--ENDNOTE--##
# We tried running the following w/in our recipe_array loop, as suggested by Christina,
# thinking it might be faster, but it ended up taking over 5 min for the program to
# load and our tests to pass.
## ONE ATTEMPT @ REFACTORING:
# ingredient_array = db_connection do |conn|
#   conn.exec("SELECT ingredients.id, ingredients.name, recipe_id
#   FROM ingredients
#     JOIN recipes ON ingredients.recipe_id = recipes.id
#   WHERE recipe_id = recipes.id")
# end # call to db - ONLY the ingredients for current recipe
