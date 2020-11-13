$ perl graph.pl workflow.xml

                                               +----------------+  ok
  +------------------------------------------- | streaming-node | ------------------------------+
  |                                            +----------------+                               |
  |                                              ^                                              |
  |                                              |                                              |                                   +-----------------------------------------+
  |                                              |                                              v                                   |                                         v
  |  +-------+          +--------------+  ok   +----------------+          +----------+  ok   +-----------+     +---------+  ok   +---------------+     +-----------+  ok   +-----+
  |  | START | -------> | cleanup-node | ----> |   fork-node    | -------> | pig-node | ----> | join-node | --> | mr-node | ----> | decision-node | --> | hdfs-node | ----> | end |
  |  +-------+          +--------------+       +----------------+          +----------+       +-----------+     +---------+       +---------------+     +-----------+       +-----+
  |                       |                                                  |                                    |                                       |
  |                       | error                                            |                                    |                                       |
  |                       v                                                  |                                    |                                       |
  |            error    +---------------------------------------+  error     |                                    |                                       |
  +-------------------> |                                       | <----------+                                    |                                       |
                        |                                       |                                                 |                                       |
                        |                                       |  error                                          |                                       |
                        |                 fail                  | <-----------------------------------------------+                                       |
                        |                                       |                                                                                         |
                        |                                       |  error                                                                                  |
                        |                                       | <---------------------------------------------------------------------------------------+
                        +---------------------------------------+
