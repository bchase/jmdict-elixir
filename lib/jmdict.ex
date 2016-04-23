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
    :ets.lookup(:jmdict_xml_entites, val)
  end

  defmodule Entry do
    defstruct eid: "",
      kanji:       [],
      kana:        [],
      glosses:     [],
      pos:         [],
      info:        [],
      xrefs:       [],
      kanji_info: %{},
      kana_info:  %{}
  end

  defp ets_xml_ent_val_to_name_table, do: :jmdict_xml_entites
  defp populate_ets_xml_entites do
    table_name = ets_xml_ent_val_to_name_table

    if :ets.info(table_name) == :undefined do
      :ets.new(table_name, [:set, :named_table])
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

  defp get_kanji_info(eles) do
    get_char_info eles,
      ~x"//k_ele"e, ~x"./keb/text()"ls, ~x"./ke_inf/text()"ls
  end

  defp get_kana_info(eles) do
    get_char_info eles,
      ~x"//r_ele"e, ~x"./reb/text()"ls, ~x"./re_inf/text()"ls
  end

  defp get_char_info(eles, ele_xpath, char_xpath, inf_xpath) do
    Enum.reduce(eles, %{}, fn ele, char_info ->
      ele = xpath ele, ele_xpath,
        infs:  inf_xpath,
        chars: char_xpath

      if length(ele.infs) > 0 do
        [char] = ele.chars
        Map.put char_info, char, ele.infs
      else
        char_info
      end
    end)
  end

  defp map_to_entries(entries) do
    entries
    |> Stream.map(fn entry_map ->
      entry_map = Map.merge entry_map, %{
        kanji: Enum.map(entry_map.k_ele, &KanjiReading.from_element/1),
        kana:  Enum.map(entry_map.r_ele, &KanaReading.from_element/1),
        # kana:  Enum.map(entry_map.r_ele, & List.first(&1.reb)),
        kanji_info: get_kanji_info(entry_map.k_eles),
        kana_info:  get_kana_info(entry_map.r_eles)
      }

      struct Entry, entry_map
    end)
  end

  defp entity_vals_to_names(entries) do
    val_for_name_map = xml_entities_val_to_name_map

    vals_arr_to_names = fn arr -> Enum.map arr, &val_for_name_map[&1] end
    info_map_vals_to_names = fn info_map ->
      Enum.reduce(info_map, %{}, fn {kanji, info_arr}, new_map ->
        Map.put new_map, kanji, vals_arr_to_names.(info_arr)
      end)
    end

    entries
    |> Stream.map(fn entry ->
      %{entry |
        pos:        vals_arr_to_names.(entry.pos),
        info:       vals_arr_to_names.(entry.info),
        kanji_info: info_map_vals_to_names.(entry.kanji_info),
        kana_info:  info_map_vals_to_names.(entry.kana_info)
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
