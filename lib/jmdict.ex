defmodule JMDict do
  import SweetXml

  alias JMDict.XML
  alias JMDict.XMLEntities

  alias JMDict.EntryXML

  alias JMDict.Entry
  alias JMDict.Entry.{KanjiReading, KanaReading}


  def entries_stream do
    XMLEntities.populate_ets_xml_entites

    # xml_file_stream
    # |> stream_tags([:entry])
    # |> query_for_entry_values
    # |> set_additional_values # |> entity_vals_to_names # |> map_to_entries
    JMDict.XML.stream
    |> stream_tags([:entry])
    |> query_for_entry_values
    |> map_to_entries
    |> entity_vals_to_names
  end

  defp query_for_entry_values(entries) do
    entries
    |> Stream.map(&EntryXML.parse/1)
  end

  defp map_to_entries(entries) do
    entries
    |> Stream.map(fn entry_map ->
      entry_map = Map.merge entry_map, %{
        kanji: Enum.map(entry_map.k_ele, &KanjiReading.from_element/1),
        kana:  Enum.map(entry_map.r_ele, &KanaReading.from_element/1),
      }

      struct Entry, entry_map
    end)
  end

  defp entity_vals_to_names(entries) do
    entries
    |> Stream.map(fn entry ->
      %{entry |
        pos:  XMLEntities.vals_to_names(entry.pos),
        info: XMLEntities.vals_to_names(entry.info),
      }
    end)
  end
end
