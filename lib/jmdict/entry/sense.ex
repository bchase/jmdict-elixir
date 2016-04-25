defmodule JMDict.Entry.Sense do
  alias JMDict.XMLEntities

  alias JMDict.Entry.Sense.Source

  defstruct \
    glosses: [],
    sources: [],
    pos:     [],
    dial:    [],
    info:    [],
    misc:    [],
    field:   [],
    xrefs:   [],
    stagk:   [],
    stagr:   []

  def from_element(sense) do
    struct __MODULE__, %{
      glosses: sense.gloss,
      sources: Source.parse(sense.lsource),
      pos:     XMLEntities.vals_to_names(sense.pos),
      dial:    XMLEntities.vals_to_names(sense.dial),
      misc:    XMLEntities.vals_to_names(sense.misc),
      field:   XMLEntities.vals_to_names(sense.field),
      info:    sense.s_inf,
      xrefs:   sense.xref,
      stagk:   sense.stagk,
      stagr:   sense.stagr,
    }
  end
end
