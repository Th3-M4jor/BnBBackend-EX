defmodule ElixirBackendWeb.LibObjView do
  use ElixirBackendWeb, :view

  @chip_props ~W(id name elem skill range hits targets effect effduration blight damage kind class description custom)a
  @virus_props ~W(id name element hp ac stats skills drops description cr abilities damage dmgelem blight custom)a
  @ncp_props ~W(id name cost color description custom)a


  def render("libobj.json", %{kind: "chips", objs: chips}) do
    Enum.map(chips, fn chip ->
      :maps.filter(&chips_filter_fn/2, chip)
    end)
  end

  def render("libobj.json", %{kind: "viruses", objs: viruses}) do
    Enum.map(viruses, fn virus ->
      :maps.filter(&virus_filter_fn/2, virus)
    end)
  end

  def render("libobj.json", %{kind: "ncps", objs: ncp}) do
    Enum.map(ncp, fn ncp ->
      :maps.filter(&ncp_filter_fn/2, ncp)
    end)
  end

  defp chips_filter_fn(key, value) when key in @chip_props and not is_nil(value) do
    true
  end

  defp chips_filter_fn(_, _) do
    false
  end

  defp virus_filter_fn(key, value) when key in @virus_props and not is_nil(value) do
    true
  end

  defp virus_filter_fn(_, _) do
    false
  end

  defp ncp_filter_fn(key, value) when key in @ncp_props and not is_nil(value) do
    true
  end

  defp ncp_filter_fn(_, _) do
    false
  end

end
