defmodule JMDictTest do
  use ExUnit.Case, async: true

  setup do
    entries = JMDict.entries_stream

    {:ok, entries: entries}
  end

  test "xml entity lookup key<->val" do
    assert JMDict.xml_entities_name_to_val["abbr"] == "abbreviation"
    assert JMDict.xml_entities_val_to_name["abbreviation"] == "abbr"
  end

  test "parses xml into stream of struct ", %{entries: entries} do
    # %JMDict.Entry{eid: "1000080", kanji: ["漢数字ゼロ"], ...}
    %{kanji: [kanji]} = get_entry_by_eid entries, 1000080
    assert kanji == "漢数字ゼロ"

    # %JMDict.Entry{eid: "1000920", glosses: ["come", "go", "stay", "welcome!"],
    #   info: ["honorific or respectful (sonkeigo) language"],
    #   kana: ["いらっしゃい", "いらしゃい"], kanji: [],
    #   pos: ["interjection (kandoushi)", "n"],
    #   xrefs: ["いらっしゃる・1", "いらっしゃいませ"]}
    irasshai = get_entry_by_eid entries, 1000920
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
    assert g1 == "come"
    assert pos2 == "n"
    assert info == "hon"
    assert xref2 == "いらっしゃいませ"
  end

  def get_entry_by_eid(entries, eid) do
    eid = if is_integer(eid), do: eid, else: String.to_integer(eid)

    entries
    |> Stream.take_while(& String.to_integer(&1.eid) <= eid)
    |> Enum.to_list
    |> List.last
  end
end
