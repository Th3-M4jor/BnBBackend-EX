defmodule ElixirBackendWeb.VirusView do
  use ElixirBackendWeb, :view

  def render("viruses.json", %{viruses: viruses}) do
    viruses
  end

end
