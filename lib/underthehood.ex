defmodule Underthehood do
  @moduledoc """
  Documentation for `Underthehood`.
  """

  def terminal(_socket, id \\ :terminal) do
    Phoenix.LiveView.Helpers.live_component(%{module: Underthehood.IexShellLive, id: id})
  end
end
