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

  def call(env)
    db_connection = db_connect
    db_persistence = DBPersistence.new(db_connection)
    db_persistence.log(env['rack.logger'])
    env['db'] = db_persistence

    status, headers, body = @app.call(env)

    db_connection.close

    [status, headers, body]
  end
end
