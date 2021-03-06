`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/09 01:26:18
// Design Name: 
// Module Name: hazard
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module hazard(
	// 取指
	output wire stallF,
	// 译码
	input wire [4:0] rsD,
	input wire [4:0] rtD,
	input wire branchD,
	output wire forwardaD,
	output wire forwardbD,
	output wire stallD,
	// 执行
	input wire [4:0] rsE,
	input wire [4:0] rtE,
	input wire [4:0] writeregE,
	input wire regwriteE,
	input wire memtoregE,
	output reg [1:0] forwardaE,
	output reg [1:0] forwardbE,
	output wire flushE,
	// 访存
	input wire [4:0] writeregM,
	input wire regwriteM,
	input wire memtoregM,
	// 回写
	input wire [4:0] writeregW,
	input wire regwriteW
    );

	wire lwstallD;
	wire branchstallD;

	assign forwardaD = ((rsD != 0) && (rsD == writeregM) && regwriteM);
	assign forwardbD = ((rtD != 0) && (rtD == writeregM) && regwriteM);

	always @ (*)
	begin
		forwardaE = 2'b00;
		forwardbE = 2'b00;
		if (rsE != 0)
		begin
			if ((rsE == writeregM) && regwriteM)
				forwardaE = 2'b10;
			else if ((rsE == writeregW) && regwriteW)
				forwardaE = 2'b01;
		end
		if (rtE != 0)
		begin
			if ((rtE == writeregM) && regwriteM)
				forwardbE = 2'b10;
			else if ((rtE == writeregW) && regwriteW)
				forwardbE = 2'b01;
		end
	end

	assign lwstallD = memtoregE && ((rtE == rsD) || (rtE == rtD));

	assign branchstallD = branchD && 
			(regwriteE && 
			((writeregE == rsD) || (writeregE == rtD))|| 
			memtoregM && 
			((writeregM == rsD) || (writeregM == rtD)));

	assign stallF = lwstallD || branchstallD;
	assign stallD = lwstallD || branchstallD;
	assign flushE = lwstallD || branchstallD;

endmodule
