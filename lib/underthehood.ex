defmodule Underthehood do
  @moduledoc """
  Documentation for `Underthehood`.
  """
  use Phoenix.Component

  def terminal_button(assigns) do
    assigns
    |> Map.put_new(:id, :terminal_button)
    |> Map.put(:module, Underthehood.TerminalButtonComponent)
    |> Phoenix.LiveView.Helpers.live_component()
  end

  def terminal(assigns) do
    assigns
    |> Map.put_new(:id, :terminal)
    |> Map.put(:module, Underthehood.TerminalComponent)
    |> Phoenix.LiveView.Helpers.live_component()
  end
end
