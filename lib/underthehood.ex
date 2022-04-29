defmodule Underthehood do
  @moduledoc """
  Documentation for `Underthehood`.
  """
  use Phoenix.Component

  import Phoenix.LiveView.Helpers, only: [live_component: 1]

  def terminal_button(assigns) do
    assigns
    |> Map.put_new(:id, :terminal_button)
    |> Map.put(:module, __MODULE__.TerminalButtonComponent)
    |> live_component()
  end

  def terminal(assigns) do
    assigns
    |> Map.put_new(:id, :terminal)
    |> Map.put(:module, __MODULE__.TerminalComponent)
    |> live_component()
  end
end
