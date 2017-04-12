require "pry"

class Dog
  attr_accessor :name, :breed
  attr_reader :id


  def initialize (id: nil,name:,breed:)
      @name = name
      @breed = breed
      @id = id
  end

  def self.create_table
      sql = "CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )"
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = "INSERT INTO dogs (name,breed) VALUES (?,?)"
      DB[:conn].execute(sql,self.name,self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      Dog.new(id:self.id,name:self.name,breed:self.breed)
    end
  end

  def self.create (attributes)
    new_dog = Dog.new(attributes)
    new_dog.save
    new_dog
  end

  def self.find_by_id (id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql,id)[0]
    Dog.new({id: result[0],name: result[1],breed: result[2]})
  end

  def self.find_or_create_by(name:, breed:)
    new_dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !new_dog.empty?
      dog_traits = new_dog[0]
      new_dog = Dog.new({id: dog_traits[0],name: dog_traits[1],breed: dog_traits[2]})
    else
      new_dog = self.create(name: name, breed: breed)
    end
    new_dog
  end

  def self.new_from_db (row)
    new_dog = Dog.new({id: row[0],name: row[1],breed: row[2]})
    new_dog
  end

  def self.find_by_name (name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    result = DB[:conn].execute(sql,name)[0]
    Dog.new({id: result[0],name: result[1],breed: result[2]})
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql,self.name,self.breed,self.id)
  end
end
