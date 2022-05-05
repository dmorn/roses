alias VegaLite, as: Vl
alias TeleFlow
alias TeleFlow.Reporter.Plot
alias TeleFlow.Collector.FS

require Logger

output = "massive_flow.html"
n_lang = 5

Logger.info("Ensuring MASSIVE dataset is downloaded")
Roses.Massive.ensure_downloaded()

Logger.info("Initializing and instrumenting Flow")
id = TeleFlow.uniq_event_prefix()
collector = FS.new(id)

flow =
  Roses.Massive.langs()
  |> Enum.take(n_lang)
  |> Roses.Flow.from_languages()
  |> TeleFlow.attach(collector, id)

Logger.info("Executing Flow with #{n_lang} language sources")
Flow.run(flow)

Logger.info("Encoding plot in #{output}")

spans = FS.stream_stop_events(collector)

Vl.new(width: 960, height: 540)
|> Plot.encode_stop_events(spans)
|> Vl.mark(:line)
|> Vl.Export.save!(output)
