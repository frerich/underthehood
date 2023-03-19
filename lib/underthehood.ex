defmodule Underthehood do
  @moduledoc """
  A collection of LiveView components providing interactive IEx terminals.

  This module serves as the main public API for using the Underthehood library.
  It provides different Phoenix LiveView components for embedding interactinve
  IEx terminals into templates.
  """
  use Phoenix.Component

  @doc """
  Embed a little button (located in the bottom-right corner of the browser's
  viewport) which, when clicked, opens an IEx terminal. The terminal can be
  closed again by clicking the 'X' button in the top-right corner.

  This component is meant to be invoked using the HEex syntax for function
  components. An optional `id` assign can be passed if desired.

  ## Examples

      defmodule MyAppWeb.DemoLive do
        use MyAppWeb, :live_view

        import Underthehood, only: [terminal_button: 1]

        def render(assigns) do
          ~H\"""
            <div>My markup</div>
            <.terminal_button/>
          \"""
        end
      end
  """
  def terminal_button(assigns) do
    assigns
    |> Map.put_new(:id, :terminal_button)
    |> Map.put(:module, __MODULE__.TerminalButtonComponent)
    |> live_component()
  end

  @doc """
  Embeds a LiveView component representing an interactive IEx terminal to the BEAM.

  Note that there is no built-in way to close this terminal. It's meant as a
  building block for more complex integrations (see e.g.
  `Underthehood.terminal_button/1`).

  This component is meant to be invoked using the HEex syntax for function
  components. An optional `id` assign can be passed if desired (e.g. in case
  more than one terminal window should be shown):

  ## Examples

      <.terminal/>
      <.terminal id={:my_terminal}/>
  """
  def terminal(assigns) do
    assigns
    |> Map.put_new(:id, :terminal)
    |> Map.put(:module, __MODULE__.TerminalComponent)
    |> live_component()
  end
end
