class Dog
  attr_accessor :name, :breed, :id

  def initialize( id: nil, name: name, breed: breed)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, @name, @breed, @id)
  end

  def self.create(name: name, breed: breed)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, name, breed)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      Dog.new(id: @id, name: @name, breed: @breed)
    end
    self
  end

  def self.new_from_db(row)
    new_dog = self.new
    new_dog.id = row[0]
    new_dog.name = row[1]
    new_dog.breed = row[2]
    new_dog
  end

  def self.find_by_name(name)
  sql = <<-SQL
    SELECT * FROM dogs WHERE name = ?
    SQL

    result = DB[:conn].execute(sql, name).map do |row|
    self.new_from_db(row)
    end.first
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, id).map do |row|
    self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
        AND breed = ?
        LIMIT 1
        SQL

       dog = DB[:conn].execute(sql,name,breed)

     if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

end
