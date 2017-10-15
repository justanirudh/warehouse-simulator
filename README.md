## Inspiration

We are students who are extremely interested in distributed systems and multi-threaded applications. Whenever we did work on distributed applications we always felt a gap between our understanding of how the system is working and how the system is actually working. We wanted a way to visualize how the information is spreading and how the resources are being utilized in the network so as to have a better understanding of our system. Enter Gridy. 

## What it does
It helps you visualize the information spread in your distributed application. For the use-case of producer-consumer, we can look at under/over utilization of resources, process bottlenecks, single point of failures (if any) and measure how well our process is load balanced. As a result, we can make necessary changes to our process and iteratively make it better. For a gossip/information-dissemination scenario, we can look at whether nodes are hearing the gossip, how many times they are hearing it and how effectively they are able to pass on the gossip. Further, you can speed-up the visualizations to look at a whole day's data in minutes. Continuous monitoring and viewing past-trend and old logs is natively supported

## How we built it

Gridy is language agnostic. Yes you read that right!
Just put our cute little logs in your awesome program and you are done!
We used Elixir for the back-end simulation. It is a concurrent and functional language built on top of the Erlang battle-tested VM.
We used node.js to read the logs, filter the useful ones and render it in a browser for visualizations using web sockets. 

## Challenges we ran into
### Simulator
Developing the pipeline topology with the producer-consumer algorithm was challenging and fun. Writing actor-model to simulate the entire back-end was a great learning experience 
### Visualizer: 
Dividing work across the 3 of us to write the back-end and front-end. Real-time rendering on browsers needed us to use websockets. Handling real-time log processing

## Accomplishments that we're proud of
Developed a generic distributed systems visualizer was an achievement. To add your own grid, you just need to
- Add two lines in your existing code
- provide us with your topology/map

If you want to use our simulator to experiment with your topology, you just need to add your business logic of each node like its capacity, what process it does, how is its current size is defined, etc.

## What we learned
- Writing functional, concurrent, distributed apps
- Parsing huge amount of data and using websockets
- Teamwork and friendship. JK.

## What's next for Gridy
- Better visualizations
- Better per-node information visuals
- Maintain history of nodes and visualize it using pretty charts
- Machine Learning for future usage predictions
- Making things more modular on our side

