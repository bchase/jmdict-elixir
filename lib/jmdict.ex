defmodule JMDict do
  import SweetXml

  def entries_stream do
    JMDict.XMLEntities.populate_ets

    JMDict.XML.stream
    |> stream_tags([:entry])
    |> Stream.map(&JMDict.EntryXML.parse/1)
    |> Stream.map(&JMDict.Entry.from_map/1)
  end
end
