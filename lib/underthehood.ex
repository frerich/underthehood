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

  ## Auditing the session

  Say who is at the keyboard and at what level to record:

      <.terminal id={:my_terminal} audit_label={@current_user.username} audit_level={:warning}/>

  Each completed line the shell emits is then logged (see `Underthehood.Audit`). Because a terminal echoes input, that stream carries the commands as well as their output, and because it is read server-side in the tty handler, it cannot be shaped by whoever is typing.

  `audit_level` accepts a Logger level, or `false` to switch this terminal off. Omit it to defer to `config :underthehood, audit: …`, which takes `true`, `false` (the default), or a level.

  For a different sink (a database, a SIEM, etc.) pass `audit_callback`, which takes precedence over both:

      <.terminal id={:my_terminal} audit_callback={&MyApp.Audit.observe/2}/>

  It is called as `fun.(data, acc)` and returns the next accumulator, so it can buffer partial lines, as the tty emits per keystroke, not per line. A callback that raises is dropped and logged; it never takes the terminal down.
  """
  def terminal(assigns) do
    assigns
    |> Map.put_new(:id, :terminal)
    |> Map.put(:module, __MODULE__.TerminalComponent)
    |> live_component()
  end
end
