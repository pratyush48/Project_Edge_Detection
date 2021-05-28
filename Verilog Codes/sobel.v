`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.05.2021 00:34:22
// Design Name: 
// Module Name: sobel
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


module sobel(clk,flag,el1,el2,el3,el4,el5,el6,el7,el8,el9,valid,sqr);

input clk;
input flag;
input[7:0] el1,el2,el3,el4,el5,el6,el7,el8,el9;
reg[7:0] out1,out2,out3,out4,out5,out6,out7,out8,out9,out11,out12,out13,out14,out15,out16,out17,out18,out19;
reg[10:0]Gx,Gy;
reg[31:0]Gx_sq,Gy_sq;
reg[31:0]sum;
reg a_tvalid = 0;
wire a_tready;
output reg valid;
reg result_tready = 0;
//output [31:0]result_tdata;
reg[31:0]a_tdata;
reg[7:0]Mx[1:3][1:3];
reg[7:0]My[1:3][1:3];
output reg[31:0] sqr;
integer i=1,j=1;
integer e1,e2,e3,e4,e5,e6,e7,e8,e9;
function [15:0] sqrt;
    input [31:0] num;  //declare input
    //intermediate signals.
    reg [31:0] a;
    reg [15:0] q;
    reg [17:0] left,right,r;    
    integer i;
begin
    //initialize all the variables.
    a = num;
    q = 0;
    i = 0;
    left = 0;   //input to adder/sub
    right = 0;  //input to adder/sub
    r = 0;  //remainder
    //run the calculations for 16 iterations.
    for(i=0;i<16;i=i+1) begin 
        right = {q,r[17],1'b1};
        left = {r[15:0],a[31:30]};
        a = {a[29:0],2'b00};    //left shift by 2 bits.
        if (r[17] == 1) //add if r is negative
            r = left + right;
        else    //subtract if r is positive
            r = left - right;
        q = {q[14:0],!r[17]};       
    end
    sqrt = q;   //final assignment of output.
end
endfunction
floating_point_0 sqrt1 (
  .aclk(clk),                                  // input wire aclk
  .s_axis_a_tvalid(a_tvalid),            // input wire s_axis_a_tvalid
  .s_axis_a_tready(a_tready),            // output wire s_axis_a_tready
  .s_axis_a_tdata(a_tdata),              // input wire [31 : 0] s_axis_a_tdata
  .m_axis_result_tvalid(result_tvalid),  // output wire m_axis_result_tvalid
  .m_axis_result_tready(result_tready),  // input wire m_axis_result_tready
  .m_axis_result_tdata(result_tdata)    // output wire [31 : 0] m_axis_result_tdata
);

initial begin
Mx[1][1] = -1;
Mx[1][2] = 0;
Mx[1][3] = 1;
Mx[2][1] = -2;
Mx[2][2] = 0;
Mx[2][3] = 2;
Mx[3][1] = -1;
Mx[3][2] = 0;
Mx[3][3] = 1;
My[1][1] = -1;
My[1][2] = -2;
My[1][3] = -1;
My[2][1] = 0;
My[2][2] = 0;
My[2][3] = 0;
My[3][1] = 1;
My[3][2] = 2;
My[3][3] = 1;
end

always@(posedge clk)
begin
    if(flag==1)begin
    //loop unrolling
    out1 <= Mx[1][1]*el1;
    out2 <= Mx[1][2]*el2;
    out3 <= Mx[1][3]*el3;
    out4 <= Mx[2][1]*el4;
    out5 <= Mx[2][2]*el5;
    out6 <= Mx[2][3]*el6;
    out7 <= Mx[3][1]*el7;
    out8 <= Mx[3][2]*el8;
    out9 <= Mx[3][3]*el9;
    out11 <= My[1][1]*el1;
    out12 <= My[1][2]*el2;
    out13 <= My[1][3]*el3;
    out14 <= My[2][1]*el4;
    out15 <= My[2][2]*el5;
    out16 <= My[2][3]*el6;
    out17 <= My[3][1]*el7;
    out18 <= My[3][2]*el8;
    out19 <= My[3][3]*el9;
    e1=el1;
    e2=el2;
    e3=el3;
    e4=el4;
    e5=el5;
    e6=el6;
    e7=el7;
    e8=el8;
    e9=el9;
    Gx_sq = (e3-2*e4+2*e6-e7+e9-e1)*(e3-2*e4+2*e6-e7+e9-e1);
    Gy_sq = (e7+2*e8+e9-e1-2*e2-e3)*(e7+2*e8+e9-e1-2*e2-e3);
    sum = Gx_sq+Gy_sq;
    sqr = sqrt(sum);
    $display("Gx_sq=%d,Gy_sq=%d,sqr=%d",Gx_sq,Gy_sq,sqr);
    valid = 1;
    end
end

endmodule
