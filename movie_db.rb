require 'pg'
require 'rest-client'

def connect
  @conn ||= PG::Connection.new(host: 'localhost', dbname: 'movie_db')
end

def create_actor_table
  result = connect.exec(
    "CREATE TABLE IF NOT EXISTS actors(
      name VARCHAR,
      id SERIAL PRIMARY KEY
    );"
    )
  result.entries
end

def insert_into_actors(name, id)
  sql = "INSERT INTO actors (name, id) VALUES ($1, $2)"

  result = connect.exec_params(sql, [name, id])
  result.entries
end

def add_actors
  result = RestClient.get("movies.api.mks.io/actors")
  actors = JSON.parse(result)

  actors.each do |actor|
    insert_into_actors(actor["name"], actor["id"])
  end
end

def create_movie_table
  result = connect.exec(
    "CREATE TABLE IF NOT EXISTS movies(
      name VARCHAR,
      id SERIAL PRIMARY KEY
    );"
    )
  result.entries
end

def insert_into_movies(name, id)
  sql = "INSERT INTO movies (name, id) VALUES ($1, $2)"

  result = connect.exec_params(sql, [name, id])
  result.entries
end

def add_movies
  result = RestClient.get("movies.api.mks.io/movies")
  movies = JSON.parse(result)

  movies.each do |movie|
    insert_into_movies(movie["name"], movie["id"])
  end
end

def create_join_table
  result = connect.exec(
    "CREATE TABLE IF NOT EXISTS actors_movies(
      id PRIMARY SERIAL KEY,
      actorId INTEGER,
      movieId INTEGER
      );"
    )
end

def insert_into_join
  
end














