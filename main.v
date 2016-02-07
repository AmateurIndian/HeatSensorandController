`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////// 
// Company: Bilkent University
// Engineer: Figali Taho, Syed Sarjeel Yusuf
//////////////////////////////////////////////////////////////////////////////////
module Main(
	input clk, 
	input rset, dir, 
	output reg buzz, led,
	output reg [0:3] LEDs, 
	input clear,
	output [3:0] AN,
	output [6:0] C,
	output       DP,
	output reg oe, //output enable	
	output reg shiftReg_clk, // shift register clk pulse
	output reg storeReg_clk, // store register clk pulse	
	output reg reset, // reset for the shift register
	output reg DS, // digital signal
	output reg [7:0] c_for_matrix
    );
	 
	reg [3:0] current_digit, cur_dig_AN;
	reg [6:0] segments;
	
	assign AN = (cur_dig_AN);// AN signals are active low,
									  // and must be enabled to display digit
	assign C = ~segments;     // since the CA values are active low
	assign DP = 1;            // the dot point is always off 
									  // (0 = on, since it is active low)
									  
	// the 18-bit counter, runs at 50 MHz, so bit16 changes each 1.3 millisecond
	localparam N=18;
	reg [N-1:0] count;
	reg [3:0] first, second;
	
	wire display_x ;
	assign display_x = buzz;
	
	//register
	reg [7:0] counttemp;
	
	//for temp tresholds
	parameter led1th = 8'b00011110; //30
	parameter led2th = 8'b00110010; //50
	parameter led3th = 8'b01000110; //70
	parameter led4th = 8'b01011010; //90
	
	
	//counttemp ticker
	reg [26:0] ticker;
	reg onesec;
	
	always @(posedge clk)
		if(rset) begin
			ticker <= 27'b0;
			onesec <= 1'b0;
			count <= 0;
			end
		else if (ticker == 27'b1011111010111100001000000) begin
			ticker <= 27'b0;
			onesec <= ~onesec;
			end
		else begin
			ticker <= ticker + 1;
			//onesec <= ~onesec;
			count <= count + 1;
		end
		
	always led <= onesec;
	
	always @(posedge onesec) begin
		if((~dir) ) begin
				if(rset) begin 
					counttemp = 8'b0;
					LEDs[0] <= 1'b0;
					LEDs[1] <= 1'b0;
					LEDs[2] <= 1'b0;
					LEDs[3] <= 1'b0;
					buzz <= 1'b0;
					end
				else if (counttemp == 90) begin
					LEDs[0] <= 1'b1;
					LEDs[1] <= 1'b1;
					LEDs[2] <= 1'b1;
					LEDs[3] <= 1'b1;
					buzz <= 1'b1;
				end
				else if (counttemp < led1th) begin
					counttemp = counttemp + 1;
					buzz <= 1'b0;
					end
				else if (counttemp >= led1th && counttemp < led2th) begin
					LEDs[0] <= 1'b1;
					counttemp = counttemp + 1;
					buzz <= 1'b0;
					end
				else if (counttemp >= led2th && counttemp < led3th) begin
					LEDs[0] <= 1'b1;
					LEDs[1] <= 1'b1;
					counttemp = counttemp + 1;
					buzz <= 1'b0;
					end
				else if (counttemp >= led3th && counttemp < led4th) begin
					LEDs[0] <= 1'b1;
					LEDs[1] <= 1'b1;
					LEDs[2] <= 1'b1;
					counttemp = counttemp + 1;
					buzz <= 1'b0;
					end
				else if (counttemp == led4th) begin
					LEDs[0] <= 1'b1;
					LEDs[1] <= 1'b1;
					LEDs[2] <= 1'b1;
					LEDs[3] <= 1'b1;
					buzz <= 1'b1;
					counttemp = counttemp + 1;
					end
				else counttemp = counttemp + 1;
			end
		else  begin
			 if(rset) begin 
					counttemp = 8'b0;
					LEDs[0] <= 1'b0;
					LEDs[1] <= 1'b0;
					LEDs[2] <= 1'b0;
					LEDs[3] <= 1'b0;
					buzz <= 1'b0;
					end
				else if (counttemp == 0) begin
					LEDs[0] <= 1'b0;
					LEDs[1] <= 1'b0;
					LEDs[2] <= 1'b0;
					LEDs[3] <= 1'b0;
					buzz <= 1'b0;
				end
				else if (counttemp < led1th) begin
					counttemp = counttemp - 1;
					LEDs[0] <= 1'b0;
					LEDs[1] <= 1'b0;
					LEDs[2] <= 1'b0;
					LEDs[3] <= 1'b0;
					buzz <= 1'b0;
					end
				else if (counttemp >= led1th && counttemp < led2th) begin
					LEDs[0] <= 1'b1;
					LEDs[1] <= 1'b0;
					LEDs[2] <= 1'b0;
					LEDs[3] <= 1'b0;
					buzz <= 1'b0;
					counttemp = counttemp - 1;
					end
				else if (counttemp >= led2th && counttemp < led3th) begin
					LEDs[0] <= 1'b1;
					LEDs[1] <= 1'b1;
					LEDs[2] <= 1'b0;
					LEDs[3] <= 1'b0;
					buzz <= 1'b0;
					counttemp = counttemp - 1;
					end
				else if (counttemp >= led3th && counttemp < led4th) begin
					LEDs[0] <= 1'b1;
					LEDs[1] <= 1'b1;
					LEDs[2] <= 1'b1;
					LEDs[3] <= 1'b0;
					buzz <= 1'b0;
					counttemp = counttemp - 1;
					end
				else if (counttemp == led4th) begin
					LEDs[0] <= 1'b1;
					LEDs[1] <= 1'b1;
					LEDs[2] <= 1'b1;
					LEDs[3] <= 1'b1;
					buzz <= 1'b1;
					counttemp = counttemp - 1;
					end
				else counttemp = counttemp - 1;
			end
	end



	//displaying temperature with changes on each second till 90
  //first left hand digit second right hand digit
	always@(counttemp)begin 
		 if(counttemp > 99) begin first = 9; second = 0; end
		 else if(counttemp >= 90) begin first = 9; second = 0; end            
		 else if(counttemp >= 80) begin first = 8; second = counttemp - 80; end
		 else if(counttemp >= 70) begin first = 7; second = counttemp - 70; end
		 else if(counttemp >= 60) begin first = 6; second = counttemp - 60; end
		 else if(counttemp >= 50) begin first = 5; second = counttemp - 50; end
		 else if(counttemp >= 40) begin first = 4; second = counttemp - 40; end
		 else if(counttemp >= 30) begin first = 3; second = counttemp - 30; end
		 else if(counttemp >= 20) begin first = 2; second = counttemp - 20; end
		 else if(counttemp >= 10) begin first = 1; second = counttemp - 10; end
		 else if(counttemp >= 0) begin first = 0; second = counttemp; end
	end
  
  always@(count, first, second)begin
		case(count[17:16])
			 00: begin current_digit = second;  cur_dig_AN = 4'b1110; end
			 01: begin current_digit = first;   cur_dig_AN = 4'b1101; end
			 default: begin current_digit = 4'bxxxx; cur_dig_AN = 4'bxxxx; end
			 endcase
		end
			
// the hex-to-7-segment decoder
	always @ (current_digit)
		case (current_digit)
		4'b0000: segments = 7'b111_1110;  // 0
		4'b0001: segments = 7'b011_0000;  // 1
		4'b0010: segments = 7'b110_1101;  // 2
		4'b0011: segments = 7'b111_1001;  // 3
		4'b0100: segments = 7'b011_0011;  // 4
		4'b0101: segments = 7'b101_1011;  // 5
		4'b0110: segments = 7'b101_1111;  // 6
		4'b0111: segments = 7'b111_0000;  // 7
		4'b1000: segments = 7'b111_1111;  // 8
		4'b1001: segments = 7'b111_0011;  // 9
		default: segments = 7'bxxx_xxxx;
		endcase

//-------------------------------------------------------for display matrix-----------------
	wire [24:1] info;
	reg [7:0] red ;
	//signals for shifting
	reg f;
	reg e;
	//counter for producing f and e
	reg [3:0] counter;
	reg[8:0] i = 1; 
	reg[2:0] column= 0; 


	assign info[24:17] = red ;
	initial begin
	   red = 8'hFF;
	end
	
	always@(posedge clk)
	begin
		counter = counter+1;
		f <= counter[3]; // clk signal for the shift register
		e <= ~f;
	end	
	
	//counter for reset for shift register
	always@( posedge e)
		i = i+9'b000000001;
	
	//shift register logic
	always@(*) begin
		if (i < 9'b000000100) reset<=0;
		else reset<=1;
		
		if (i>9'b000000011 && i<9'b000011100) DS<=info[i-9'b000000011];
		else DS<=0;
			
		if (i<9'b000011100)begin
			shiftReg_clk <= f;             
			storeReg_clk <= e;
			end
		else begin
			shiftReg_clk <= 0;
			storeReg_clk <= 1;
			end
	end
	
	//output enable
	always@(posedge f) begin
		if (i>9'b000011100 && i<9'b110011101)
			oe<=0;
		else
			oe<=1;
		end		
	
	always@(posedge f) begin	
		if (i==9'b110011110) 
			column= column+1;
		end
		 
	//display an x
	always@( column)
		if (display_x == 1)begin	
			if (column==0) begin
				c_for_matrix<=8'b10000000;
				red <= 8'b00000000;
				end
			else if (column==1) begin
				c_for_matrix<=8'b01000000;
				red <= 8'b00000000;
				end
			else if (column==2) begin
				c_for_matrix<=8'b00100000;
				red <= 8'b00000000;
				end
			else if (column==3) begin
				c_for_matrix<=8'b00010000;
				red <= 8'b00000000;
				end
			else if (column==4) begin
				c_for_matrix<=8'b00001000;
				red <= 8'b00000000;
				end
			else if (column==5) begin
				c_for_matrix<=8'b00000100;
				red <= 8'b10100000;
				end
			else if (column==6) begin
				c_for_matrix<=8'b00000010;
				red <= 8'b01000000;
				end
			else begin
				c_for_matrix<=8'b00000001;
				red <= 8'b10100000;
				end			
		end
		else begin	
			if (column==0) begin
				c_for_matrix<=8'b10000000;
				red <= 8'b00000000;
				end
			else if (column==1) begin
				c_for_matrix<=8'b01000000;
				red <= 8'b00000000;
				end
			else if (column==2) begin
				c_for_matrix<=8'b00100000;
				red <= 8'b00000000;
				end
			else if (column==3) begin
				c_for_matrix<=8'b00010000;
				red <= 8'b00000000;
				end
			else if (column==4) begin
				c_for_matrix<=8'b00001000;
				red <= 8'b00000000;
				end
			else if (column==5) begin
				c_for_matrix<=8'b00000100;
				red <= 8'b00000000;
				end
			else if (column==6) begin
				c_for_matrix<=8'b00000010;
				red <= 8'b00000000;
				end
			else begin
				c_for_matrix<=8'b00000001;
				red <= 8'b00000000;
				end			
		end
		
		
endmodule
