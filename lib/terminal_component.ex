defmodule Underthehood.TerminalComponent do
  @moduledoc false

  use Phoenix.LiveComponent
  alias Phoenix.LiveView.{JS, Socket}

  def render(%{component_id: component_id} = assigns) do
    toggle_js =
      JS.toggle(to: "##{component_id} .terminal_element")
      |> JS.toggle(to: "##{component_id} .placeholder_element")

    ~H"""
    <div phx-hook="Terminal" id={component_id} phx-click={toggle_js}>
      <div class="placeholder_element">
        <%= if @inner_block != [] do %>
          <%= render_slot(@inner_block) %>
        <% else %>
          Open IEx
        <% end %>
      </div>
      <div class="terminal_element" style="display: none;" phx-update="ignore"></div>
    </div>
    """
  end

  def update(%{id: component_id, data: data}, socket) do
    {:ok, push_event(socket, "print_#{component_id}", %{data: data})}
  end

  def update(%{id: component_id} = assigns, socket) do
    inner_block = Map.get(assigns, :inner_block, [])

    socket =
      socket
      |> assign(:component_id, component_id)
      |> assign(:inner_block, inner_block)
      |> assign_tty(component_id)

    {:ok, socket}
  end

  def handle_event("key", %{"key" => key}, %Socket{assigns: %{tty: tty}} = socket) do
    ExTTY.send_text(tty, key)
    {:noreply, socket}
  end

  defp assign_tty(socket, component_id) do
    if connected?(socket) do
      {:ok, output_handler} = Underthehood.TTYOutputHandler.start(self(), component_id)

      {:ok, tty} = ExTTY.start_link(handler: output_handler)

      assign(socket, :tty, tty)
    else
      socket
    end
  end
end
