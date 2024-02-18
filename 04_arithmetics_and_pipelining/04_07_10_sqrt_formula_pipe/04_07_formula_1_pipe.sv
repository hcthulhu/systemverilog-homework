//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_pipe
(
    input         clk,
    input         rst,

    input         arg_vld,
    input  [31:0] a,
    input  [31:0] b,
    input  [31:0] c,

    output        res_vld,
    output [31:0] res
);
    // Task:
    //
    // Implement a pipelined module formula_1_pipe that computes the result
    // of the formula defined in the file formula_1_fn.svh.
    //
    // The requirements:
    //
    // 1. The module formula_1_pipe has to be pipelined.
    //
    // It should be able to accept a new set of arguments a, b and c
    // arriving at every clock cycle.
    //
    // It also should be able to produce a new result every clock cycle
    // with a fixed latency after accepting the arguments.
    //
    // 2. Your solution should instantiate exactly 3 instances
    // of a pipelined isqrt module, which computes the integer square root.
    //
    // 3. Your solution should save dynamic power by properly connecting
    // the valid bits.
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm

    logic res_sqrt1_vld;
    logic res_sqrt2_vld;
    logic res_sqrt3_vld;
    logic res_all_sqrt_vld;

    logic [15:0] res_sqrt1;
    logic [15:0] res_sqrt2;
    logic [15:0] res_sqrt3; 
    logic [31:0] res_sum;

    isqrt sqrt1
    (
        .clk   ( clk           ),
        .rst   ( rst           ),

        .x_vld ( arg_vld       ),
        .x     ( a             ),

        .y_vld ( res_sqrt1_vld ),
        .y     ( res_sqrt1     )
    );

    isqrt sqrt2
    (
        .clk   ( clk           ),
        .rst   ( rst           ),

        .x_vld ( arg_vld       ),
        .x     ( b             ),

        .y_vld ( res_sqrt2_vld ),
        .y     ( res_sqrt2     )
    );

    isqrt sqrt3
    (
        .clk   ( clk           ),
        .rst   ( rst           ),

        .x_vld ( arg_vld       ),
        .x     ( c             ),

        .y_vld ( res_sqrt3_vld ),
        .y     ( res_sqrt3     )
    );

    always_ff @ (posedge clk or posedge rst)
        if (rst)
            res_all_sqrt_vld <= '0;
        else
            res_all_sqrt_vld <= res_sqrt1_vld & res_sqrt2_vld & res_sqrt3_vld;

    always_ff @ (posedge clk)
        if (res_sqrt1_vld & res_sqrt2_vld & res_sqrt3_vld)
            res_sum <= res_sqrt1 + res_sqrt2 + res_sqrt3;

    assign res_vld = res_all_sqrt_vld;
    assign res     = res_sum;

endmodule
