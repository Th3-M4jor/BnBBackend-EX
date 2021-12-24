defmodule ElixirBackendWeb.LibObjView do
  use ElixirBackendWeb, :view

  # @chip_props ~W(id name elem skill range hits targets effect effduration blight damage kind class description custom)a
  # @virus_props ~W(id name element hp ac stats skills drops description cr abilities damage dmgelem blight custom)a
  # @ncp_props ~W(id name cost color description custom)a

  def render("libobj.json", %{objs: objs}) do
    objs
    # Enum.map(chips, fn chip ->
    #  Map.filter(chip, &chips_filter_fn/1)
    # end)
  end
end
