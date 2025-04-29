defmodule UselessMachineWeb.AsciiArt do
  use Phoenix.Component
  require Logger

  attr :file_path, :string, doc: "Path to the ASCII art file"
  attr :class, :string, default: "text-[8px]", doc: "Supplementary classes for the pre element"

  def ascii_art(assigns) do
    file_contents =
      if is_binary(assigns.file_path) do
        assigns.file_path
        |> File.read!()
      else
        # Logger.debug("No assign `file_path`")
        ""
      end

    assigns = assign(assigns, :content, file_contents)

    ~H"""
    <pre class={[@class, "ascii-art"]}><code><%= @content %></code></pre>
    """
  end
end
