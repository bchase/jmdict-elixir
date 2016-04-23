defmodule JMDict.Entry.Sense do
  defstruct \
    glosses: []
  # sense: [ # SENSES (GLOSSES)
  #   ~x{./sense}le,
  #   stagk:   ~x{./stagk/text()}ls,
  #   stagr:   ~x{./stagr/text()}ls,
  #   xref:    ~x{./xref/text()}ls,    # full ex: <xref>彼・あれ・1</xref>
  #   pos:     ~x{./pos/text()}ls,     # prior ./sense/pos apply, unless new added
  #   field:   ~x{./field/text()}ls,
  #   misc:    ~x{./misc/text()}ls,    # "usually apply to several senses"
  #   lsource: ~x{./lsource/text()}ls, # attr xml:lang="eng" (default) ISO 639-2
  #   # attr ls_type="full"(default) || "part"
  #   # attr ls_wasei="y" means "yes" e.g. waseieigo
  #   dial:    ~x{./dial/text()}ls,
  #   gloss:   ~x{./gloss/text()}ls,   # attr xml:lang="eng" (default)
  #   # attr g_gend "gender of the gloss"
  #   # pri: ~x{./pri/text()}ls,       # DNE in current JMdict_e file
  #   s_inf: ~x{./s_inf/text()}ls
  # ]

  def from_element(sense) do
    struct __MODULE__, %{glosses: sense.gloss}
  end
end
