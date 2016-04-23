# JMDict

Fetch and parse [JMDict](https://www.mdbg.net/chindict/export/cedict/cedict_1_0_ts_utf-8_mdbg.zip) in Elixir

> The JMdict (Japanese-Multilingual Dictionary) project has at its aim the compilation of a multilingual lexical database with Japanese as the pivot language.

**NOTE**: Currently uses JMDict_e (Japanese->English only).

## Usage

The following call to `JMDict.entries_stream` will download the latest version of JMdict to `/tmp`, but if you'd like to use the copy stored in this repo instead, just copy it over before you run the code below.

```
$ cp xml/JMdict_e.gz /tmp && gunzip /tmp/JMdict_e.gz
```

You can use the entries stream to seed your DB:

```elixir
Enum.each JMDict.entries_stream, fn entry ->
  # ...

  entry = struct YourJMDictEntryModel, entry
  Repo.insert! entry
end
```

```elixir
# an entry has the top-level structure...

%Entry{
  eid:    String.t,
  kanji:  [%KanjiReading{}],
  kana:   [%KanaReading{}],
  senses: [%Sense{}],
}

# where those structs have structures like...

%KanjiReading{
  text: String.t,   # the kanji
  info: [String.t],
  # more to come
}

%KanaReading{
  text: String.t,   # the kana
  info: [String.t],
  # more to come
}

%Sense{
  glosses: [String.t],
  pos:     [String.t],
  dial:    [String.t],
  info:    [String.t],
  misc:    [String.t],
  field:   [String.t],
  xrefs:   [String.t],
  stagk:   [String.t],
  stagr:   [String.t],
  # more to come
  # lsource: [String.t],
}
```

<!--
This takes JMdict XML:

```xml
<entry>
  <ent_seq>1000920</ent_seq>
  <r_ele>
    <reb>いらっしゃい</reb>
    <re_pri>spec1</re_pri>
  </r_ele>
  <r_ele>
    <reb>いらしゃい</reb>
    <re_inf>&ik;</re_inf>
  </r_ele>
  <sense>
    <pos>&int;</pos>
    <pos>&n;</pos>
    <xref>いらっしゃる・1</xref>
    <misc>&hon;</misc>
    <s_inf>used as a polite imperative</s_inf>
    <gloss>come</gloss>
    <gloss>go</gloss>
    <gloss>stay</gloss>
  </sense>
  <sense>
    <xref>いらっしゃいませ</xref>
    <gloss>welcome!</gloss>
  </sense>
</entry>
```

And turns it into a Elixir `JMDict.Entry` struct:

```elixir
%JMDict.Entry{
  eid: "1000920",

  kanji: [],
  kanji_info: %{},

  kana: ["いらっしゃい", "いらしゃい"],
  kana_info: %{"いらしゃい" => ["ik"]},

  glosses: ["come", "go", "stay", "welcome!"],

  pos: ["int", "n"],
  info: ["hon"],

  xrefs: ["いらっしゃる・1", "いらっしゃいませ"]
}
```
-->

You can also look up [XML entity](http://www.csse.monash.edu.au/~jwb/jmdict_dtd_h.html) values by name, and vice versa:

```elixir
JMDict.xml_entities_name_to_val_map["abbr"]
# => "abbreviation"

JMDict.xml_entities_val_to_name_map["abbreviation"]
# => "abbr"
```
