defmodule Underthehood.TerminalComponent do
  @moduledoc false

  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <div phx-hook="Terminal" id={@id}>
      <div class="xtermjs_container" phx-update="ignore"></div>
    </div>
    """
  end

  def update(%{id: id, data: data}, socket) do
    {:ok, push_event(socket, "print_#{id}", %{data: data})}
  end

  def update(%{id: id} = assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign_tty(id)

    {:ok, socket}
  end

  def handle_event("key", %{"key" => key}, %{assigns: %{tty: tty}} = socket) do
    ExTTY.send_text(tty, key)
    {:noreply, socket}
  end

  defp assign_tty(socket, id) do
    if connected?(socket) do
      {:ok, output_handler} = Underthehood.TTYOutputHandler.start(self(), id)

      {:ok, tty} = ExTTY.start_link(handler: output_handler)

      assign(socket, :tty, tty)
    else
      socket
    end
  end
end
