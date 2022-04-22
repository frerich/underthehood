defmodule Underthehood do
  @moduledoc """
  Documentation for `Underthehood`.
  """
  use Phoenix.Component

  def terminal(assigns) do
    assigns
    |> Map.put_new(:id, :terminal)
    |> Map.put(:module, Underthehood.IexShellLive)
    |> Phoenix.LiveView.Helpers.live_component()
  end
end
