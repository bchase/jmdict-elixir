defmodule JMDict do
  import SweetXml

  alias JMDict.XML
  alias JMDict.XMLEntities

  alias JMDict.EntryXML

  alias JMDict.Entry
  alias JMDict.Entry.{KanjiReading, KanaReading}


  def entries_stream do
    XMLEntities.populate_ets_xml_entites

    JMDict.XML.stream
    |> stream_tags([:entry])
    |> Stream.map(&EntryXML.parse/1)
    |> Stream.map(&Entry.from_map/1)
  end
end
