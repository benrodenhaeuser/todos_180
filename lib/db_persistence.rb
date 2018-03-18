class DatabasePersistence
  def initialize(connection, logger)
    @db = connection
    @logger = logger
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
          JOIN todos
            ON lists.id = todos.list_id
      GROUP BY lists.id
      ORDER BY lists.name;
    SQL

    query(sql).map do |list|
      {
        id: list['id'].to_i,
        name: list['name'],
        todos_count: list['todos_count'].to_i,
        incomplete_todos_count: list['incomplete_todos_count'].to_i
      }
    end
  end

  def find_list(id)
    sql = <<~SQL
        SELECT lists.id,
               lists.name,
               count(todos.id) AS todos_count,
               count(nullif(todos.completed, true)) AS incomplete_todos_count
          FROM lists
          JOIN todos
            ON lists.id = todos.list_id
         WHERE lists.id = $1
      GROUP BY lists.id
      ORDER BY lists.name;
    SQL

    list_tuple = query(sql, id).first

    todo_tuples = query("SELECT * FROM todos WHERE list_id = $1", id)

    todos = todo_tuples.map do |todo|
      {
        id: todo['id'].to_i,
        name: todo['name'],
        completed: todo['completed'] == 't'
      }
    end

    {
      id: list_tuple['id'].to_i,
      name: list_tuple['name'],
      todos_count: list_tuple['todos_count'].to_i,
      incomplete_todos_count: list_tuple['incomplete_todos_count'].to_i,
      todos: todos
    }
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
      "UPDATE lists SET name = $2 WHERE id = $1",
      id,
      name
    )
  end

  def find_todo(list_id, todo_id)
    list = find_list(list_id)
    list[:todos].find { |todo| todo[:id] == todo_id }
  end

  def add_todo(list_id, content)
    query(
      "INSERT INTO todos (name, list_id) VALUES ($2, $1)",
      list_id,
      content
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
      "UPDATE todos SET completed = $2 where id = $1",
      todo_id,
      completed_status
    )
  end

  def complete_all_todos(list_id)
    query(
      "UPDATE todos SET completed = true where list_id = $1",
      list_id
    )
  end
end
