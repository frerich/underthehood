defmodule Underthehood do
  @moduledoc """
  Documentation for `Underthehood`.
  """

  def terminal(socket, id \\ :terminal) do
    Phoenix.LiveView.Helpers.live_render(socket, Underthehood.IexShellLive, id: id)
  end
end
