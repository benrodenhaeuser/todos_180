class SessionPersistence
  def initialize(session)
    @session = session
    @session[:lists] ||= []
  end

  def all_lists
    @session[:lists]
  end

  def find_list(id)
    all_lists.find{ |list| list[:id] == id }
  end

  def create_list(list_name)
    id = next_element_id(all_lists)
    all_lists << { id: id, name: list_name, todos: [] }
  end

  def delete_list(id)
    all_lists.reject! { |list| list[:id] == id }
  end

  def update_list(id, name)
    find_list(id)[:name] = name
  end

  def find_todo(list_id, todo_id)
    list = find_list(list_id)
    list[:todos].find { |todo| todo[:id] == todo_id }
  end

  def add_todo(list_id, content)
    list = find_list(list_id)
    todo_id = next_element_id(list[:todos])
    list[:todos] << { id: todo_id, name: content, completed: false }
  end

  def delete_todo(list_id, todo_id)
    list = find_list(list_id)
    list[:todos].reject! { |todo| todo[:id] == todo_id }
  end

  def update_todo(list_id, todo_id, completed_status)
    todo = find_todo(list_id, todo_id)
    todo[:completed] = completed_status
  end

  def complete_all_todos(list_id)
    list = find_list(list_id)
    list[:todos].each { |todo| todo[:completed] = true }
  end

  private

  def next_element_id(elements)
    max = elements.map { |todo| todo[:id] }.max || 0
    max + 1
  end
end
