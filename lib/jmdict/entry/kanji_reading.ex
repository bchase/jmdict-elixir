defmodule JMDict.Entry.KanjiReading do
  alias JMDict.XMLEntities

  defstruct \
    text:  "",
    info:  [],
    lists: []

  def from_element(k_ele) do
    struct __MODULE__,
      text:  List.first(k_ele.keb),
      info:  XMLEntities.vals_to_names(k_ele.ke_inf),
      lists: k_ele.ke_pri
  end
end
