defmodule JMDictTest do
  use ExUnit.Case, async: true

  setup_all do
    entries = JMDict.entries_stream

    entries = %{
      akarasama:    get_entry_by_eid(entries, 1000225),
      asoko:        get_entry_by_eid(entries, 1000320),
      kansuujizero: get_entry_by_eid(entries, 1000080),
      irasshai:     get_entry_by_eid(entries, 1000920),
    }

    {:ok, entries: entries}
  end

  test "xml entity lookup key<->val" do
    assert JMDict.xml_entities_name_to_val_map["abbr"] == "abbreviation"
    assert JMDict.xml_entities_val_to_name_map["abbreviation"] == "abbr"
  end

  test "provides kanji/kana info", %{entries: e} do
    assert e.akarasama.kanji_info["明白"] == ["ateji"]
    assert e.asoko.kana_info["あしこ"] == ["ok"]
  end

  test "parses xml into stream of struct ", %{entries: e} do
    # %JMDict.Entry{eid: "1000080", kanji: ["漢数字ゼロ"], ...}
    assert match? ["漢数字ゼロ"], e.kansuujizero.kanji

    # %JMDict.Entry{eid: "1000920", glosses: ["come", "go", "stay", "welcome!"],
    #   info: ["honorific or respectful (sonkeigo) language"],
    #   kana: ["いらっしゃい", "いらしゃい"], kanji: [],
    #   pos: ["interjection (kandoushi)", "n"],
    #   xrefs: ["いらっしゃる・1", "いらっしゃいませ"]}
    assert match? "1000920", e.irasshai.eid
    assert match? 0, length(e.irasshai.kanji)
    assert match? ["いらっしゃい", _], e.irasshai.kana
    assert match? ["come"|_], e.irasshai.glosses
    assert match? [_, "n"], e.irasshai.pos
    assert match? ["hon"], e.irasshai.info
    assert match? [_,"いらっしゃいませ"], e.irasshai.xrefs
  end

  def get_entry_by_eid(entries, eid) do
    eid = if is_integer(eid), do: eid, else: String.to_integer(eid)

    entries
    |> Stream.take_while(& String.to_integer(&1.eid) <= eid)
    |> Enum.to_list
    |> List.last
  end
end
