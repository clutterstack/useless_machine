defmodule UselessMachineWeb.AsciiArt do
  use Phoenix.Component

  attr :file_path, :string, doc: "Path to the ASCII art file"
  attr :bg_class, :string, default: "bg-black"

  def ascii_art(assigns) do
    file_contents =
      if assigns.file_path != nil do
        assigns.file_path
        |> dbg
        |> File.read!()
      else
        # IO.puts("No assign `file_path`")
        ""
      end

    assigns = assign(assigns, :content, file_contents)

    ~H"""
    <pre class={"ascii-art #{@bg_class}"}><code><%= @content %></code></pre>
    """
  end
end
