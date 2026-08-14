defmodule Underthehood.Audit do
  @moduledoc """
  Logs the terminal session as a transcript.

  Embedding a shell in a web app usually comes with wanting a record of what was done in it, so this
  ships with the library rather than being left to each host app. Drive it from the terminal's own
  assigns:

      <.terminal id={:term} audit_label="alice" audit_level={:warning} />

  Or enable it for every terminal at once:

      config :underthehood, audit: true      # or a level, e.g. :warning

  A per-terminal `audit_level` overrides that either way — including `false` to switch one terminal
  off — so a host that always wants an audit, or never does, need not depend on deployment config.

  ## What it records, and what that is worth

  It logs the *transcript*: what was typed and what came back. Because a terminal echoes input, both
  arrive on the same stream, and they are not distinguishable — a tty offers no marker separating an
  echoed keystroke from a result. So treat this as a session recording, not a list of commands.

  It is worth more than anything gathered in the browser: this runs in the tty handler process, on
  the bytes the shell actually produced, so it cannot be shaped by whoever is at the keyboard.

  Output can be voluminous (one listing can be thousands of lines), hence `:max_line` truncation
  and the `:max_buffer` cap for programs that never emit a newline.

  ## Options

    * `:label` — identifies the actor in each entry; the host app supplies whatever it knows
    * `:level` — Logger level to audit at, or `false` to switch off regardless of config. Omitted,
      the `:underthehood, :audit` config decides.
    * `:prefix` — prepended to each entry, default `"tty"`
    * `:max_line` — truncate each line, default `2_000`
    * `:max_buffer` — flush an unterminated line beyond this, default `16_000`
  """

  require Logger

  @default_max_line 2_000
  @default_max_buffer 16_000

  @doc """
  Builds an observer, or `nil` when auditing is off.

  `nil` is meaningful: it is the handler's no-op path, so being switched off costs one pattern match
  per chunk rather than a conditional inside the hot path.
  """
  def observer(opts \\ []) do
    if level = level(opts) do
      fun_opts = Keyword.put(opts, :level, level)
      fn data, acc -> observe(data, acc, fun_opts) end
    end
  end

  @doc """
  Resolves the Logger level to audit at, or `nil` when off.

  Distinguishes "not specified" from "explicitly off", so a caller can force auditing off for one
  terminal without touching config, and omitting the option still honours config:

      level: false   -> off, whatever config says
      level: :warning -> on, at :warning
      level: nil      -> defer to `config :underthehood, audit: …`

  The config value accepts the same shapes: `false` (the default), `true` for `:info`, or a level.
  """
  def level(opts \\ []) do
    case Keyword.get(opts, :level) do
      nil -> from_config(Application.get_env(:underthehood, :audit, false))
      other -> normalise(other)
    end
  end

  defp from_config(value), do: normalise(value)

  defp normalise(false), do: nil
  defp normalise(nil), do: nil
  defp normalise(true), do: :info
  defp normalise(level) when is_atom(level), do: level

  @doc "Accumulates `data` into `acc`, logging each completed line. Returns the next accumulator."
  def observe(data, acc, opts \\ []) do
    max_buffer = Keyword.get(opts, :max_buffer, @default_max_buffer)
    buffer = (acc || "") <> data

    case String.split(buffer, ~r/\r?\n/) do
      [partial] when byte_size(partial) > max_buffer ->
        # never terminated a line: a pager, a raw-mode program, a prompt awaiting input. Flush so
        # the buffer can't grow without bound.
        log(partial, opts)
        ""

      [partial] ->
        partial

      lines ->
        {complete, [partial]} = Enum.split(lines, -1)
        Enum.each(complete, &log(&1, opts))
        partial
    end
  end

  defp log(line, opts) do
    case clean(line, Keyword.get(opts, :max_line, @default_max_line)) do
      "" ->
        :ok

      text ->
        prefix = Keyword.get(opts, :prefix, "tty")
        label = Keyword.get(opts, :label)
        who = if label, do: " #{label}", else: ""

        Logger.log(Keyword.get(opts, :level, :info), "#{prefix}#{who}: #{text}")
    end
  end

  # strip ANSI sequences and stray control bytes so the log stays greppable
  defp clean(line, max_line) do
    line
    |> String.replace(~r/\e\[[0-9;?]*[ -\/]*[@-~]/, "")
    |> String.replace(~r/[\x00-\x08\x0b-\x1f\x7f]/, "")
    |> String.trim()
    |> String.slice(0, max_line)
  end
end
