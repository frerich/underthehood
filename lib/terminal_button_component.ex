defmodule Underthehood.TerminalButtonComponent do
  @moduledoc false

  use Phoenix.LiveComponent
  alias Phoenix.LiveView.JS

  import Underthehood, only: [terminal: 1]

  def update(assigns, socket) do
    terminal_id = "#{assigns.id}_terminal"
    {:ok, assign(socket, :terminal_id, terminal_id)}
  end

  def render(assigns) do
    ~H"""
    <div id={@id} style="position: fixed; bottom: 1em; right: 1em; z-index: 2147483647;">
      <div class="terminal_toggle_button" style="background-color: black; color: lightgray; padding: 0.3em; font-family: monospace; border-radius: 0.5em; cursor: pointer;" phx-click={toggle_terminal(@id)}>
        iex>
      </div>
      <div class="terminal_container" style="display: none; position: relative; border: 2px solid lightgray;">
        <.terminal id={@terminal_id}/>
        <div style="position: absolute; top: 8px; right: 8px; z-index: 2147483647; line-height: 1em; cursor: pointer; color: white;" phx-click={toggle_terminal(@id)}>&#x2715</div>
      </div>
    </div>
    """
  end

  defp toggle_terminal(component_id, js \\ %JS{}) do
    js
    |> JS.toggle(to: "##{component_id} .terminal_toggle_button")
    |> JS.toggle(to: "##{component_id} .terminal_container")
  end
end
