defmodule JMDict do
  import SweetXml

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
    xml_file_stream
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

  def xml_file_stream do
    xml_filepath = "/tmp/JMdict_e"

    unless File.exists? xml_filepath do
      get_xml!
    end

    File.stream!(xml_filepath)
  end

  def xml_url do
    "http://ftp.monash.edu.au/pub/nihongo/JMdict_e.gz"
  end

  defp get_xml! do
    filename = Path.basename xml_url
    filepath = "/tmp/#{filename}"

    unless String.ends_with? filename, ".gz" do
      raise "#{filename} is not a .gz file"
    end

    unless File.exists?(filepath) do
      IO.puts "fetching JMdict_e... this could take a while"
      File.write! filepath, get_body(xml_url)
    end

    System.cmd "gunzip", [filepath]
  end

  defp get_body(url) do
    HTTPoison.start
    %{body: body} = HTTPoison.get! url, [], timeout: 20_000
    body
  end
end
