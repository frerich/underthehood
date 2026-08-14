defmodule Underthehood.AuditTest do
  @moduledoc """
  The transcript is what makes an embedded shell defensible after the fact, so the parts that could silently drop it (line buffering across chunks, the off switch, the unterminated-line cap) are pinned here.
  """

  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  alias Underthehood.Audit

  setup do
    on_exit(fn -> Application.delete_env(:underthehood, :audit) end)
  end

  describe "level/1" do
    test "an explicit level wins over config" do
      Application.put_env(:underthehood, :audit, false)
      assert Audit.level(level: :warning) == :warning
    end

    test "false switches off even when config says on" do
      Application.put_env(:underthehood, :audit, :info)
      assert Audit.level(level: false) == nil
    end

    test "omitted defers to config, in each of its shapes" do
      Application.put_env(:underthehood, :audit, false)
      assert Audit.level([]) == nil

      Application.put_env(:underthehood, :audit, true)
      assert Audit.level([]) == :info

      Application.put_env(:underthehood, :audit, :error)
      assert Audit.level([]) == :error
    end

    test "off by default" do
      Application.delete_env(:underthehood, :audit)
      assert Audit.level([]) == nil
    end
  end

  describe "observer/1" do
    test "is nil when off, which is the handler's no-op path" do
      refute Audit.observer(level: false)
    end

    test "is a 2-arity accumulator function when on" do
      assert is_function(Audit.observer(level: :info), 2)
    end
  end

  describe "observe/3" do
    @opts [level: :warning, label: "alice (01H)", prefix: "CONSOLE"]

    test "logs nothing until a line is complete, and returns the partial" do
      log = capture_log(fn -> assert Audit.observe("Users.li", nil, @opts) == "Users.li" end)
      refute log =~ "Users.li"
    end

    test "logs a line once it terminates, with label and prefix" do
      log = capture_log(fn -> assert Audit.observe("Users.list()\n", "", @opts) == "" end)

      assert log =~ "CONSOLE alice (01H): Users.list()"
    end

    test "assembles a line split across chunks, as a tty emits it per keystroke" do
      log =
        capture_log(fn ->
          acc = Enum.reduce(["Us", "ers", ".list()"], nil, &Audit.observe(&1, &2, @opts))
          assert Audit.observe("\n", acc, @opts) == ""
        end)

      assert log =~ "Users.list()"
    end

    test "logs several lines from one chunk, keeping the trailing partial" do
      log = capture_log(fn -> assert Audit.observe("one\ntwo\nthr", nil, @opts) == "thr" end)

      assert log =~ "one"
      assert log =~ "two"
      refute log =~ "thr"
    end

    test "strips ANSI escapes so the log stays greppable" do
      log = capture_log(fn -> Audit.observe("\e[32miex>\e[0m 1+1\n", nil, @opts) end)

      assert log =~ "iex> 1+1"
      refute log =~ "\e["
    end

    test "truncates a long line" do
      log = capture_log(fn -> Audit.observe(String.duplicate("x", 50) <> "\n", nil, [{:max_line, 10} | @opts]) end)

      assert log =~ String.duplicate("x", 10)
      refute log =~ String.duplicate("x", 11)
    end

    test "flushes an unterminated line past max_buffer, so it can't grow without bound" do
      opts = [{:max_buffer, 8} | @opts]

      log =
        capture_log(fn ->
          # a pager or raw-mode program that never emits a newline
          assert Audit.observe(String.duplicate("y", 20), nil, opts) == ""
        end)

      assert log =~ "yyyy"
    end

    # :error rather than :debug — the test env's Logger level filters debug out before it reaches
    # capture_log, so that would assert nothing
    test "respects the configured level" do
      log = capture_log(fn -> Audit.observe("hello\n", nil, level: :error, label: "bob") end)
      assert log =~ "[error"
      assert log =~ "bob: hello"
    end
  end
end
