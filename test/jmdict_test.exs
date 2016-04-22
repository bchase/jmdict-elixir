defmodule JMDictTest do
  use ExUnit.Case, async: true

  setup do
    entries = JMDict.entries_stream

    {:ok, entries: entries}
  end

  test "xml entity lookup key<->val" do
    assert JMDict.xml_entities_name_to_val_map["abbr"] == "abbreviation"
    assert JMDict.xml_entities_val_to_name_map["abbreviation"] == "abbr"
  end

  test "provides kanji/kana info", %{entries: entries} do
    akarasama = get_entry_by_eid entries, 1000225
    assert akarasama.kanji_info["明白"] == ["ateji"]

    asoko = get_entry_by_eid entries, 1000320
    assert asoko.kana_info["あしこ"] == ["ok"]
  end

  test "parses xml into stream of struct ", %{entries: entries} do
    kansuujizero = get_entry_by_eid entries, 1000080
    # %JMDict.Entry{eid: "1000080", kanji: ["漢数字ゼロ"], ...}
    assert match? ["漢数字ゼロ"], kansuujizero.kanji

    irasshai = get_entry_by_eid entries, 1000920
    # %JMDict.Entry{eid: "1000920", glosses: ["come", "go", "stay", "welcome!"],
    #   info: ["honorific or respectful (sonkeigo) language"],
    #   kana: ["いらっしゃい", "いらしゃい"], kanji: [],
    #   pos: ["interjection (kandoushi)", "n"],
    #   xrefs: ["いらっしゃる・1", "いらっしゃいませ"]}
    assert match? "1000920", irasshai.eid
    assert match? 0, length(irasshai.kanji)
    assert match? ["いらっしゃい", _], irasshai.kana
    assert match? ["come"|_], irasshai.glosses
    assert match? [_, "n"], irasshai.pos
    assert match? ["hon"], irasshai.info
    assert match? [_,"いらっしゃいませ"], irasshai.xrefs
  end

  def get_entry_by_eid(entries, eid) do
    eid = if is_integer(eid), do: eid, else: String.to_integer(eid)

    entries
    |> Stream.take_while(& String.to_integer(&1.eid) <= eid)
    |> Enum.to_list
    |> List.last
  end
end
