defmodule Stack.Server do
  use GenServer

  #####
  # External API

  def start_link(stash_pid) do
    GenServer.start_link(__MODULE__, stash_pid, name: __MODULE__)
  end

  def pop do
    GenServer.call(__MODULE__, :pop)
  end

  def push(element) do
    GenServer.cast(__MODULE__, {:push, element})
  end

  #####
  # GenServer Implementation

  def init(stash_pid) do
    current_stack = Stack.Stash.get_value stash_pid
    { :ok, {current_stack, stash_pid } }
  end

  def handle_call(:pop, _from, {current_stack, stash_pid}) when length(current_stack) == 0 do
    raise "Invalid Operation: pop on empty stack"
  end

  def handle_call(:pop, _from, {current_stack, stash_pid}) do
    first_element = List.first(current_stack)
    new_list = List.delete_at(current_stack, 0)

    { :reply, first_element, {new_list, stash_pid} }
  end

  def handle_cast({:push, new_element}, current_stack) when not is_number(new_element) do
    raise "Invalid Operation: element must be a valid number"
  end

  def handle_cast({:push, new_element}, {current_stack, stash_pid}) do
    new_list = List.insert_at(current_stack, 0, new_element)

    { :noreply, {new_list, stash_pid} }
  end

  def terminate(_reason, {current_stack, stash_pid}) do
    Stack.Stash.save_value stash_pid, current_stack
  end

  def format_status(_reason, [ _pdict, state ]) do
    [data: [{'State', "My current state is '#{inspect state}'"}]]
  end
end
