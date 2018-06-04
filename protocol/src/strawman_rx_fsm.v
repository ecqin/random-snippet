`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name:    strawman_rx_fsm
// Author:	   Eric Qin

// Description:    State Machine of Strawman FSM


// Control fields:
//	4 bits of CTRL bits
//	1 valid bit
//	1 full bit


//	Stream Inactive --> 0000
//	Stream Active --> 0001
//	Steam Stalled --> 0010
//	Reserved --> 0011
//	Write 8B Active --> 0100
//	Write 8B Stall --> 0101
//	Write 64B Active --> 0110
//	Write 64B Stall --> 0111   
//	Write 1024B Active --> 1000
//	Write 1024B Stall --> 1001
//	Read Request 8B Active --> 1010
//	Read Request 64B Active --> 1011
//	Read Request 1024B Active --> 1100
//	Atomic Operations --> TODO
    

//////////////////////////////////////////////////////////////////////////////////
module strawman_rx_fsm (
  clk,
  i_control_field,

  o_address_flag,
  o_data_flag,
  o_read_req_size
);

  parameter CONTROL_LINE_WIDTH = 6;
  parameter LOG2_NUM_STATES = 3;

  parameter [LOG2_NUM_STATES-1:0] IDLE  = 3'b000,
                  STREAM = 3'b001,
                  WRITE_8B = 3'b010,
		  WRITE_64B = 3'b011,
		  WRITE_1024B = 3'b100,
                  READ_8B = 3'b101,
		  READ_64B = 3'b110,
		  READ_1024B = 3'b111;

  input clk;
  input [CONTROL_LINE_WIDTH-1:0] i_control_field;

  output reg o_address_flag;
  output reg o_data_flag;
  output reg [1:0] o_read_req_size; // 2'b00 is 8B, 2'b01 is 64B, 2'b10 is 1024B Read Req 

  reg [LOG2_NUM_STATES-1:0] current_state = 'b0;
  reg [LOG2_NUM_STATES-1:0] next_state = 'b0;

  // counter variable
  reg [7:0] counter = 'b0;

  // TODO: Implement a counter system

  always @(posedge clk) begin
    current_state <= next_state;
  end

  always @(current_state, i_control_field) begin
    next_state = 3'b0;
    o_address_flag = 1'b0;
    o_data_flag = 1'b0;
    
    case (current_state)

      IDLE : begin
        counter = 'b0;
        if (i_control_field == 4'b0100) begin
          next_state = WRITE_8B;
        end else if (i_control_field == 4'b0110) begin
          next_state = WRITE_64B;
        end else if (i_control_field == 4'b1000) begin
          next_state = WRITE_1024B;
        end
      end

      STREAM : begin
        // WIP
      end

      WRITE_8B : begin
        counter = counter + 1'b1;
        if (counter == 1) begin
          o_address_flag = 1'b1;
          o_data_flag = 1'b0;
          next_state = WRITE_8B;
        end else if (counter == 2) begin
          o_address_flag = 1'b0;
          o_data_flag = 1'b1;
          next_state = IDLE;
        end else begin
          o_address_flag = 1'b0;
          o_data_flag = 1'b0;
          next_state = IDLE;
        end
      end

      WRITE_64B : begin
        counter = counter + 1'b1;
        if (counter == 1) begin
          o_address_flag = 1'b1;
          o_data_flag = 1'b0;
          next_state = WRITE_64B;
        end else if (counter == 8) begin
          o_address_flag = 1'b0;
          o_data_flag = 1'b1;
          next_state = IDLE;
        end else begin
          o_address_flag = 1'b0;
          o_data_flag = 1'b0;
          next_state = IDLE;
        end
      end

      WRITE_1024B : begin
        counter = counter + 1'b1;
        if (counter == 1) begin
          o_address_flag = 1'b1;
          o_data_flag = 1'b0;
          next_state = WRITE_1024B;
        end else if (counter == 128) begin
          o_address_flag = 1'b0;
          o_data_flag = 1'b1;
          next_state = IDLE;
        end else begin
          o_address_flag = 1'b0;
          o_data_flag = 1'b0;
          next_state = IDLE;
        end
      end

      READ_8B : begin
        counter = counter + 1'b1;
        o_read_req_size = 2'b00;
        if (counter == 1) begin
          o_address_flag = 1'b1;
          o_data_flag = 1'b0;
          next_state = READ_8B;
        end else if (counter == 2) begin
          o_address_flag = 1'b1;
          o_data_flag = 1'b0;
          next_state = IDLE;
        end
      end

      READ_64B : begin
        counter = counter + 1'b1;
        o_read_req_size = 2'b01;
        if (counter == 1) begin
          o_address_flag = 1'b1;
          o_data_flag = 1'b0;
          next_state = READ_8B;
        end else if (counter == 2) begin
          o_address_flag = 1'b1;
          o_data_flag = 1'b0;
          next_state = IDLE;
        end
      end

      READ_1024B : begin
        counter = counter + 1'b1;
        o_read_req_size = 2'b10;
        if (counter == 1) begin
          o_address_flag = 1'b1;
          o_data_flag = 1'b0;
          next_state = READ_8B;
        end else if (counter == 2) begin
          o_address_flag = 1'b1;
          o_data_flag = 1'b0;
          next_state = IDLE;
        end
      end

    endcase
  end


  
endmodule
