defmodule JMDict.EntryXML do
  import SweetXml

  def parse({_, doc}) do
    xpath doc, ~x"//entry"e,
      # EID
      eid: ~x"./ent_seq/text()"s,
      k_ele: [ # KANJI
        ~x"./k_ele"le,
          keb: ~x"./keb/text()"ls,
          ke_inf: ~x"./ke_inf/text()"ls,
          ke_pri: ~x"./ke_pri/text()"ls
      ],
      r_ele: [ # KANA
        ~x"./r_ele"le,
          reb: ~x"./reb/text()"ls,
          re_inf: ~x"./re_inf/text()"ls,
          re_pri: ~x"./re_pri/text()"ls,
          re_nokanji: ~x"./re_nokanji"e,
          re_restr: ~x"./re_restr/text()"ls,
      ],
      sense: [ # SENSES (GLOSSES)
        ~x{./sense}le,
          stagk:   ~x{./stagk/text()}ls,
          stagr:   ~x{./stagr/text()}ls,
          xref:    ~x{./xref/text()}ls,  # full ex: <xref>彼・あれ・1</xref>
          pos:     ~x{./pos/text()}ls,   # prior ./sense/pos apply, unless new added
          field:   ~x{./field/text()}ls,
          misc:    ~x{./misc/text()}ls,  # "usually apply to several senses"
          dial:    ~x{./dial/text()}ls,
          gloss:   ~x{./gloss/text()}ls,
          s_inf: ~x{./s_inf/text()}ls,
          lsource: ~x{./lsource}le,      # attr xml:lang="eng" (default) ISO 639-2
                                         # attr ls_wasei="y" means "yes" e.g. waseieigo
      ]
  end
end
