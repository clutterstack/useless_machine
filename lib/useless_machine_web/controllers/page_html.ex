defmodule UselessMachineWeb.PageHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use UselessMachineWeb, :html
  require Logger

  embed_templates "page_html/*"
end
