defmodule JMDict.Entry do
  alias JMDict.XMLEntities

  alias JMDict.Entry.{KanjiReading, KanaReading, Sense}

  defstruct eid: "",
    kanji:       [],
    kana:        [],
    senses:      [],
    pos:         [],
    info:        [],
    xrefs:       []

  def from_map(entry_map) do
    entry_map = Map.merge entry_map, %{
      kanji:  Enum.map(entry_map.k_ele, &KanjiReading.from_element/1),
      kana:   Enum.map(entry_map.r_ele, &KanaReading.from_element/1),
      senses: Enum.map(entry_map.sense, &Sense.from_element/1),
    }

    struct __MODULE__, entry_map
  end
end
