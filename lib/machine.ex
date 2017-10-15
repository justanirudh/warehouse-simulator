defmodule Machine do
    use GenServer
    
    #state: {all_nodes_list, neighbour range, capacity, factor, size}

    defp print_plotty(state, new_size, type, sender, receiver) do
        now = DateTime.utc_now() |> DateTime.to_unix
        node_list = elem(state, 0)
        cap = elem(state, 2)
        rec_index =  if receiver == -1 do
            -1
        else
            Enum.find_index(node_list, fn(x) -> x == receiver end)
        end
        perc = (new_size/cap) * 100
        
        if sender == nil do
            IO.puts "<plotty: #{now},#{type},#{rec_index},#{perc}>"
        else
            sender_index = Enum.find_index(node_list, fn(x) -> x == sender end)
            IO.puts "<plotty: #{now},#{type},#{sender_index},#{rec_index},#{perc}>"
        end
    end

    #initialize
    def handle_call({:data, all_nodes, neigh_range, cap, factor}, _from, _) do
        {:reply, :ok, {all_nodes, neigh_range, cap, factor, 0}}
    end

    #receive
    def handle_call(:receive, _from, state) do
        #check if after processing, size > capacity
        # if size < capacity, accept and return :ok
        #after accepting starting sending to random neighbours 1 unit of items until empty and 
        #deduct from size
        #else reject and send not okay
        curr_size = elem(state, 4)
        factor = elem(state, 3)
        capacity = elem(state, 2)
        pot_new_size = curr_size + factor
        curr = self()
        if (pot_new_size > capacity) do
           IO.puts "Machine is full. Wait for it to empty"
           {:reply, :failure, state}
        else
            new_size = pot_new_size
            print_plotty(state, new_size, "receive", nil, curr)
            if curr_size == 0 do #this was first receive
                send curr, :send 
            end
            {:reply, :success, {elem(state, 0),elem(state, 1),elem(state, 2),elem(state, 3),new_size}}
        end
    end

    defp get_rand_neigh(state) do
        all_nodes_list = elem(state, 0)
        neigh_range = elem(state, 1)
        Enum.at(all_nodes_list, Enum.random(neigh_range))
    end

    #send
    def handle_info(:send, state) do
        #select a random neighbour and send it a unit of work
        #wait for a reply if failed, send again until succeed
        #then send itself a message to continue sending
        #then  {:noreply, state}
        curr_size = elem(state, 4)
        range = elem(state, 1)
        if(curr_size == 0) do
            {:noreply, state}
        else
            curr = self()
            if range == nil do #last layer
                new_size = curr_size - 1
                :timer.sleep(1000)
                print_plotty(state, new_size, "send", curr, -1)
                send curr, :send                
                {:noreply, {elem(state, 0),elem(state, 1),elem(state, 2),elem(state, 3),new_size}}    
            else
                receiver = get_rand_neigh(state)
                :timer.sleep(1000)
                res = GenServer.call(receiver, :receive, :infinity)
                if(res == :success) do
                    new_size = curr_size - 1
                    print_plotty(state, new_size, "send", curr, receiver)
                    send curr, :send                    
                    {:noreply, {elem(state, 0),elem(state, 1),elem(state, 2),elem(state, 3),new_size}}
                else
                    send curr, :send    
                    {:noreply, state}
                end
            end
        end
    end

    # def handle_info(_msg, state) do #catch unexpected messages
    #     {:noreply, state}
    # end

    
end