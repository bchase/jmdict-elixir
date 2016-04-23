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

  test "provides kanji + info", %{entries: entries} do
    akarasama = get_entry_by_eid entries, 1000225
    assert match? [%{text: "明白", info: ["ateji"]}|_], akarasama.kanji
  end

  test "parses kana + info", %{entries: entries} do
    asoko = get_entry_by_eid entries, 1000320
    assert match? [_,_,_,%{text: "あしこ", info: ["ok"]}|_], asoko.kana
  end

  test "parses sense glosses + pos", %{entries: entries} do
    irasshai = get_entry_by_eid entries, 1000920
    assert match? "1000920", irasshai.eid
    assert match? 0, length(irasshai.kanji)
    assert match? [_, %{text: "いらしゃい", info: ["ik"]}], irasshai.kana
    assert match? [%{glosses: ["come"|_], pos: [_,"n"]},_], irasshai.senses
  end

  def get_entry_by_eid(entries, eid) do
    eid = if is_integer(eid), do: eid, else: String.to_integer(eid)

    entries
    |> Stream.take_while(& String.to_integer(&1.eid) <= eid)
    |> Enum.to_list
    |> List.last
  end
end

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
