require 'pg'

class DBConnection
  def initialize(app)
    @app = app
  end

  def call(env)
    env['dbconnection'] = PG.connect(dbname: 'todos')

    status, headers, body = @app.call(env)

    [status, headers, body]
  end
end
