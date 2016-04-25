defmodule JMDict.Entry.KanaReading do
  alias JMDict.XMLEntities

  defstruct \
    text:    "",
    nokanji: false,
    info:    [],
    lists:   [],
    kanji:   []

  def from_element(r_ele) do
    struct __MODULE__,
      text:     List.first(r_ele.reb),
      nokanji: !!r_ele.re_nokanji,
      info:     XMLEntities.vals_to_names(r_ele.re_inf),
      lists:    r_ele.re_pri,
      kanji:    r_ele.re_restr
  end
end
