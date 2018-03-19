require 'pg'
require_relative 'db_persistence'

class DBConnection
  def initialize(app)
    @app = app
    @db = DBPersistence.new(db_connection)
  end

  def db_connection
    if ENV["RACK_ENV"] == 'production'
      PG.connect(ENV['DATABASE_URL'])
    else
      PG.connect(dbname: 'todos')
    end
  end

  def call(env)
    @db.log(env['rack.logger'])
    env['db'] = @db

    @app.call(env)
  end
end
