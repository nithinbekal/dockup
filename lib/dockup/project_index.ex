defmodule Dockup.ProjectIndex do
  use GenServer

  def start(filename \\ Dockup.Configs.project_index_file) when is_binary(filename) do
    GenServer.start_link(__MODULE__, filename, [name: __MODULE__])
  end

  def write(project_id, properties) do
    GenServer.cast(__MODULE__, {:write, project_id, properties})
  end

  def read(project_id) do
    GenServer.call(__MODULE__, {:read, project_id})
  end

  def all do
    GenServer.call(__MODULE__, :all)
  end

  # Below are used by the GenServer behavior, not intended to be used
  # directly. Use the above public APIs only.

  def init(filename) do
    :dets.open_file(:projects, [file: String.to_char_list(filename), type: :set])
  end

  def handle_cast({:write, project_id, properties}, dets) do
    :ok = :dets.insert(dets, {project_id, properties})
    {:noreply, dets}
  end

  def handle_cast({:delete, project_id}, dets) do
    :ok = :dets.delete(dets, project_id)
    {:noreply, dets}
  end

  def handle_call({:read, project_id}, _from, dets) do
    {project_id, properties} = :dets.lookup(dets, project_id) |> List.first
    {:reply, properties, dets}
  rescue
    _error ->
      {:reply, nil, dets}
  end

  def handle_call(:all, _from, dets) do
    props = :dets.foldl(fn({_pid, props}, acc) -> [props | acc] end, [], dets)
    {:reply, props, dets}
  rescue
    _error ->
      {:reply, [], dets}
  end
end
