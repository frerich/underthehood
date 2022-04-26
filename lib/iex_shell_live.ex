defmodule Underthehood.IexShellLive.Helper do
  @moduledoc false

  use GenServer

  @impl true
  def init({view_pid, component_id}) do
    {:ok, {view_pid, component_id}}
  end

  @impl true
  def handle_info({:tty_data, data}, {view_pid, component_id} = state) do
    Phoenix.LiveView.send_update(view_pid, Underthehood.IexShellLive, id: component_id, data: data)

    {:noreply, state}
  end
end

defmodule Underthehood.IexShellLive do
  @moduledoc false

  use Phoenix.LiveComponent
  alias Phoenix.LiveView.{JS, Socket}

  def render(%{component_id: component_id} = assigns) do
    toggle_js =
      JS.show(to: "##{component_id} .terminal_element")
      |> JS.hide(to: "##{component_id} .placeholder_element")

    ~H"""
    <div phx-hook="Terminal" id={component_id} phx-click={toggle_js}>
      <div class="placeholder_element">
        <%= render_slot(@inner_block) %>
      </div>
      <div class="terminal_element" style="display: none;" phx-update="ignore"></div>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div>
    </div>
    """
  end

  def update(%{id: component_id, data: data}, socket) do
    {:ok, push_event(socket, "print_#{component_id}", %{data: data})}
  end

  def update(%{id: component_id} = assigns, socket) do
    if connected?(socket) do
      {:ok, helper_pid} =
        GenServer.start_link(Underthehood.IexShellLive.Helper, {self(), component_id})

      {:ok, tty} = ExTTY.start_link(handler: helper_pid)

      socket =
        socket
        |> assign(:component_id, component_id)
        |> assign(:tty, tty)
        |> assign(:inner_block, assigns.inner_block)

      {:ok, socket}
    else
      {:ok, socket}
    end
  end

  def handle_event("key", %{"key" => key}, %Socket{assigns: %{tty: tty}} = socket) do
    ExTTY.send_text(tty, key)
    {:noreply, socket}
  end
end
