alias TeleFlow.Reporter.Report
alias TeleFlow.Collector.FS

require Logger

#:observer.start()

n_lang = 2

Logger.info("Ensuring MASSIVE dataset is downloaded")
Roses.Massive.ensure_downloaded()

new_flow = fn opts ->
  Roses.Massive.langs()
  |> Enum.take(n_lang)
  |> Roses.Flow.from_languages(opts)
end

bench_flow = fn flow ->
  id = TeleFlow.uniq_event_prefix()
  collector = FS.new(id)

  Logger.info("Executing Flow #{inspect(id)}")

  flow
  |> TeleFlow.attach(collector, id)
  |> Flow.run()

  spans = FS.stream_span_events(collector)

  Logger.info("Generating Report")
  Report.from_spans(spans, :millisecond)
end

reports =
  [
    %{
      init: [stages: 4],
      partition: [stages: 4]
    },
    %{
      init: [stages: 8],
      partition: [stages: 4]
    },
    #%{
    #  init: [stages: 16],
    #  partition: [stages: 4]
    #},
    %{
      init: [stages: 4],
      partition: [stages: 8]
    },
    #%{
    #  init: [stages: 4],
    #  partition: [stages: 16]
    #},
    %{
      init: [stages: 2],
      partition: [stages: 2]
    },
    %{
      init: [stages: 2],
      partition: [stages: 4]
    },
    %{
      init: [stages: 4],
      partition: [stages: 2]
    },
    %{
      init: [stages: 1],
      partition: [stages: 2]
    },
    %{
      init: [stages: 2],
      partition: [stages: 1]
    }
  ]
  |> List.duplicate(3)
  |> List.flatten()
  |> Enum.shuffle()
  |> Enum.map(fn opts -> {opts, new_flow.(opts)} end)
  |> Enum.map(fn {opts, flow} ->
    Logger.info("Benchmarking configuration #{inspect(opts)}")
    {opts, bench_flow.(flow)}
  end)
  |> Enum.map(fn {opts, report} -> {opts, Map.get(report.stats, [:global])} end)
  |> Enum.map(fn {opts, %{total: total}} -> {opts, total} end)
  |> Enum.sort(fn {_, lhs}, {_, rhs} -> lhs > rhs end)

keys_of_interest = [
  :average,
  :maximum,
  :minimum,
  :percentiles,
  :sample_size,
  :total,
  :standard_deviation
]

final_report =
  reports
  |> Enum.map(fn {_opts, total} -> total end)
  |> Statistex.statistics(percentiles: [25, 50, 75])
  |> Map.take(keys_of_interest)

IO.inspect(reports)
IO.inspect(final_report)

# Darwin jecoz.local 20.6.0 Darwin Kernel Version 20.6.0: Tue Feb 22 21:10:41 PST 2022; root:xnu-7195.141.26~1/RELEASE_X86_64 x86_64

#[
#  {%{init: [stages: 4], partition: [stages: 8]}, 8505},
#  {%{init: [stages: 4], partition: [stages: 8]}, 7758},
#  {%{init: [stages: 8], partition: [stages: 4]}, 6943},
#  {%{init: [stages: 8], partition: [stages: 4]}, 6510},
#  {%{init: [stages: 4], partition: [stages: 8]}, 5441},
#  {%{init: [stages: 8], partition: [stages: 4]}, 4084},
#  {%{init: [stages: 4], partition: [stages: 4]}, 3697},
#  {%{init: [stages: 4], partition: [stages: 4]}, 3580},
#  {%{init: [stages: 4], partition: [stages: 4]}, 2004},
#  {%{init: [stages: 4], partition: [stages: 2]}, 1993},
#  {%{init: [stages: 4], partition: [stages: 2]}, 1686},
#  {%{init: [stages: 2], partition: [stages: 2]}, 1352},
#  {%{init: [stages: 4], partition: [stages: 2]}, 1347},
#  {%{init: [stages: 2], partition: [stages: 4]}, 1149},
#  {%{init: [stages: 2], partition: [stages: 4]}, 994},
#  {%{init: [stages: 2], partition: [stages: 4]}, 858},
#  {%{init: [stages: 2], partition: [stages: 2]}, 671},
#  {%{init: [stages: 1], partition: [stages: 2]}, 662},
#  {%{init: [stages: 2], partition: [stages: 2]}, 579},
#  {%{init: [stages: 2], partition: [stages: 1]}, 342},
#  {%{init: [stages: 2], partition: [stages: 1]}, 329},
#  {%{init: [stages: 1], partition: [stages: 2]}, 162},
#  {%{init: [stages: 2], partition: [stages: 1]}, 160},
#  {%{init: [stages: 1], partition: [stages: 2]}, 125}
#]
#%{
#  average: 2538.7916666666665,
#  maximum: 8505,
#  minimum: 125,
#  percentiles: %{25 => 599.75, 50 => 1349.5, 75 => 3987.25},
#  sample_size: 24,
#  standard_deviation: 2639.31269016183,
#  total: 60931
#}
