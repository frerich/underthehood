defmodule Underthehood.TTYOutputHandler do
  @moduledoc false

  use GenServer

  def start(view_pid, component_id) do
    GenServer.start_link(__MODULE__, {view_pid, component_id})
  end

  @impl true
  def init({view_pid, component_id}) when is_pid(view_pid) do
    {:ok, {view_pid, component_id}}
  end

  @impl true
  def handle_info({:tty_data, data}, {view_pid, component_id} = state) do
    Phoenix.LiveView.send_update(view_pid, Underthehood.IexShellLive, id: component_id, data: data)

    {:noreply, state}
  end
end
