defmodule JMDict.Entry do
  alias JMDict.Entry.{KanjiReading, KanaReading, Sense}

  defstruct \
    eid:    "",
    kanji:  [],
    kana:   [],
    senses: []

  def from_map(entry_map) do
    struct __MODULE__, %{
      eid:    entry_map.eid,
      kanji:  Enum.map(entry_map.k_ele, &KanjiReading.from_element/1),
      kana:   Enum.map(entry_map.r_ele, &KanaReading.from_element/1),
      senses: Enum.map(entry_map.sense, &Sense.from_element/1),
    }
  end
end
