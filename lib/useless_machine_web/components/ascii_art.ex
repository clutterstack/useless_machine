defmodule UselessMachineWeb.AsciiArt do
  use Phoenix.Component
  require Logger

  # attr :file_path, :string, doc: "Path to the ASCII art file"
  attr :content, :string, doc: "The contents of the ASCII art file"
  attr :class, :string, default: "text-[8px]", doc: "Supplementary classes for the pre element"

  def ascii_art(assigns) do
    ~H"""
    <pre id="ascii-display" class={[@class, "ascii-art"]} phx-update="replace"><code><%= @content %></code></pre>
    """
  end
end
