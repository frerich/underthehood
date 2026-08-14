defmodule Underthehood.TTYOutputHandler do
  @moduledoc false

  use GenServer

  def start(view_pid, component_id, opts \\ []) do
    GenServer.start_link(__MODULE__, {view_pid, component_id, Keyword.get(opts, :on_data)})
  end

  @impl true
  def init({view_pid, component_id, on_data}) when is_pid(view_pid) do
    {:ok, %{view_pid: view_pid, component_id: component_id, on_data: on_data, acc: nil}}
  end

  @impl true
  def handle_info({:tty_data, data}, state) do
    state = observe(state, data)

    Phoenix.LiveView.send_update(state.view_pid, Underthehood.TerminalComponent,
      id: state.component_id,
      data: data
    )

    {:noreply, state}
  end

  # Optional observer for the raw terminal stream, given as `on_data:` to `Underthehood.terminal/1`.
  #
  # This is the only point at which the *server* sees the shell's bytes, which is what makes it
  # usable for auditing: a terminal echoes input, so the stream carries the commands as well as
  # their results, and none of it originates from the client. Anything derived in the browser could
  # be forged by the person being audited.
  #
  # Called as `fun.(data, acc)` and expected to return the next accumulator, so an observer can
  # buffer partial lines across chunks (the tty emits per keystroke, not per line). A `nil`
  # `on_data` costs one pattern match.
  defp observe(%{on_data: nil} = state, _data), do: state

  defp observe(%{on_data: fun, acc: acc} = state, data) when is_function(fun, 2) do
    %{state | acc: fun.(data, acc)}
  rescue
    e ->
      # an observer must never take the terminal down with it
      require Logger

      Logger.error(
        "Underthehood on_data observer raised, continuing without it: " <>
          Exception.format(:error, e, __STACKTRACE__)
      )

      %{state | on_data: nil}
  end
end
