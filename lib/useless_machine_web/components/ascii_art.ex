defmodule UselessMachineWeb.Components.AsciiArt do
  use Phoenix.Component

  attr :file_path, :string, required: true, doc: "Path to the ASCII art file"

  def ascii_art(assigns) do
    file_contents =
      assigns.file_path
      |> File.read!()

    assigns = assign(assigns, :content, file_contents)

    ~H"""
    <pre class="ascii-art"><code><%= @content %></code></pre>
    """
  end
end
