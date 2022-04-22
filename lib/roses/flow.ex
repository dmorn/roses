defmodule Roses.Flow do
  @doc """
  Returns a Flow that counts the words found in every enumerable provided. Each
  entry in the enumerable is expected to be a String. Words are tokenized
  splitting the line in whitespaces.
  """
  def from_enumerables(enumerables, opts \\ []) do
    enumerables
    |> Flow.from_enumerables(opts)
    |> Flow.flat_map(&extract/1)
    |> Flow.partition()
    |> Flow.reduce(fn -> %{} end, fn word, acc ->
      Map.update(acc, word, 1, fn old -> old + 1 end)
    end)
  end

  defp extract(line) when is_binary(line) do
    String.split(line)
  end
end
