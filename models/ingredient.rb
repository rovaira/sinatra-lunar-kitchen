def db_connection
  begin
    connection = PG.connect(dbname: "recipes")
    yield(connection)
  ensure
    connection.close
  end
end

class Ingredient

  attr_reader :name

  def initialize(id, name, recipe_id)
    @id = id
    @name = name
    @recipe_id = recipe_id
  end

  def self.all

    ingredient_array = []
    db_connection do |conn|
      ingredient_array = conn.exec("SELECT id, name, recipe_id FROM ingredients")
    end

    all_ingredients = []
    ingredient_array.to_a.each do |item|
      food = Ingredient.new(item["id"], item["name"], item["recipe_id"])
      all_ingredients << food
    end
    
    all_ingredients
  end

end
