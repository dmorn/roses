defmodule Roses.Massive do
  @moduledoc """
  Provides an interface to Amazon's latest MASSIVE NL dataset. Find more
  at https://www.amazon.science/blog/amazon-releases-51-language-dataset-for-language-understanding
  """

  @base_url "https://amazon-massive-nlu-dataset.s3.amazonaws.com/"
  @dataset_file "amazon-massive-dataset-1.0.tar.gz"

  @dataset_name "amazon-massive-dataset"

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

  def take_paths() do
    cached =
      @all_langs
      |> Enum.map(&path/1)
      |> Enum.map(&File.exists?/1)
      |> Enum.all?()

    unless cached do
      :ok = download()
    end

    @all_langs
    |> Enum.map(fn lang -> {lang, path(lang)} end)
  end

  defp path(lang) do
    Path.join([cache_dir(), "1.0", "data", lang <> ".jsonl"])
  end

  defp download() do
    (@base_url <> @dataset_file)
    |> Tesla.get!()
    |> Map.get(:body)
    |> extract()
  end

  defp extract(body) do
    File.mkdir_p!(cache_dir())

    dir =
      cache_dir()
      |> String.to_charlist()

    :ok = :erl_tar.extract({:binary, body}, [:compressed, {:cwd, dir}])
  end

  defp cache_dir() do
    Path.join([System.tmp_dir!(), @dataset_name])
  end
end
