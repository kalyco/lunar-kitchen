class Recipe
  attr_accessor :id, :name, :instructions, :description, :ingredients

  def initialize(id, name, instructions, description, ingredients=[])
    @id = id
    @name = name
    @instructions = instructions
    @description = description
    @ingredients = ingredients
  end

  def description
    @description
  end

  def instructions
    @instructions
  end

  def self.all(id=nil)
    if id.nil?
      @recipes = self.get_recipes_from_db.to_a.map do |recipe|
        a = Recipe.new(recipe['id'], recipe['name'], recipe['instructions'], recipe['description'])
      end
    end

    @recipes
  end

  def self.find(id)
    @recipe = self.all.find { |i| i.id == id }
    a = self.get_ingredients_from_db(id)
    self.get_error if @recipe.nil?
    a.each do |i|
      @recipe.ingredients << Ingredient.new(i['name'])
    end
    @recipe
  end

  def self.get_error
    @recipe = Hash.new
    @recipe['description'] = "This recipe doesn't have a description."
    @recipe['instructions'] = "This recipe doesn't have any instructions."
    @recipe['id'] = "This id does not exist."
    @recipe['name'] = "This name does not exist."
    @recipe = Recipe.new(@recipe['id'], @recipe['name'], @recipe['instructions'], @recipe['description'])
  end


  ##########
  # DB     #
  ##########

    def self.db_connection
      begin
        connection = PG.connect(dbname: 'recipes')
        yield(connection)
      ensure
        connection.close
      end
    end

    def self.get_recipes_from_db
      recipes = db_connection do |conn|
        conn.exec("SELECT * FROM recipes")
      end
      recipes
    end

    def self.get_ingredients_from_db(id)
      sql = %Q{ SELECT name FROM ingredients WHERE #{id} = recipe_id }

      ingredients = db_connection do |conn|
        conn.exec(sql)
      end
      ingredients.to_a
    end

  def self.parse(ingredient)
  end
end
