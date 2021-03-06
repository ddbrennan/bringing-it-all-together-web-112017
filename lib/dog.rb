require 'pry'

class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
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

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(dog_hash)
    new_dog = Dog.new(name: dog_hash[:name], breed: dog_hash[:breed])
    new_dog.save
    new_dog
  end

  def self.new_from_db(row)
    Dog.new(name: row[1], breed: row[2], id: row[0])
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL

    query = DB[:conn].execute(sql, id)[0]
    new_dog = Dog.new_from_db(query)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
    SQL

    query = DB[:conn].execute(sql, name)[0]
    new_dog = Dog.new_from_db(query)
  end

  def self.find_or_create_by(dog_hash)
    sql = "SELECT * FROM dogs WHERE name = \"#{dog_hash[:name]}\" AND breed = \"#{dog_hash[:breed]}\""
    found = DB[:conn].execute(sql)[0]
    if found
      new_dog = Dog.new_from_db(found)
    else
      new_dog = self.create(dog_hash)
    end
    new_dog
  end

end
