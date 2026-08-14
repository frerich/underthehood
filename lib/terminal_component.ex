defmodule Underthehood.TerminalComponent do
  @moduledoc false

  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <div phx-hook="Terminal" id={@id}>
      <div class="xtermjs_container" phx-update="ignore" id={"xtermjs-container-#{@id}"}></div>
    </div>
    """
  end

  def update(%{id: id, data: data}, socket) do
    {:ok, push_event(socket, "print_#{id}", %{data: data})}
  end

  def update(%{id: id} = assigns, socket) do
    # an explicit `audit_callback` wins; otherwise the built-in transcript logger, which returns nil
    # (the no-op path) when `audit_level` or config says off
    on_data =
      Map.get(assigns, :audit_callback) ||
        Underthehood.Audit.observer(
          label: Map.get(assigns, :audit_label),
          level: Map.get(assigns, :audit_level)
        )

    socket =
      socket
      |> assign(assigns)
      |> assign_tty(id, on_data)

    {:ok, socket}
  end

  def handle_event("key", %{"key" => key}, %{assigns: %{tty: tty}} = socket) do
    :ok = ExTTY.send_text(tty, key)
    {:noreply, socket}
  end

  defp assign_tty(socket, id, on_data) do
    if connected?(socket) do
      {:ok, output_handler} = Underthehood.TTYOutputHandler.start(self(), id, on_data: on_data)

      {:ok, tty} = ExTTY.start_link(handler: output_handler)

      assign(socket, :tty, tty)
    else
      socket
    end
  end
end
