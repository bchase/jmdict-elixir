defmodule JMDict.Entry.Sense.Source do
  import SweetXml

  defstruct \
    word:  "",
    lang:  "eng",
    type:  "full",
    wasei: false

  def parse([]), do: []
  def parse(lsources) do
    Enum.map(lsources, fn lsource ->
      struct __MODULE__, %{
        word:  xpath(lsource, ~x"//lsource/text()"s),
        lang:  lang_val_for(lsource),
        type:  type_val_for(lsource),
        wasei: wasei_val_for(lsource),
      }
    end)
  end

  defp lang_val_for(lsource) do
    attr = attr_val(lsource, :"xml:lang")
    if attr, do: to_string(elem(attr, 8)), else: "eng"
  end

  defp type_val_for(lsource) do
    attr = attr_val(lsource, :ls_type)
    if attr, do: to_string(elem(attr, 8)), else: "full"
  end

  defp wasei_val_for(lsource) do
    attr = attr_val(lsource, :ls_wasei)
    if attr, do: to_string(elem(attr, 8)) == "y", else: false
  end

  defp attr_val(lsource, attr_atom) do
    lsource
    |> elem(7)
    |> Enum.find(& elem(&1, 1) == attr_atom)
  end
end
