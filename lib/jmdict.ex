defmodule JMDict do
  import SweetXml

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

  def entries_stream do
    xml_stream
    |> stream_tags([:entry])
    |> query_for_entry_values
    |> map_to_entries
    |> entity_vals_to_names
  end

  defp query_for_entry_values(entries) do
    entries
    |> Stream.map(fn {_, doc} ->
      xpath doc, ~x"//entry"e,
        eid:     eid_xpath,
        kanji:   kanji_xpath,
        kana:    kana_xpath,
        glosses: glosses_xpath,
        pos:     pos_xpath,
        xrefs:   xrefs_xpath,
        info:    info_xpath,

        # these are removed later for
        # `kanji_info` and `kana_info`
        k_eles: ~x"./k_ele"le,
        r_eles: ~x"./r_ele"le
    end)
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
    |> Enum.map(&List.to_tuple/1)
    |> Enum.into(%{})
  end

  def xml_entities_val_to_name_map do
    xml_entities
    |> Enum.map(&Enum.reverse/1)
    |> Enum.map(&List.to_tuple/1)
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
  end

  defp eid_xpath,     do: ~x"./ent_seq/text()"s
  defp kanji_xpath,   do: ~x"./k_ele/keb/text()"ls
  defp kana_xpath,    do: ~x"./r_ele/reb/text()"ls
  defp glosses_xpath, do: ~x"./sense/gloss/text()"ls
  defp pos_xpath,     do: ~x"./sense/pos/text()"ls
  defp xrefs_xpath,   do: ~x"./sense/xref/text()"ls
  defp info_xpath do
    ~x"./sense/misc/text() | ./sense/dial/text() | ./sense/field/text()"ls
  end

  defp xml_stream do
    xml_filepath = "/tmp/JMdict_e"

    unless File.exists? xml_filepath do
      get_xml!
    end

    File.stream! xml_filepath
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
