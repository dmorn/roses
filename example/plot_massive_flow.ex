alias VegaLite, as: Vl
alias Flow.Reporter
alias Flow.Reporter.Plot
alias Flow.Reporter.Stats

require Logger

Logger.info("Ensuring MASSIVE dataset is downloaded")
Roses.Massive.ensure_downloaded()

Logger.info("Initializing and instrumenting Flow")
id = Reporter.uniq_event_prefix()
collector = Stats.new(id)
flow =
  Roses.Massive.langs()
  |> Enum.take(1)
  |> Roses.Flow.from_languages()
  |> Reporter.attach(collector, id)

Logger.info("Executing Flow")
Flow.run(flow)

output = "massive_flow.html"
Logger.info("Encoding plot in #{output}")

spans = Stats.spans_stream(collector)

Vl.new(width: 960, height: 540)
|> Plot.encode_spans(spans)
|> Vl.mark(:line)
|> Vl.Export.save!(output)
