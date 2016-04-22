defmodule JMDictTest do
  use ExUnit.Case, async: true

  setup do
    entries = JMDict.entries_stream

    {:ok, entries: entries}
  end

  test "parses xml entities into key/val pairs" do
    assert JMDict.xml_entities["abbr"] == "abbreviation"
  end

  test "parses xml into stream of struct ", %{entries: entries} do
    %{kanji: [kanji]} = entries
                        |> Stream.take_while(& String.to_integer(&1.eid) <= 1000080)
                        |> Enum.to_list
                        |> List.last

    assert kanji == "漢数字ゼロ"

    irasshai = entries
                |> Stream.take_while(& String.to_integer(&1.eid) <= 1000920)
                |> Enum.to_list
                |> List.last

    %{
      eid:      eid,
      kanji:    kanji,
      kana:    [kana1, _],
      glosses: [g1|_],
      pos:     [_, pos2],
      info:    [info],
      xrefs:   [_, xref2],
    } = irasshai

    assert eid == "1000920"
    assert length(kanji) == 0
    assert kana1 == "いらっしゃい"
    assert String.contains?(pos2, "futsuumeishi")
    assert String.contains?(info, "sonkeigo")
    assert xref2 == "いらっしゃいませ"
  end
end

# %JMDict.Entry{eid: "1000080", kanji: ["漢数字ゼロ"], ...}
#
# %JMDict.Entry{eid: "1000920", glosses: ["come", "go", "stay", "welcome!"],
#   info: ["honorific or respectful (sonkeigo) language"],
#   kana: ["いらっしゃい", "いらしゃい"], kanji: [],
#   pos: ["interjection (kandoushi)", "noun (common) (futsuumeishi)"],
#   xrefs: ["いらっしゃる・1", "いらっしゃいませ"]}
