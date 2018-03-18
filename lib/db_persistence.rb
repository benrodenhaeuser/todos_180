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
    db_lists = query("SELECT * FROM lists")
    db_todos = query("SELECT * FROM todos")

    in_app_format(db_lists, db_todos)
  end

  def find_list(id)
    db_list = query("SELECT * FROM lists WHERE id = $1", id)
    db_todos = query("SELECT * FROM todos WHERE list_id = $1", id)

    in_app_format(db_list, db_todos).first
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

  private

  def in_app_format(db_lists, db_todos)
    todos = db_todos.map do |todo|
      {
        id: todo['id'].to_i,
        name: todo['name'],
        completed: todo['completed'] == 't',
        list_id: todo['list_id'].to_i
      }
    end

    db_lists.map do |list|
      {
        id: list['id'].to_i,
        name: list['name'],
        todos: todos.select { |todo| todo[:list_id] == list['id'].to_i }
      }
    end
  end
end
