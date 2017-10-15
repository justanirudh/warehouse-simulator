defmodule Topology do

    defp get_line_neighbours(list, index, num) do
        if index == 0 do
            [Enum.at(list, 1)]
        else
            if index == num - 1 do
                [Enum.at(list, num - 2)]
            else
                [Enum.at(list, index - 1), Enum.at(list, index + 1)]            
            end
        end
    end

    defp get_full_neighbours(list, server) do
        List.delete(list, server)
    end

    defp get_twoD_neighbours(list, index, num) do
        side = num |> :math.sqrt |> round
        row = div(index, side)
        col = rem(index, side)
        res = []

        up_row = row - 1
        if(up_row >= 0) do
            res = [ Enum.at(list, (up_row * side) + col) | res]        
        end         
        down_row = row + 1
        if(down_row < side) do
            res = [ Enum.at(list, (down_row * side) + col)  | res]
        end    
        left_col = col - 1
        if left_col >= 0 do
            res = [ Enum.at(list, (row * side) + left_col) | res]
        end
        right_col = col + 1
        if right_col < side do
            res = [ Enum.at(list, (row * side) + right_col) | res]
        end
        res   
    end

    defp get_impTwoD_neighbours(list, index, num, server) do
        ns = get_twoD_neighbours(list, index, num)
        #remove 4 neighbours and itself from the space
        space_left = get_full_neighbours(list,server) -- ns 
        #select a random element from left space
        fifth =  Enum.at(space_left, :rand.uniform(length(space_left)) - 1)
        [fifth | ns]
    end    

    defp send_data(list, index, num, topo) do
        if(index != num) do
            server = Enum.at(list, index)
            neighbours = case topo do
                :full -> get_full_neighbours(list, server)
                :line -> get_line_neighbours(list, index, num)
                :twoD -> get_twoD_neighbours(list, index, num)
                :impTwoD -> get_impTwoD_neighbours(list, index, num, server)
                _ -> raise topo <> " not supported"  
            end                
            :ok = GenServer.call(server, {:neighbours, neighbours})
            send_data(list, index + 1, num, topo)
        else
            :ok
        end
    end

    #Specific warehouse
    #Layers: 5 -> 7 -> 5 -> 5 -> 6 -> 8 -> 3 -> 8
    #nodes: 0..4 -> 5..11 -> 12..16 -> 17..21 -> 22..27 -> 28..35 -> 36..38 -> 39..46
    #Caps:   50 -> 50 -> 50 -> 50 ->50 ->50 ->50 ->50 ->done  
    #factor: 10, 5, 10, 5, 10, 5, 10, 5

    #send neighbours and capacities
    defp send_data_pipeline(list, index, num) do
        # layers = div(num, 10)
        if(index != num) do
            server = Enum.at(list, index)
            case num do
                47 ->
                    case index do
                        x when x in 0..4 -> GenServer.call(server, {:data, list, 5..11, 50, 10}, :infinity)
                        x when x in 5..11 -> GenServer.call(server, {:data, list, 12..16, 50, 5}, :infinity)
                        x when x in 12..16 -> GenServer.call(server, {:data, list, 17..21, 50, 10}, :infinity)
                        x when x in 17..21 -> GenServer.call(server, {:data, list, 22..27, 50, 5}, :infinity)
                        x when x in 22..27 -> GenServer.call(server, {:data, list, 28..35, 50, 10}, :infinity)
                        x when x in 28..35 -> GenServer.call(server, {:data, list, 36..38, 50, 5}, :infinity)
                        x when x in 36..38 -> GenServer.call(server, {:data, list, 39..46, 50, 10}, :infinity)
                        x when x in 39..46 ->GenServer.call(server, {:data, list, nil, 50, 5}, :infinity)
                        _ -> raise "not supported yet"
                    end        
                _ -> raise "not supported"
                    # case layers do
                    #     1 ->
                    #         case index do
                    #             x when x in 0..9 -> GenServer.call(server, {:data, list, nil, 50, 10})
                    #             _ -> raise "not supported yet"
                    #         end
                    #         2 ->
                    #             case index do
                    #                 x when x in 0..9 -> GenServer.call(server, {:data, list, 10..19, 50, 10})
                    #                 x when x in 10..19 -> GenServer.call(server, {:data, list, nil, 50, 5})
                    #                 _ -> raise "not supported yet"
                    #             end
                    #             3 ->
                    #                 case index do
                    #                     x when x in 0..9 -> GenServer.call(server, {:data, list, 10..19, 50, 10})
                    #                     x when x in 10..19 -> GenServer.call(server, {:data, list, 20..29, 50, 5})
                    #                     x when x in 20..29 -> GenServer.call(server, {:data, list, nil, 50, 10})
                    #                     _ -> raise "not supported yet"
                    #                 end
                    #                 4 ->
                    #                     case index do
                    #                         x when x in 0..9 -> GenServer.call(server, {:data, list, 10..19, 50, 10})
                    #                         x when x in 10..19 -> GenServer.call(server, {:data, list, 20..29, 50, 5})
                    #                         x when x in 20..29 -> GenServer.call(server, {:data, list, 30..39, 50, 10})
                    #                         x when x in 30..39 -> GenServer.call(server, {:data, list, nil, 50, 5})
                    #                         _ -> raise "not supported yet"
                    #                     end
                    #                     5 ->
                    #                         case index do
                    #                             x when x in 0..9 -> GenServer.call(server, {:data, list, 10..19, 50, 10})
                    #                             x when x in 10..19 -> GenServer.call(server, {:data, list, 20..29, 50, 5})
                    #                             x when x in 20..29 -> GenServer.call(server, {:data, list, 30..39, 50, 10})
                    #                             x when x in 30..39 -> GenServer.call(server, {:data, list, 40..49, 50, 5})
                    #                             x when x in 40..49 -> GenServer.call(server, {:data, list, nil, 50, 10})   
                    #                             _ -> raise "not supported yet"
                    #                         end

                    # end     
            end 
            send_data_pipeline(list, index + 1, num)
        else
            :ok
        end
    end
    
    
    def create(num, topo, algo) do
        #1 spawn processes
        #2 send info of neighbors to each process spawned before

        num = 
            if num == -1 do
                47 #image
            else
                num # max 59 for pipeline
            end

        # num = if topo == "pipeline" do
        #     if num >= 60 do
        #         raise "pipeline with size >= 60 not supported"
        #     else
        #         num - rem(num, 10)
        #     end
            
        # end

        num = 
            case topo do
                "full" -> num
                "line" -> num
                "2D" -> num |> :math.sqrt |> round |> :math.pow(2) |> round
                "imp2D" -> num |> :math.sqrt |> round |> :math.pow(2) |> round
                "pipeline" -> num 
                _ -> raise "Not supported"     
            end
        
        list = 
            case algo do
                "gossip" -> 1..num |> Enum.map(fn _ -> elem(GenServer.start_link(Gossiper, []), 1) end)
                "push-sum" -> 1..num |> Enum.map(fn i -> elem(GenServer.start_link(Adder, i), 1) end) #i = s
                "pc" -> 1..num |> Enum.map(fn _ -> elem(GenServer.start_link(Machine,[]), 1) end)
                _ -> raise "Not supported"
            end

        case topo do
            "full" -> :ok = send_data(list, 0, num, :full)
            "line" -> :ok = send_data(list, 0, num, :line)
            "2D" -> :ok = send_data(list, 0, num, :twoD)
            "imp2D" -> :ok = send_data(list, 0, num, :impTwoD)
            "pipeline" -> :ok = send_data_pipeline(list, 0, num)
        end
        {list, 0..4} #first layer
    end
end