defmodule JMDict.XMLEntities do
  def table_name, do: :jmdict_xml_entites
  def populate_ets_xml_entites do
    if :ets.info(table_name) == :undefined do
      :ets.new(table_name, [:named_table])
      |> :ets.insert(val_to_name_tuples)
    end
  end

  def vals_to_names(arr) do
    Enum.map arr, &val_to_name/1
  end

  def val_to_name(val) do
    [{_, name}] = :ets.lookup(table_name, val)
    name
  end

  def name_to_val_map do
    entity_tuples
    |> Enum.into(%{})
  end

  def val_to_name_map do
    val_to_name_tuples
    |> Enum.into(%{})
  end

  defp val_to_name_tuples do
    entity_tuples
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&Enum.reverse/1)
    |> Enum.map(&List.to_tuple/1)
  end

  defp xml_entity_re, do: ~r{\<\!ENTITY ([^\s]+) "(.+)"\>}
  defp entity_tuples do
    JMDict.XML.stream
    |> Stream.take_while(& !Regex.match? ~r{^\<JMdict}, &1)
    |> Enum.to_list
    |> Enum.map(fn line ->
        Regex.run xml_entity_re, line, capture: :all_but_first
    end)
    |> Enum.reject(& is_nil &1)
    |> Enum.map(&List.to_tuple/1)
  end
end
