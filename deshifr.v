module deshifr(
											input [7:0] code,
											input [3:0] number_of_zeros,
											output reg [6:0] Hex0,
											output reg [6:0] Hex1,
											output reg [6:0] Hex2);


							
always @* begin
	case(code[3:0])
		4'h0: Hex0 = 7'b1000000;
		4'h1: Hex0 = 7'b1111001;
		4'h2: Hex0 = 7'b0100100;
		4'h3: Hex0 = 7'b0110000;
		4'h4: Hex0 = 7'b0011001;
		4'h5: Hex0 = 7'b0010010;
		4'h6: Hex0 = 7'b0000010;
		4'h7: Hex0 = 7'b1111000;
		4'h8: Hex0 = 7'b0000000;
		4'h9: Hex0 = 7'b0010000;
		4'hA: Hex0 = 7'b0001000;
		4'hB: Hex0 = 7'b0000011;
		4'hC: Hex0 = 7'b1000110;
		4'hD: Hex0 = 7'b0100001;
		4'hE: Hex0 = 7'b0000110;
		4'hF: Hex0 = 7'b0001110;
	endcase
	case(code[7:4])
		4'h0: Hex1 = 7'b1000000;
		4'h1: Hex1 = 7'b1111001;
		4'h2: Hex1 = 7'b0100100;
		4'h3: Hex1 = 7'b0110000;
		4'h4: Hex1 = 7'b0011001;
		4'h5: Hex1 = 7'b0010010;
		4'h6: Hex1 = 7'b0000010;
		4'h7: Hex1 = 7'b1111000;
		4'h8: Hex1 = 7'b0000000;
		4'h9: Hex1 = 7'b0010000;
		4'hA: Hex1 = 7'b0001000;
		4'hB: Hex1 = 7'b0000011;
		4'hC: Hex1 = 7'b1000110;
		4'hD: Hex1 = 7'b0100001;
		4'hE: Hex1 = 7'b0000110;
		4'hF: Hex1 = 7'b0001110;
	endcase
	case(number_of_zeros[3:0])
		4'h0: Hex2 = 7'b1000000;
		4'h1: Hex2 = 7'b1111001;
		4'h2: Hex2 = 7'b0100100;
		4'h3: Hex2 = 7'b0110000;
		4'h4: Hex2 = 7'b0011001;
		4'h5: Hex2 = 7'b0010010;
		4'h6: Hex2 = 7'b0000010;
		4'h7: Hex2 = 7'b1111000;
		4'h8: Hex2 = 7'b0000000;
		4'h9: Hex2 = 7'b0010000;
		4'hA: Hex2 = 7'b0001000;
		4'hB: Hex2 = 7'b0000011;
		4'hC: Hex2 = 7'b1000110;
		4'hD: Hex2 = 7'b0100001;
		4'hE: Hex2 = 7'b0000110;
		4'hF: Hex2 = 7'b0001110;
	endcase
end

endmodule
