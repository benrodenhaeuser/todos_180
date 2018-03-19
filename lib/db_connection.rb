require 'pg'

class DBConnection
  def initialize(app)
    @app = app
    self.class.setup
  end

  def call(env)
    @app.call(env)
  end

  class << self
    def db
      @db
    end

    def setup
      @db =
        if ENV["RACK_ENV"] == 'production'
          PG.connect(ENV['DATABASE_URL'])
        else
          PG.connect(dbname: 'todos')
        end
    end
  end
end
