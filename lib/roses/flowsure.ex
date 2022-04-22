defmodule Roses.Flowsure do
  require Logger

  def run(flow) do
    flow
    |> walk_flow()
    |> Flow.run()
  end

  defp measure_op({:mapper, id, funs}) do
    {:mapper, id,
     Enum.map(funs, fn original ->
       fn arg ->
         Logger.debug("mapper function called")
         original.(arg)
       end
     end)}
  end

  defp measure_op({:reduce, acc_fun, reducer_fun}) do
    {:reduce, acc_fun,
     fn x, acc ->
       Logger.debug("reduce operation called")
       reducer_fun.(x, acc)
     end}
  end

  defp measure_op(op) do
    op
  end

  # defp measure_op(op = {:uniq, fun()})
  # defp measure_op(op = {:emit_and_reduce, fun(), fun()})
  # defp measure_op(op = {:on_trigger, fun()})

  defp walk_flow(flow = %Flow{}) do
    flow
    |> Map.update(:operations, [], fn ops -> Enum.map(ops, &measure_op/1) end)
    |> Map.update(:producers, [], fn
      {:flows, flows} -> {:flows, Enum.map(flows, &walk_flow/1)}
      other -> other
    end)
  end
end
