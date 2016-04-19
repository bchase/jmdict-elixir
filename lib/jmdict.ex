defmodule JMDict do
  import SweetXml

  defmodule Entry do
    defstruct eid: "",
      pos: [],
      kanji: [],
      kana: [],
      glosses: []
  end

  def entries_stream do
    xml_stream
    |> stream_tags([:entry])
    |> Stream.map(fn {_, doc} ->
      entry = xpath doc, ~x"//entry"e,
        eid:     eid_xpath,
        kanji:   kanji_xpath,
        kana:    kana_xpath,
        pos:     pos_xpath,
        glosses: glosses_xpath
      struct(Entry, entry)
    end)
  end

  defp eid_xpath,     do: ~x"./ent_seq/text()"
  defp kanji_xpath,   do: ~x"./k_ele/keb/text()"l
  defp kana_xpath,    do: ~x"./r_ele/reb/text()"l
  defp pos_xpath,     do: ~x"./sense/pos/text()"l
  defp glosses_xpath, do: ~x"./sense/gloss/text()"l

  defp xml_entities do
    xml_entity_re = ~r{ENTITY ([^ ]+) "(.+?)"}
    match_arr_to_map = fn ([_, key, val]) ->
      %{key: key, value: val}
    end

    dtd_html = get_body(dtd_url)

    Regex.scan(xml_entity_re, dtd_html)
    |> Enum.map(match_arr_to_map)
  end

  defp xml_stream do
    xml_filepath = "/tmp/JMdict_e"

    unless File.exists? xml_filepath do
      get_xml!
    end

    File.stream! xml_filepath
  end

  def dtd_url do
    "http://www.edrdg.org/jmdict/jmdict_dtd_h.html"
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
    %{body: body} = HTTPoison.get! url
    body
  end
end
