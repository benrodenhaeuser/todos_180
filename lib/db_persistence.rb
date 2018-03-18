class DatabasePersistence
  def initialize(connection)
    @connection = connection
  end

  def all_lists
    db_lists = @connection.exec("SELECT * FROM lists")
    db_todos = @connection.exec("SELECT * FROM todos")

    convert_for_display(db_lists, db_todos)
  end

  def find_list(id)
    db_list = @connection.exec("SELECT * FROM lists WHERE id = $1", [id])
    db_todos = @connection.exec("SELECT * FROM todos WHERE list_id = $1", [id])

    convert_for_display(db_list, db_todos)
  end

  def create_list(list_name)
    @connection.exec_params(
      "INSERT INTO lists (name) VALUES ($1)",
      [list_name]
    )
  end

  def delete_list(id)
    @connection.exec_params(
      "DELETE FROM lists WHERE id = $1",
      [id]
    )
  end

  def update_list(id, name)
    @connection.exec_params(
      "UPDATE lists SET name = $2 WHERE id = $1",
      [id, name]
    )
  end

  def find_todo(list_id, todo_id)
    list = find_list(list_id)
    list[:todos].find { |todo| todo[:id] == todo_id }
  end

  def add_todo(list_id, content)
    @connection.exec_params(
      "INSERT INTO todos (name, list_id) VALUES ($2, $1)",
      [list_id, content]
    )
  end

  def delete_todo(todo_id)
    @connection.exec_params(
      "DELETE FROM todos WHERE id = $1",
      [todo_id]
    )
  end

  def update_todo(todo_id, completed_status)
    @connection.exec_params(
      "UPDATE todos SET completed = $2 where id = $1",
      [todo_id, completed_status]
    )
  end

  def complete_all_todos(list_id)
    @connection.exec_params(
      "UPDATE todos SET completed = true where list_id = $1",
      [list_id]
    )
  end

  private

  def to_boolean(status)
    status == 't' ? true : false
  end

  def convert_for_display(db_lists, db_todos)
    todos = db_todos.map do |todo|
      {
        id: todo['id'].to_i,
        name: todo['name'],
        completed: to_boolean(todo['completed']),
        list_id: todo['list_id'].to_i
      }
    end

    lists = db_lists.map do |list|
      {
        id: list['id'].to_i,
        name: list['name'],
        todos: todos.select { |todo| todo[:list_id] == list['id'].to_i }
      }
    end

    lists.length > 1 ? lists : lists.first
  end
end
