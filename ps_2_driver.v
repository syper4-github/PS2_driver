module ps_2_driver(
											input 		CLOCK_50,
											inout 		PS2_DAT,
											inout 		PS2_CLK,
											output [6:0] HEX0,
											output [6:0] HEX1,
											output [6:0] HEX2,
											output [7:0] LEDG);

										
	
// assign db = dir ? da : 8'hzz; при dir = 1 db - выход, da - вход
// assign da = !dir ? db : 8'hzz; при dir = 0 da - выход, db - вход

reg data_out = 1'b0;

assign PS2_DAT = enable_data_input ? 1'hz : data_out;
assign PS2_CLK = enable_clock_input ? 1'hz : impulse80us;

deshifr inst1(		.code(datkey), .number_of_zeros(number_of_zeros), .Hex0(HEX0), .Hex1(HEX1), .Hex2(HEX2));

reg [11:0] counter = 12'b0;
reg impulse80us_counter = 1'b0;
reg impulse80us = 1'b1;

reg enable_data_input = 1'b1;
reg enable_clock_input = 1'b1;
reg [10:0] code_from_device = 11'b0;
reg [10:0] success_code_from_device = 11'b0;
reg [7:0] code_to_out = 8'b0;
wire [7:0] code_8_bit = success_code_from_device[8:1];

reg [7:0] datkey = 8'b0;

assign LEDG[7:0] = datkey[7:0];

parameter [3:0] reset = 4'b0;

reg [3:0] state1 = 4'b0001;
reg [3:0] state2 = 4'b0010;
reg [3:0] state3 = 4'b0011;
reg [3:0] state4 = 4'b0100;
reg [3:0] state5 = 4'b0101;
reg [3:0] state6 = 4'b0110;
reg [3:0] state7 = 4'b0111;
reg [3:0] state8 = 4'b1000;
reg [3:0] state9 = 4'b1001;
reg [3:0] state10 = 4'b1010;
reg [3:0] state11 = 4'b1011;

reg [3:0] number_of_zeros = 4'b0;

reg [3:0] currentstate = reset;
reg error_marker = 1'b0;

reg [7:0] code_memory [0:3];

reg [3:0] memory_currentstate = 4'b0001;

reg [3:0] memory_state1 = 4'b0001;
reg [3:0] memory_state2 = 4'b0010;
reg [3:0] memory_state3 = 4'b0011;
reg [3:0] memory_state4 = 4'b0100;
reg write_memory = 1'b0;

reg [3:0] outputstate = reset;
reg [3:0] impulsestate = reset;

