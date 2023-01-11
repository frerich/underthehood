defmodule Underthehood.TerminalButtonComponent do
  @moduledoc false

  use Phoenix.LiveComponent
  alias Phoenix.LiveView.JS

  import Underthehood, only: [terminal: 1]

  def render(%{id: _id} = assigns) do
    ~H"""
    <div id={@id} style="position: fixed; bottom: 1em; right: 1em; z-index: 2147483647;">
      <div class="terminal_toggle_button" style="background-color: black; color: lightgray; padding: 0.3em; font-family: monospace; border-radius: 0.5em; cursor: pointer;" phx-click={toggle_terminal(@id)}>
        iex>
      </div>
      <div class="terminal_container" style="display: none; position: relative; border: 2px solid lightgray;">
        <.terminal id={terminal_id(@id)}/>
        <div style="position: absolute; top: 8px; right: 8px; z-index: 2147483647; line-height: 1em; cursor: pointer; color: white;" phx-click={toggle_terminal(@id)}>&#x2715</div>
      </div>
    </div>
    """
  end

  def terminal_id(id), do: "#{id}_terminal"

  def toggle_terminal(id),
    do:
      JS.toggle(to: "##{id} .terminal_toggle_button")
      |> JS.toggle(to: "##{id} .terminal_container")
end
