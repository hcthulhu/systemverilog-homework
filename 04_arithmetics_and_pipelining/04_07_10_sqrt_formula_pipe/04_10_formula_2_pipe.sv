//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_pipe
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
    // Implement a pipelined module formula_2_pipe that computes the result
    // of the formula defined in the file formula_2_fn.svh.
    //
    // The requirements:
    //
    // 1. The module formula_2_pipe has to be pipelined.
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

    localparam [4:0] depth_1 = 5'd16;
    localparam [5:0] depth_2 = 6'd33;

    logic [31:0] sqrt2_input;
    logic [31:0] sqrt3_input;

    logic [15:0] res_sqrt1;
    logic [15:0] res_sqrt2;
    logic [15:0] res_sqrt3; 

    logic        sqrt2_input_vld;
    logic        sqrt3_input_vld;

    logic        res_sqrt1_vld;
    logic        res_sqrt2_vld;
    logic        res_sqrt3_vld;

    logic [31:0] shift_reg_1_data [0:depth_1 - 1];
    logic        shift_reg_1_vld  [0:depth_1 - 1];

    logic [31:0] shift_reg_2_data [0:depth_2 - 1];
    logic        shift_reg_2_vld  [0:depth_2 - 1];

    //---------------------------------------------------------------
    // SQRT modules

    isqrt sqrt1
    (
        .clk   ( clk             ),
        .rst   ( rst             ),

        .x_vld ( arg_vld         ),
        .x     ( c               ),

        .y_vld ( res_sqrt1_vld   ),
        .y     ( res_sqrt1       )
    );

    isqrt sqrt2
    (
        .clk   ( clk             ),
        .rst   ( rst             ),

        .x_vld ( sqrt2_input_vld ),
        .x     ( sqrt2_input     ),

        .y_vld ( res_sqrt2_vld   ),
        .y     ( res_sqrt2       )
    );

    isqrt sqrt3
    (
        .clk   ( clk             ),
        .rst   ( rst             ),

        .x_vld ( sqrt3_input_vld ),
        .x     ( sqrt3_input     ),

        .y_vld ( res_sqrt3_vld   ),
        .y     ( res_sqrt3       )
    );

    //---------------------------------------------------------------
    // Shift registers

    always_ff @ (posedge clk)
        if (rst)
        begin
            for (int i = 0; i < depth_1; i ++)
                shift_reg_1_vld [i] <= 1'b0;
        end
        else
        begin
            if (arg_vld)
                shift_reg_1_data [0] <= b;

            shift_reg_1_vld [0] <= arg_vld;
            
            for (int i = 1; i < depth_1; i ++)
            begin
                if (shift_reg_1_vld [i - 1])
                    shift_reg_1_data [i] <= shift_reg_1_data [i - 1];
                
                shift_reg_1_vld [i] <= shift_reg_1_vld [i - 1];
            end
        end

    always_ff @ (posedge clk)
        if (rst)
        begin
            for (int i = 0; i < depth_2; i ++)
                shift_reg_2_vld [i] <= 1'b0;
        end
        else
        begin
            if (arg_vld)
                shift_reg_2_data [0] <= a;

            shift_reg_2_vld [0] <= arg_vld;
            
            for (int i = 1; i < depth_2; i ++)
            begin
                if (shift_reg_2_vld [i - 1])
                    shift_reg_2_data [i] <= shift_reg_2_data [i - 1];
                
                shift_reg_2_vld [i] <= shift_reg_2_vld [i - 1];
            end
        end

    //---------------------------------------------------------------
    // Valid flags

    always_ff @ (posedge clk)
        if (rst)
        begin
            sqrt2_input_vld <= '0;
            sqrt3_input_vld <= '0;
        end
        else
        begin
            sqrt2_input_vld <= res_sqrt1_vld;
            sqrt3_input_vld <= res_sqrt2_vld;
        end

    //---------------------------------------------------------------
    // Input data pipelines
    
    always_ff @ (posedge clk)
        if (res_sqrt1_vld)
            sqrt2_input <= res_sqrt1 + shift_reg_1_data [depth_1 - 1];
    
    always_ff @ (posedge clk)
        if (res_sqrt2_vld)
            sqrt3_input <= res_sqrt2 + shift_reg_2_data [depth_2 - 1];

    assign res_vld = res_sqrt3_vld;
    assign res     = res_sqrt3;

endmodule
