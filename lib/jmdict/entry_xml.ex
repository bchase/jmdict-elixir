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
          re_nokanji: ~x"./re_nokanji/text()"ls, # TODO NULL <re_nokanji/>
          re_restr: ~x"./re_restr/text()"ls,
      ],
      sense: [ # SENSES (GLOSSES)
        ~x{./sense}le,
        stagk:   ~x{./stagk/text()}ls,
        stagr:   ~x{./stagr/text()}ls,
        xref:    ~x{./xref/text()}ls,    # full ex: <xref>彼・あれ・1</xref>
        pos:     ~x{./pos/text()}ls,     # prior ./sense/pos apply, unless new added
        field:   ~x{./field/text()}ls,
        misc:    ~x{./misc/text()}ls,    # "usually apply to several senses"
        lsource: ~x{./lsource/text()}ls, # attr xml:lang="eng" (default) ISO 639-2
                                         # attr ls_type="full"(default) || "part"
                                         # attr ls_wasei="y" means "yes" e.g. waseieigo
        dial:    ~x{./dial/text()}ls,
        gloss:   ~x{./gloss/text()}ls,   # attr xml:lang="eng" (default)
                                         # attr g_gend "gender of the gloss"
        # pri: ~x{./pri/text()}ls,       # DNE in current JMdict_e file
        s_inf: ~x{./s_inf/text()}ls
      ]
  end
end
