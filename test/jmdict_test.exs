defmodule JMDictTest do
  use ExUnit.Case, async: true

  alias JMDict.XMLEntities

  setup do
    entries = JMDict.entries_stream

    {:ok, entries: entries}
  end

  test "ets xml entity val->key lookup" do
    assert match? [{_, "abbr"}], :ets.lookup(:jmdict_xml_entites, "abbreviation")
  end

  test "xml entity lookup key<->val" do
    assert XMLEntities.name_to_val_map["abbr"] == "abbreviation"
    assert XMLEntities.val_to_name_map["abbreviation"] == "abbr"
  end

  test "provides kanji/kana info", %{entries: entries} do
    akarasama = get_entry_by_eid entries, 1000225
    assert match? [%{text: "明白", info: ["ateji"]}|_], akarasama.kanji

    asoko = get_entry_by_eid entries, 1000320
    assert match? [_,_,_,%{text: "あしこ", info: ["ok"]}|_], asoko.kana
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
    #       # misc:    ["hon"],
    #       # field:   ["hon"],
    #       # dial:    ["hon"],
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
    assert match? [_, %{text: "いらしゃい", info: ["ik"]}], irasshai.kana
    assert match? [%{glosses: ["come"|_]},_], irasshai.senses

    # TODO parse the rest of //entry/sense
    # assert match? ["hon"], irasshai.info
    # assert match? [_,"いらっしゃいませ"], irasshai.xrefs
    assert match? [_, "n"], irasshai.pos
  end

  def get_entry_by_eid(entries, eid) do
    eid = if is_integer(eid), do: eid, else: String.to_integer(eid)

    entries
    |> Stream.take_while(& String.to_integer(&1.eid) <= eid)
    |> Enum.to_list
    |> List.last
  end
end
