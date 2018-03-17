class DatabasePersistence
  def initialize(connection)
    @connection = connection
  end

  def all_lists
    db_lists = @connection.exec("SELECT * FROM lists").to_a
    db_todos = @connection.exec("SELECT * FROM todos").to_a

    todos = db_todos.map do |todo|
      { id: todo['id'].to_i,
        name: todo['name'],
        completed: to_boolean(todo['completed']),
        list_id: todo['list_id'].to_i
      }
    end

    db_lists.map do |list|
      { id: list['id'].to_i,
        name: list['name'],
        todos: todos.select { |todo| todo[:list_id] == list['id'].to_i }
      }
    end
  end

  def find_list(id)
    all_lists.find{ |list| list[:id] == id }
  end

  def create_list(list_name)
    statement = "INSERT INTO lists (name) VALUES ($1);"
    params = [list_name]
    @connection.exec_params(statement, params)
  end

  def delete_list(id)
    puts "The id is #{id}"
    statement = "DELETE FROM lists WHERE id = $1"
    params = [id]
    @connection.exec_params(statement, params)
  end

  def update_list(id, name)
    statement = "UPDATE lists SET name = $2 WHERE id = $1"
    params = [id, name]
    @connection.exec_params(statement, params)
  end

  def find_todo(list_id, todo_id)
    list = find_list(list_id)
    list[:todos].find { |todo| todo[:id] == todo_id }
  end

  def add_todo(list_id, content)
    statement = "INSERT INTO todos (name, list_id) VALUES ($2, $1)"
    params = [list_id, content]
    @connection.exec_params(statement, params)
  end

  def delete_todo(todo_id)
    statement = "DELETE FROM todos WHERE id = $1"
    params = [todo_id]
    @connection.exec_params(statement, params)
  end

  def update_todo(todo_id, completed_status)
    statement = "UPDATE todos SET completed = $2 where id = $1"
    params = [todo_id, completed_status]
    @connection.exec_params(statement, params)
  end

  def complete_all_todos(list_id)
    statement = "UPDATE todos SET completed = true where list_id = $1"
    params = [list_id]
    @connection.exec_params(statement, params)
  end

  private

  def to_boolean(status)
    status == 't' ? true : false
  end
end
