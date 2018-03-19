class DBPersistence
  def initialize(connection)
    @db = connection
  end

  def log(logger)
    @logger = logger
    self
  end

  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end

  def all_lists
    sql = <<~SQL
          SELECT lists.id,
                 lists.name,
                 count(todos.id) AS todos_count,
                 count(nullif(todos.completed, true)) AS incomplete_todos_count
            FROM lists
       LEFT JOIN todos
              ON lists.id = todos.list_id
        GROUP BY lists.id
        ORDER BY lists.name;
    SQL

    query(sql).map { |list_tuple| tuple_to_list_hash(list_tuple) }
  end

  def find_list(id)
    sql = <<~SQL
          SELECT lists.id,
                 lists.name,
                 count(todos.id) AS todos_count,
                 count(nullif(todos.completed, true)) AS incomplete_todos_count
            FROM lists
       LEFT JOIN todos
              ON lists.id = todos.list_id
           WHERE lists.id = $1
        GROUP BY lists.id
        ORDER BY lists.name;
    SQL

    tuple_to_list_hash(
      query(sql, id).first
    )
  end

  def todos_for_list(id)
    todo_tuples =
      query(
        "SELECT * FROM todos WHERE list_id = $1",
        id
      )

    todos = todo_tuples.map do |todo|
      {
        id: todo['id'].to_i,
        name: todo['name'],
        completed: todo['completed'] == 't'
      }
    end
  end

  def create_list(list_name)
    query(
      "INSERT INTO lists (name) VALUES ($1)",
      list_name
    )
  end

  def delete_list(id)
    query(
      "DELETE FROM lists WHERE id = $1",
      id
    )
  end

  def update_list(id, name)
    query(
      "UPDATE lists SET name = $1 WHERE id = $2",
      name,
      id
    )
  end

  def find_todo(list_id, todo_id)
    list = find_list(list_id)
    list[:todos].find { |todo| todo[:id] == todo_id }
  end

  def add_todo(list_id, content)
    query(
      "INSERT INTO todos (name, list_id) VALUES ($1, $2)",
      content,
      list_id
    )
  end

  def delete_todo(todo_id)
    query(
      "DELETE FROM todos WHERE id = $1",
      todo_id
    )
  end

  def update_todo(todo_id, completed_status)
    query(
      "UPDATE todos SET completed = $1 where id = $2",
      completed_status,
      todo_id
    )
  end

  def complete_all_todos(list_id)
    query(
      "UPDATE todos SET completed = true where list_id = $1",
      list_id
    )
  end

  private

  def tuple_to_list_hash(list_tuple)
    {
      id: list_tuple['id'].to_i,
      name: list_tuple['name'],
      todos_count: list_tuple['todos_count'].to_i,
      incomplete_todos_count: list_tuple['incomplete_todos_count'].to_i
    }
  end
end
