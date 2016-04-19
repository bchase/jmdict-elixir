# JMDict

```elixir
Enum.each JMDict.entries_stream, fn entry ->
  entry.eid     # entry id       # String
  entry.pos     # part of speech # List[String]
  entry.kanji   # kanji          # List[String]
  entry.kana    # kana           # List[String]
  entry.glosses # kana           # List[String]
end
```

### TODO

* `%POS{type: String, expl: String}` instead of `List[String]` for `entry.pos`
* provide more information from JMdict in `Entry`
* parallelized seeder
