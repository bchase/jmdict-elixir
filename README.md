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
  entry.eid        # entry id         #   String
  entry.kanji      # kanji            #  [String]
  entry.kana       # kana             #  [String]
  entry.glosses    # glosses          #  [String]
  entry.pos        # part of speech   #  [String]
  entry.info       # additonal info   #  [String]
  entry.xrefs      # cross references #  [String]
  entry.kanji_info # kanji info       # %{String => [String]}
  entry.kana_info  # kana info        # %{String => [String]}

  entry = struct YourJMDictEntryModel, entry
  Repo.insert! entry
end
```

```elixir
#####################
### EXAMPLE ENTRY ###
#####################

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

And you can also look up [XML entity](http://www.csse.monash.edu.au/~jwb/jmdict_dtd_h.html) values by name, and vice versa:

```elixir
JMDict.xml_entities_name_to_val_map["abbr"]
# => "abbreviation"

JMDict.xml_entities_val_to_name_map["abbreviation"]
# => "abbr"
```
