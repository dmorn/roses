defmodule Roses.Flow do
  alias Roses.Massive

  def from_languages(langs, opts) do
    langs
    |> Enum.map(&Massive.path/1)
    |> Enum.map(&File.stream!(&1, read_ahead: 20_000))
    |> Flow.from_enumerables(opts.init)
    |> Flow.map(&decode/1)
    |> Flow.flat_map(&extract/1)
    |> Flow.partition(opts.partition)
    |> Flow.reduce(fn -> %{} end, fn word, acc ->
      Map.update(acc, word, 1, fn old -> old + 1 end)
    end)
  end

  defp decode(line) do
    line
    |> Jason.decode!()
    |> Map.get("utt")
  end

  defp extract(line) when is_binary(line) do
    String.split(line)
  end
end
