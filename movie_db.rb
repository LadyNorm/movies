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
      title VARCHAR,
      id SERIAL PRIMARY KEY
    );"
    )
  result.entries
end

def insert_into_movies(title, id)
  sql = "INSERT INTO movies (title, id) VALUES ($1, $2)"

  result = connect.exec_params(sql, [title, id])
  result.entries
end

def add_movies
  result = RestClient.get("movies.api.mks.io/movies")
  movies = JSON.parse(result)
  puts "TEST"
  puts movies

  movies.each do |movie|
    insert_into_movies(movie["title"], movie["id"])
  end
end

def create_join_table
  result = connect.exec(
    "CREATE TABLE IF NOT EXISTS actors_movies(
      id SERIAL PRIMARY KEY,
      actorId INTEGER,
      movieId INTEGER
      );"
    )
  result.entries
end

def insert_into_join(id, movieId)
  sql = "INSERT INTO actors_movies (actorId, movieId) VALUES ($1, $2)"

  result = connect.exec_params(sql, [id, movieId])
  result.entries
end

def add_actors_movies
  result = connect.exec("SELECT id FROM movies;")
  movies = []
  result.entries.each do |movie|
    query = "movies.api.mks.io/movies/" + movie['id'] + "/actors"
    result = RestClient.get(query)
    movies << JSON.parse(result)
  end
  movies.flatten!
  movies.each do |move|
    result = insert_into_join(move['id'], move['movieId'])
  end
end

#   result = connect.exec("SELECT id FROM actors;")
#   actors = []
#   result.entries.each do |actor|
#     query = "movies.api.mks.io/actors/" + actor['id'] + "/movies"
#     result = RestClient.get(query)
#     actors << JSON.parse(result)
#   end
#   actors.flatten!
# end

def all_actors
  result = connect.exec("SELECT * FROM actors ORDER BY name;")
  result.entries
end

def all_movies
  result = connect.exec("SELECT * FROM movies ORDER BY name;")
  result.entries
end

def frequent_actors
  result = connect.exec("SELECT COUNT(actorId) AS actor FROM actors_movies ORDER BY actor DESC;")
  result.entries
end

def in_movie(movieId)
  result = connect.exec("SELECT * FROM actors_movies WHERE movieId = #{movieId};")
end














