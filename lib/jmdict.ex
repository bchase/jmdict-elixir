defmodule JMDict do
  import SweetXml

  alias JMDict.EntryXML

  defmodule KanjiReading do
    defstruct \
      text: "",
      info: []

    def from_element(k_ele) do
      struct __MODULE__,
        text: List.first(k_ele.keb),
        info: JMDict.entity_vals_arr_to_names(k_ele.ke_inf)
    end
  end

  defmodule KanaReading do
    defstruct \
      text: "",
      info: []

    def from_element(r_ele) do
      struct __MODULE__,
        text: List.first(r_ele.reb),
        info: JMDict.entity_vals_arr_to_names(r_ele.re_inf)
    end
  end

  def entity_vals_arr_to_names(arr) do
    Enum.map arr, &xml_entity_val_to_name/1
  end
  def xml_entity_val_to_name(val) do
    [{_, name}] = :ets.lookup(ets_xml_ent_val_to_name_table, val)
    name
  end

  defmodule Entry do
    defstruct eid: "",
      kanji:       [],
      kana:        [],
      glosses:     [],
      pos:         [],
      info:        [],
      xrefs:       []
  end

  defp ets_xml_ent_val_to_name_table, do: :jmdict_xml_entites
  defp populate_ets_xml_entites do
    if :ets.info(ets_xml_ent_val_to_name_table) == :undefined do
      :ets.new(ets_xml_ent_val_to_name_table, [:named_table])
      |> :ets.insert(xml_entities_val_to_name)
    end
  end

  def entries_stream do
    populate_ets_xml_entites

    # xml_stream
    # |> stream_tags([:entry])
    # |> query_for_entry_values
    # |> set_additional_values # |> entity_vals_to_names # |> map_to_entries
    xml_stream
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
        pos:  entity_vals_arr_to_names(entry.pos),
        info: entity_vals_arr_to_names(entry.info),
      }
    end)
  end

  def xml_entities_name_to_val_map do
    xml_entities
    |> Enum.into(%{})
  end

  defp xml_entities_val_to_name do
    xml_entities
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&Enum.reverse/1)
    |> Enum.map(&List.to_tuple/1)
  end
  def xml_entities_val_to_name_map do
    xml_entities_val_to_name
    |> Enum.into(%{})
  end

  defp xml_entity_re, do: ~r{\<\!ENTITY ([^\s]+) "(.+)"\>}
  defp xml_entities do
    xml_stream
    |> Stream.take_while(& !Regex.match? ~r{^\<JMdict}, &1)
    |> Enum.to_list
    |> Enum.map(fn line ->
        Regex.run xml_entity_re, line, capture: :all_but_first
    end)
    |> Enum.reject(& is_nil &1)
    |> Enum.map(&List.to_tuple/1)
  end

  defp xml_stream do
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
