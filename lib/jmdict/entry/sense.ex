defmodule JMDict.Entry.Sense do
  alias JMDict.XMLEntities

  defstruct \
    glosses: [],
    lsource: [],
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
      glosses: sense.gloss, # attr g_gend "gender of the gloss"
  #   lsource: # attr xml:lang="eng" (default) ISO 639-2
  #     # attr ls_type="full"(default) || "part"
  #     # attr ls_wasei="y" means "yes" e.g. waseieigo

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
