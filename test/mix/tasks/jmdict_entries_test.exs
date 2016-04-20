defmodule JMDict.EntryStreamConsumer do
  def take_one(entries_stream) do
    [entry] = Enum.take entries_stream, 1
    entry
  end
end

defmodule JMDict.EntriesMixTaskTest do
  use ExUnit.Case, async: true

  test "module receives entries stream" do
    consumer = "JMDict.EntryStreamConsumer.take_one"
    entry = Mix.Tasks.JMDict.Entries.run([consumer])
    assert entry.eid == '1000000'
  end
end
