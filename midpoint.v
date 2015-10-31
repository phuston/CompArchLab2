module midpoint
#(parameter width = 8)
(
input btn0,
input switch0,
input switch1,
input clk,
output [width-1:0] parallelout,
output serialout
);

    // Condition the inputs
    wire conditionedbtn, positiveedgebtn, negativeedgebtn;
    inputconditioner btnConditioner(
                                    clk, 
                                    btn0, 
                                    conditionedbtn,
                                    positiveedgebtn,
                                    negativeedgebtn);

    wire conditionedswitch0, positiveedgeswitch0, negativeedgeswitch0;
    inputconditioner switch0Conditioner(
                                    clk, 
                                    switch0, 
                                    conditionedswitch0,
                                    positiveedgeswitch0,
                                    negativeedgeswitch0);

    wire conditionedswitch1, positiveedgeswitch1, negativeedgeswitch1;
    inputconditioner switch1Conditioner(
                                    clk, 
                                    switch1, 
                                    conditionedswitch1,
                                    positiveedgeswitch1,
                                    negativeedgeswitch1);

    shiftregister sregister(
                            clk,
                            positiveedgeswitch1,
                            negativeedgebtn,
                            8'hA5,
                            conditionedswitch0,
                            parallelout,
                            serialout
                            );


endmodule
