# Tang Nano 9k FPGA programming

So, I just recently got a Tang Nano 9k FPGA board, and I've started using it for the past 3-4 days as of when I'm writing this docs. I'm creating this repo to maintain detailed
explanations for different lines of code and quirks in terms of getting the Tang Nano 9k to work properly (because of its dependence on old versions of existing libraries).

### Project 1: Controlled UpDown-counter:

In this project, you have the two on-board buttons on the Tang Nano function as inputs to a gated SR-latch, use the output to drive whether an increment or decrement operation
needs to be performed on the current binary number.

so basically:

SR-latch -> check output -> Demux (1x2) selector line -> increment operation on current binary number if Selector = 1 else decrement operation
