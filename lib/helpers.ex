defmodule Underthehood.Helpers do
  defmacro maybe_import_live_view_helpers() do
    live_view_version = Application.spec(:phoenix_live_view, :vsn) |> to_string()

    if Version.compare(live_view_version, "0.18.0") == :lt do
      quote do
        import Phoenix.LiveView.Helpers, only: [live_component: 1]
      end
    end
  end
end
