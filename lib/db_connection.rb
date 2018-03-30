require 'pg'
require_relative 'db_persistence'

class DBConnection
  def initialize(app)
    @app = app
  end

  def db_connect
    if ENV["RACK_ENV"] == 'production'
      PG.connect(ENV['DATABASE_URL'])
    else
      PG.connect(dbname: 'todos')
    end
  end

  def db_wrap(db_connection, env)
    DBPersistence.new(db_connection, env['rack.logger'])
  end

  def call(env)
    db_connection = db_connect
    env['storage'] = db_wrap(db_connection, env)
    response = @app.call(env)
    db_connection.close
    response
  end
end
