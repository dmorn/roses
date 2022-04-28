defmodule Roses.Massive do
  @moduledoc """
  Provides an interface to Amazon's latest MASSIVE NL dataset. Find more
  at https://www.amazon.science/blog/amazon-releases-51-language-dataset-for-language-understanding
  """

  @base_url "https://amazon-massive-nlu-dataset.s3.amazonaws.com/"
  @dataset_file "amazon-massive-dataset-1.0.tar.gz"

  @all_langs [
    "af-ZA",
    "am-ET",
    "ar-SA",
    "az-AZ",
    "bn-BD",
    "cy-GB",
    "da-DK",
    "de-DE",
    "el-GR",
    "en-US",
    "es-ES",
    "fa-IR",
    "fi-FI",
    "fr-FR",
    "he-IL",
    "hi-IN",
    "hu-HU",
    "hy-AM",
    "id-ID",
    "is-IS",
    "it-IT",
    "ja-JP",
    "jv-ID",
    "ka-GE",
    "km-KH",
    "kn-IN",
    "ko-KR",
    "lv-LV",
    "ml-IN",
    "mn-MN",
    "ms-MY",
    "my-MM",
    "nb-NO",
    "nl-NL",
    "pl-PL",
    "pt-PT",
    "ro-RO",
    "ru-RU",
    "sl-SL",
    "sq-AL",
    "sv-SE",
    "sw-KE",
    "ta-IN",
    "te-IN",
    "th-TH",
    "tl-PH",
    "tr-TR",
    "ur-PK",
    "vi-VN",
    "zh-CN",
    "zh-TW"
  ]

  alias Scidata.Utils

  # TODO: this is sub-optimal: the whole dataset is loaded into memory by the Utils.get! function.
  # we would rather store the dataset somewhere and create a lazy function that is capable of retriving it from there instead.
  def download() do
    (@base_url <> @dataset_file)
    |> Utils.get!()
    |> Map.get(:body)
    |> Stream.map(fn {path, content} -> {IO.chardata_to_string(path), content} end)
    |> Stream.filter(fn {path, _content} -> String.ends_with?(path, ".jsonl") end)
    |> Stream.map(fn {path, content} -> {String.trim_leading(path, "1.0/data/"), content} end)
    |> Stream.filter(fn {path, _content} -> not String.starts_with?(path, "._") end)
    |> Stream.map(fn {path, content} -> {String.trim_trailing(path, ".jsonl"), content} end)
    |> Stream.map(fn {path, content} ->
      content =
        content
        |> String.split("\n")
        |> Enum.map(&Jason.decode!/1)
        |> Enum.map(&Map.get(&1, "utt"))

      {path, content}
    end)
    |> Enum.into([])
  end

  def take(dataset, languages) do
    dataset
    |> Keyword.take(languages)
    |> Enum.map(fn {_k, v} -> v end)
  end

  def take_all(dataset) do
    take(dataset, @all_langs)
  end
end
