defmodule ExampleWeb.ExampleView do
  use ExampleWeb, :live_view

  def render(assigns) do
    ~H"""
    Hello, this is a LiveView.

    Try clicking the IEx button in the bottom-right corner to open a command
    line interface which lets you interact with the BEAM much like IEx does.

    <Underthehood.terminal_button />
    """
  end
end

