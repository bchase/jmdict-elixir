defmodule JMDictTest do
  use ExUnit.Case, async: true

  alias JMDict.XMLEntities

  setup do
    {:ok, entries: JMDict.entries_stream}
  end

  test "ets xml entity val->key lookup" do
    assert match? [{_, "abbr"}], :ets.lookup(:jmdict_xml_entites, "abbreviation")
  end

  test "xml entity lookup key<->val" do
    assert XMLEntities.name_to_val_map["abbr"] == "abbreviation"
    assert XMLEntities.val_to_name_map["abbreviation"] == "abbr"
  end

  test "parses eid", %{entries: entries} do
    akarasama = get_entry_by_eid entries, 1000225

    assert akarasama.eid == "1000225"
  end

  test "parses kanji + info", %{entries: entries} do
    akarasama = get_entry_by_eid entries, 1000225
    asoko     = get_entry_by_eid entries, 1000320

    assert match? [%{text: "明白", info: ["ateji"]}|_], akarasama.kanji
    assert match? [%{lists: ["ichi1"]}|_], asoko.kanji
  end

  test "parses kana/info/lists/nokanji/restr", %{entries: entries} do
    akan       = get_entry_by_eid entries, 1000230
    asoko      = get_entry_by_eid entries, 1000320
    attoiumani = get_entry_by_eid entries, 1000390

    assert match? [_,_,_,%{text: "あしこ", info: ["ok"]}|_], asoko.kana
    assert match? [%{lists: ["ichi1"]}|_], asoko.kana
    assert match? [_,%{nokanji: true}], akan.kana
    assert match? [%{kanji: ["あっという間に", "あっと言う間に"]},_], attoiumani.kana
  end

  test "parses sense glosses, pos, etc", %{entries: entries} do
    # eids = [1000920, 1001390, 1002480, 1000320, 1010230]
    # [irasshai, oden, otenba, asoko] = get_entries_by_eids entries, eids
    irasshai = get_entry_by_eid entries, 1000920
    oden     = get_entry_by_eid entries, 1001390
    otenba   = get_entry_by_eid entries, 1002480
    asoko    = get_entry_by_eid entries, 1000320
    hanpen   = get_entry_by_eid entries, 1010230

    # GLOSS & POS
    assert match? [%{glosses: ["come"|_], pos: [_,"n"]},_], irasshai.senses
    # MISC & INFO
    info = "used as a polite imperative"
    assert match? [%{misc: ["hon"], info: [^info]},_], irasshai.senses
    # XREFS
    assert match? [_,%{xrefs: ["いらっしゃいませ"]}], irasshai.senses
    # FIELD
    assert match? [%{field: ["food"]}], oden.senses
    # STAGK
    assert match? [_,%{stagk: ["半片"]}], hanpen.senses
    # STAGR
    assert match? [_,%{stagr: ["あそこ",_]},_], asoko.senses
  end

  # TODO LSOURCE # assert # <lsource xml:lang="dut">ontembaar</lsource>
  # TODO rename stagk/r
  test "//entry/sense/lsource w/ xml:lang attr"

  def get_entry_by_eid(entries, eid) do
    eid = if is_integer(eid), do: eid, else: String.to_integer(eid)

    entries
    |> Stream.take_while(& String.to_integer(&1.eid) <= eid)
    |> Enum.to_list
    |> List.last
  end

  def get_entries_by_eids(entries, eids) do
    entries
    |> Stream.take_while(& String.to_integer(&1.eid) <= Enum.max(eids))
    |> Stream.reject(fn entry -> Enum.any?(eids, & entry.eid != &1) end)
    |> Enum.to_list
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
