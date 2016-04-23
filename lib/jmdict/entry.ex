defmodule JMDict.Entry do
  alias JMDict.XMLEntities

  defstruct eid: "",
    kanji:       [],
    kana:        [],
    glosses:     [],
    pos:         [],
    info:        [],
    xrefs:       []

  defmodule KanjiReading do
    defstruct \
      text: "",
      info: []

    def from_element(k_ele) do
      struct __MODULE__,
        text: List.first(k_ele.keb),
        info: XMLEntities.vals_to_names(k_ele.ke_inf)
    end
  end

  defmodule KanaReading do
    defstruct \
      text: "",
      info: []

    def from_element(r_ele) do
      struct __MODULE__,
        text: List.first(r_ele.reb),
        info: XMLEntities.vals_to_names(r_ele.re_inf)
    end
  end
end
