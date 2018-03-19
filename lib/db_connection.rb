require 'pg'

class DBConnection
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  end

  class << self

    attr_reader :db

    def setup
      @db =
        if ENV["RACK_ENV"] == 'production'
          PG.connect(ENV['DATABASE_URL'])
        else
          PG.connect(dbname: 'todos')
        end
    end
  end

  setup
end
