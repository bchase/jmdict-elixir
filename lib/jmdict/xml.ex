defmodule JMDict.XML do
  def stream do
    get_xml!
    File.stream!(xml_filepath)
  end

  def url do
    "http://ftp.monash.edu.au/pub/nihongo/JMdict_e.gz"
  end

  defp xml_filepath, do: "/tmp/JMdict_e"
  defp gz_filepath,  do: "/tmp/#{gz_filename}"
  defp gz_filename,  do: Path.basename url

  defp get_xml! do
    unless File.exists? xml_filepath do
      IO.puts "fetching JMdict_e... this could take a while"
      File.write! gz_filepath, get_body(url)
      System.cmd "gunzip", [gz_filepath]
    end
  end

  defp get_body(url) do
    HTTPoison.start
    HTTPoison.get!(url).body
  end
end