always @(posedge CLOCK_50) begin
	counter <= counter + 1'b1;
	if(counter == 12'b111110100000) begin
		impulse80us <= impulse80us + 1'b1;
		counter <= 12'b000000000000;
	end
end

// автомат вывода кода
always @(posedge PS2_CLK) begin
	case(outputstate)
		reset: 	begin
						if(~enable_clock_input) begin
							enable_data_input <= 1'b0;
							data_out <= code_to_out[0];
							outputstate <= state1;
						end else begin
								outputstate <= reset;
							end
					end
		state1:	begin
						data_out <= code_to_out[1];
						outputstate <= state2;
					end
		state2:	begin
						data_out <= code_to_out[2];
						outputstate <= state3;
					end
		state3:	begin
						data_out <= code_to_out[3];
						outputstate <= state4;
					end
		state4:	begin
						data_out <= code_to_out[4];
						outputstate <= state5;
					end
		state5:	begin
						data_out <= code_to_out[5];
						outputstate <= state6;
					end
		state6:	begin
						data_out <= code_to_out[6];
						outputstate <= state7;
					end
		state7:	begin
						data_out <= code_to_out[7];
						outputstate <= state8;
					end
		state8:	begin
						data_out <= ~^code_to_out[7:0];
						outputstate <= state9;
					end
		state9:	begin
						data_out <= 1'b1;
						outputstate <= state10;
					end
		state10:	begin
						enable_data_input <= 1'b1;
						outputstate <= state11;
					end
		state11: begin
						data_out <= 1'b0;
						outputstate <= reset;
					end
	endcase
end

// запуск вывода нужного кода при нажатии одной из 3 клавиш
always @(posedge impulse80us) begin
	if((datkey == 8'b00010100) | (datkey == 8'b01110110) | (datkey == 8'b01011111)) begin
		case(impulsestate)
			reset:  begin
							if(impulse80us_counter == 1'b0) begin
								impulse80us_counter <= impulse80us_counter + 1'b1;
								enable_clock_input <= 1'b0;
								code_to_out <= datkey;
								impulsestate <= state1;
							end else begin
									impulsestate <= reset;
								end
						end
			state1:	begin
							enable_clock_input <= 1'b1;
							impulsestate <= reset;
						end
		endcase
	end
end

always @(posedge CLOCK_50) begin
	case(memory_currentstate)
		memory_state1: begin
								if(((code_memory[2] == 8'b00010010) | (code_memory[2] == 8'b00110100)) & ((code_memory[3] == 8'b00010010) | (code_memory[3] == 8'b00110100))) begin
									number_of_zeros <= 4'b1000 - ((datkey[7])*4'b0001 + (datkey[6])*4'b0001 + (datkey[5])*4'b0001 + (datkey[4])*4'b0001 + (datkey[3])*4'b0001 + (datkey[2])*4'b0001 + (datkey[1])*4'b0001 + (datkey[0])*4'b0001);
								end
							end
		memory_state2: begin
								if(((code_memory[3] == 8'b00010010) | (code_memory[3] == 8'b00110100)) & ((code_memory[0] == 8'b00010010) | (code_memory[0] == 8'b00110100))) begin
									number_of_zeros <= 4'b1000 - ((datkey[7])*4'b0001 + (datkey[6])*4'b0001 + (datkey[5])*4'b0001 + (datkey[4])*4'b0001 + (datkey[3])*4'b0001 + (datkey[2])*4'b0001 + (datkey[1])*4'b0001 + (datkey[0])*4'b0001);
								end
							end
		memory_state3: begin
								if(((code_memory[0] == 8'b00010010) | (code_memory[0] == 8'b00110100)) & ((code_memory[1] == 8'b00010010) | (code_memory[1] == 8'b00110100))) begin
									number_of_zeros <= 4'b1000 - ((datkey[7])*4'b0001 + (datkey[6])*4'b0001 + (datkey[5])*4'b0001 + (datkey[4])*4'b0001 + (datkey[3])*4'b0001 + (datkey[2])*4'b0001 + (datkey[1])*4'b0001 + (datkey[0])*4'b0001);
								end
							end
		memory_state4: begin
								if(((code_memory[1] == 8'b00010010) | (code_memory[1] == 8'b00110100)) & ((code_memory[2] == 8'b00010010) | (code_memory[2] == 8'b00110100))) begin
									number_of_zeros <= 4'b1000 - ((datkey[7])*4'b0001 + (datkey[6])*4'b0001 + (datkey[5])*4'b0001 + (datkey[4])*4'b0001 + (datkey[3])*4'b0001 + (datkey[2])*4'b0001 + (datkey[1])*4'b0001 + (datkey[0])*4'b0001);
								end
							end
	endcase
end

always @(posedge CLOCK_50) begin
	case(memory_currentstate)
		memory_state1: begin
								if((code_memory[3] != 8'b00010010) & (code_memory[3] != 8'b00110100)) begin
									datkey <= code_memory[3];
								end else begin
										if(code_memory[1] == code_memory[3])
											datkey <= code_memory[3];
									end
								if(code_memory[3] == 8'b11110000)
									datkey <= code_memory[2];
							end
		memory_state2: begin
								if((code_memory[0] != 8'b00010010) & (code_memory[0] != 8'b00110100)) begin
									datkey <= code_memory[0];
								end else begin
										if(code_memory[2] == code_memory[0])
											datkey <= code_memory[0];
									end
								if(code_memory[0] == 8'b11110000)
									datkey <= code_memory[3];
							end
		memory_state3: begin
								if((code_memory[1] != 8'b00010010) & (code_memory[1] != 8'b00110100)) begin
									datkey <= code_memory[1];
								end else begin
										if(code_memory[3] == code_memory[1])
											datkey <= code_memory[1];
									end
								if(code_memory[1] == 8'b11110000)
									datkey <= code_memory[0];
							end
		memory_state4: begin
								if((code_memory[2] != 8'b00010010) & (code_memory[2] != 8'b00110100)) begin
									datkey <= code_memory[2];
								end else begin
										if(code_memory[0] == code_memory[2])
											datkey <= code_memory[2];
									end
								if(code_memory[2] == 8'b11110000)
									datkey <= code_memory[1];
							end
	endcase
end

always @(posedge write_memory) begin
	case(memory_currentstate)
		memory_state1: begin
								code_memory[0] <= code_8_bit;
								memory_currentstate <= memory_state2;
							end
		memory_state2: begin
								code_memory[1] <= code_8_bit;
								memory_currentstate <= memory_state3;
							end
		memory_state3: begin
								code_memory[2] <= code_8_bit;
								memory_currentstate <= memory_state4;
							end
		memory_state4: begin
								code_memory[3] <= code_8_bit;
								memory_currentstate <= memory_state1;
							end
	endcase
end

always @(negedge PS2_CLK) begin
	if(enable_data_input) begin
		case(currentstate)
			reset: 	begin
							if(PS2_DAT == 0) begin
								currentstate <= state1;
								code_from_device <= {PS2_DAT, code_from_device[10:1]};
								write_memory <= 1'b0;
								error_marker <= 1'b0;
							end else
								currentstate <= reset;
						end
			state1: 	begin
							currentstate <= state2;
							code_from_device <= {PS2_DAT, code_from_device[10:1]};
						end
			state2: 	begin
							currentstate <= state3;
							code_from_device <= {PS2_DAT, code_from_device[10:1]};
						end
			state3: 	begin
							currentstate <= state4;
							code_from_device <= {PS2_DAT, code_from_device[10:1]};
						end
			state4: 	begin
							currentstate <= state5;
							code_from_device <= {PS2_DAT, code_from_device[10:1]};
						end
			state5:	begin
							currentstate <= state6;
							code_from_device <= {PS2_DAT, code_from_device[10:1]};
						end
			state6:	begin
							currentstate <= state7;
							code_from_device <= {PS2_DAT, code_from_device[10:1]};
						end
			state7:	begin
							currentstate <= state8;
							code_from_device <= {PS2_DAT, code_from_device[10:1]};
						end
			state8:	begin
							currentstate <= state9;
							code_from_device <= {PS2_DAT, code_from_device[10:1]};
						end
			state9:	begin
							code_from_device <= {PS2_DAT, code_from_device[10:1]};
							if(PS2_DAT == ~^code_from_device[10:3]) begin
								currentstate <= state10;
							end else begin
								currentstate <= reset;
								code_from_device <= 11'b0;
								error_marker <= 1'b1;
							end
						end
			state10:	begin
							if(PS2_DAT == 1) begin
								code_from_device = {PS2_DAT, code_from_device[10:1]};
								success_code_from_device[10:0] <= code_from_device[10:0];
								write_memory <= 1'b1;
								currentstate <= reset;
							end else begin
								currentstate <= reset;
								code_from_device <= 11'b11111111111;
								error_marker <= 1'b1;
							end
						end
		endcase
	end
end

endmodule
