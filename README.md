# JMDict

## Usage

Use the entries stream in your code:

```elixir
Enum.each JMDict.entries_stream, fn entry ->
  entry.eid     # entry id       # String
  entry.pos     # part of speech # List[String]
  entry.kanji   # kanji          # List[String]
  entry.kana    # kana           # List[String]
  entry.glosses # kana           # List[String]
end
```

Or create a seeder function, and call it with Mix:

```elixir
defmodule MyApp.JMDict do
 def seed_entries(entries) do
  Enum.each entries, fn entry ->
    # seed the DB
  end
end
```

```
$ mix jmdict:entries MyApp.JMDict.seed_entries
```

#### TODO

* `%POS{type: String, expl: String}` instead of `List[String]` for `entry.pos`
* provide more information from JMdict in `Entry`
* parallelized seeder
