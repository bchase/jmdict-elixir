defmodule JMDictTest do
  use ExUnit.Case, async: true

  setup do
    entries = JMDict.entries_stream

    {:ok, entries: entries}
  end

  test "ets xml entity val->key lookup" do
    assert match? [{_, "abbr"}], :ets.lookup(:jmdict_xml_entites, "abbreviation")
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
    assert match? [%{text: "漢数字ゼロ"}], kansuujizero.kanji
    # assert match? ["漢数字ゼロ"], kansuujizero.kanji

    irasshai = get_entry_by_eid entries, 1000920
    # %JMDict.Entry{
    #   eid: "1000920",
    #
    #   kanji: [],
    #
    #   kana: [
    #     [
    #       %Reading{
    #         text:    "いらっしゃい",
    #         info:     [],
    #         priority: ["spec1"],
    #       },
    #       %Reading{
    #         text:    "いらしゃい",
    #         info:     ["ik"],
    #         priority: [],
    #       }
    #   ],
    #
    #   senses: [
    #     %Sense{
    #       glosses: ["welcome!"],
    #       pos:     ["int", "n"],
    #       # misc:    ["hon"], # TODO rename...<misc>
    #       # field:   ["hon"], # TODO rename...<misc>
    #       # dial:    ["hon"], # TODO rename...<misc>
    #       xrefs:   ["いらっしゃる・1"],
    #       info:    ["used as a polite imperative"]
    #     },
    #     %Sense{
    #       glosses: ["come", "go", "stay"],
    #       xrefs:   ["いらっしゃいませ"]
    #     }
    #   ]
    # }
    assert match? "1000920", irasshai.eid
    assert match? 0, length(irasshai.kanji)
    # assert match? ["いらっしゃい", _], irasshai.kana
    # assert match? %{"いらしゃい" => ["ik"]}, irasshai.kana_info
    # TODO assert match? [_, %{text: "いらしゃい", info: ["ik"]}], irasshai.kana
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
