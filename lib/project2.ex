defmodule GossipSimulator do

  defp loop(nodes, range) do
    neigh = Enum.at(nodes, Enum.random(range))
    :timer.sleep(1000)
    GenServer.call(neigh, :receive, :infinity)
    loop(nodes, range)
  end

  #Warehouse simulator and visualizer
  #give number of nodes, capacity of each, function to each
  # Realtime each nodes capacity
  def main(args) do
    num = Enum.at(args, 0) |> String.to_integer
    topo = Enum.at(args, 1)
    algo = Enum.at(args, 2)

    self() |> Process.register(:master) #register master
    {nodes, range} = Topology.create(num,topo, algo) #create topology
    loop(nodes, range)

  end 
end