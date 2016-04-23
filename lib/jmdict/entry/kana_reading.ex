defmodule JMDict.Entry.KanaReading do
  alias JMDict.XMLEntities

  defstruct \
    text: "",
    info: []

  def from_element(r_ele) do
    struct __MODULE__,
      text: List.first(r_ele.reb),
      info: XMLEntities.vals_to_names(r_ele.re_inf)
  end
end
