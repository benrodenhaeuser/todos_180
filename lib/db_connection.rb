require 'pg'

class DBConnection
  def initialize(app)
    @app = app
  end

  def call(env)
    env['dbconnection'] =
      if Sinatra::Base.production?
        PG.connect(ENV['DATABASE_URL'])
      else
        PG.connect(dbname: 'todos')
      end

    @app.call(env)
  end
end
