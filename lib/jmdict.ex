defmodule JMDict do
  import SweetXml

  defmodule Entry do
    defstruct eid: "",
      kanji:   [],
      kana:    [],
      glosses: [],
      pos:     [],
      info:    [],
      xrefs:   []
  end

  def entries_stream(opts \\ [entities_to_val: true]) do
    xml_stream
    |> stream_tags([:entry])
    |> Stream.map(fn {_, doc} ->
      e = xpath doc, ~x"//entry"e,
        eid:     eid_xpath,
        kanji:   kanji_xpath,
        kana:    kana_xpath,
        glosses: glosses_xpath,
        pos:     pos_xpath,
        xrefs:   xrefs_xpath,
        info:    info_xpath
      struct Entry, e
    end)
  end

  def xml_entity_re, do: ~r{\<\!ENTITY ([^\s]+) "(.+)"\>}
  def xml_entities do
    xml_stream
    |> Stream.take_while(& !Regex.match? ~r{^\<JMdict}, &1)
    |> Enum.to_list
    |> Enum.map(fn line ->
        Regex.run xml_entity_re, line, capture: :all_but_first
    end)
    |> Enum.reject(& is_nil &1)
    |> Enum.map(&List.to_tuple/1)
    |> Enum.into(%{})
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
