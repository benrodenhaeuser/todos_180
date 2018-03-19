require 'pg'

class DBConnection
  def initialize(app)
    @app = app
    @db = setup_db
  end

  def setup_db
    if ENV["RACK_ENV"] == 'production'
      PG.connect(ENV['DATABASE_URL'])
    else
      PG.connect(dbname: 'todos')
    end
  end 

  def call(env)
    env['db'] = @db
    @app.call(env)
  end
end
