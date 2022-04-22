defmodule Roses.Massive do
  @moduledoc """
  Provides an interface to Amazon's latest MASSIVE NL dataset. Find more
  at https://www.amazon.science/blog/amazon-releases-51-language-dataset-for-language-understanding
  """

  @languages_available [
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

  def parse_stream(stream) do
    stream
    |> Stream.map(&Jason.decode!/1)
    |> Stream.map(&Map.get(&1, "utt"))
  end

  def path(lang_code) do
    Path.join([:code.priv_dir(:roses), "amazon-massive-dataset-1.0", "data", "#{lang_code}.jsonl"])
  end

  def all_paths() do
    @languages_available
    |> Enum.map(&path/1)
  end
end
