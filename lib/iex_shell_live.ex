defmodule Underthehood.IexShellLive do
  @moduledoc false

  use Phoenix.LiveView, layout: {Underthehood.LayoutView, "live.html"}
  alias Phoenix.LiveView.{JS, Socket}

  def mount(_session, _params, socket) do
    socket =
      if connected?(socket) do
        {:ok, tty} = ExTTY.start_link(handler: self())
        assign(socket, tty: tty)
      else
        socket
      end

    {:ok, socket}
  end

  def render(%{socket: %Socket{id: id}} = assigns) do
    toggle_js =
      JS.show(to: "##{id} .terminal_element")
      |> JS.hide(to: "##{id} .placeholder_element")

    ~H"""
    <div phx-hook="Terminal" id={id} phx-click={toggle_js}>
      <div class="placeholder_element">
        <p>Peek under the hood...</p>
      </div>
      <div class="terminal_element" style="display: none;" phx-update="ignore"></div>
    </div>
    """
  end

  def handle_info({:tty_data, data}, %Socket{id: id} = socket) do
    {:noreply, push_event(socket, "print_#{id}", %{data: data})}
  end

  def handle_event("key", %{"key" => key}, %Socket{assigns: %{tty: tty}} = socket) do
    ExTTY.send_text(tty, key)
    {:noreply, socket}
  end
end
