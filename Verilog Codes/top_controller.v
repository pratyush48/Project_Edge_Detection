module topcontroller(   input clk,
                        input rst,
                        input rxd,
                        output txd );
    
    wire [15:0] prescale=100000000/(115200*8);
    reg[7:0]el[0:8];
    reg [7:0] senddata;
    reg sendvalid=0;
    wire [7:0] readdata;
    wire readvalid;
    reg[31:0]sum_num_y = 0,sum_num_x = 0,sum_den_x = 0;
    reg[1:0] counter_r,counter_w;
    reg[2:0] state=0;
    reg[7:0]Xcom = 0,Ycom = 0;//--ILA4,ILA5
    reg[7:0]roi[1:21][1:21];
    reg [7:0] data1=0;
    reg ena,enb;
    reg[0:0] wea,web;
    reg[13:0] addra,addrb;
    reg[7:0] dina,max = 0;
    reg[31:0]dinb;
    reg[15:0] row,col,row_max,row_min,col_max,col_min;
    wire[7:0] douta;
    wire[31:0] doutb;
    reg done = 0;
    reg max_done = 0;
    reg roi_done = 0;
    integer i,j,k,l,m;
    reg centroid_done = 0,el_fill_done = 0;
    wire flag;
    wire[31:0]data;
    integer count,element;
    
    uart uartuut(
    .clk(clk),
    .rst(rst),
    .s_axis_tdata(senddata),
    .s_axis_tvalid(sendvalid),
    .m_axis_tdata(readdata),
    .m_axis_tvalid(readvalid),
    .m_axis_tready(1),
    .rxd(rxd),
    .txd(txd),
    .prescale(prescale)

);

blk_mem_gen_0 image (
  .clka(clk),    // input wire clka
  .ena(ena),      // input wire ena
  .wea(wea),      // input wire [0 : 0] wea
  .addra(addra),  // input wire [13 : 0] addra
  .dina(dina),    // input wire [7 : 0] dina
  .douta(douta)  // output wire [7 : 0] douta
);

blk_mem_gen_1 filtered_image (
  .clka(clk),    // input wire clka
  .ena(enb),      // input wire ena
  .wea(web),      // input wire [0 : 0] wea
  .addra(addrb),  // input wire [13 : 0] addra
  .dina(dinb),    // input wire [31 : 0] dina
  .douta(doutb)  // output wire [31 : 0] douta
);

//blk_mem_gen_1 filtered_image (
//  .clka(clk),    // input wire clka
//  .ena(enb),      // input wire ena
//  .wea(web),      // input wire [0 : 0] wea
//  .addra(addrb),  // input wire [13 : 0] addra
//  .dina(dinb),    // input wire [7 : 0] dina
//  .douta(doutb)  // output wire [7 : 0] douta
//);

//blk_mem_gen_1 mem (
//  .clka(clk),    // input wire clka
//  .ena(ena),      // input wire ena
//  .wea(wea),      // input wire [0 : 0] wea
//  .addra(addra),  // input wire [15 : 0] addra--ILA1
//  .dina(dina),    // input wire [7 : 0] dina--ILA2
//  .douta(douta)  // output wire [7 : 0] douta--ILA3
//);

//ila_0 navyush (
//	.clk(clk), // input wire clk


//	.probe0(addra), // input wire [15:0]  probe0  
//	.probe1(dina), // input wire [7:0]  probe1 
//	.probe2(douta), // input wire [7:0]  probe2 
//	.probe3(Xcom), // input wire [7:0]  probe3 
//	.probe4(Ycom) // input wire [7:0]  probe4
//);

initial
begin
    ena = 1;
    wea = 1;
    enb = 1;
    web = 1;
    addra = 0;
    addrb = 0;
end

always @(posedge clk) begin
    if(rst==1) begin
        state=0;
        sendvalid=0;
        data1=0;
    end
    
    case(state)
    
    3'b000: begin //writing to block ram
            sendvalid=0;
            if(readvalid) begin
                ena = 1;
                wea = 1;            
                data1=readdata;
                dina = data1; 
                $display("dina=%d",dina); 
                addra = addra+1; 
                if(addra == 16383)begin 
                    $display("Hey");   
                    addra = -2;
                    done = 1;
                    wea = 0;
                    i=0;
                    j=0;
                    k=0;
                    l=0;
                    m=0;
                    element = 1;
                    state = 3'b001;
                end                  
                end                
            end   
    3'b001:begin//reading from blockram
          if(done == 1)begin
            if(i<126)begin
                if(j<126)begin
                    if(k<=i+2)begin
                        if(l<=j+2)begin
                            addra = k*127+l+1;
                            if(element > 3)begin
                                addra = addra+1;
                                if(element>6)
                                    addra = addra+1;
                            end
                            if(count<3)begin                            
                                count=count+1;
                            end
                            else begin
                                el[m] = douta;
                                element = element+1;
                                $display("i=%d,j=%d,k=%d,l=%d,m=%d,el[m]=%d,douta=%d,addra=%d",i,j,k,l,m,el[m],douta,addra);
                                l=l+1;
                                m=m+1;
                                count=0;
                            end
                        end
                        else begin
                            l=j;
                            k=k+1;
                        end
                    end
                    else begin
                        $display("entering state");
                        el_fill_done = 1;
                        web = 1;
                        state = 3'b010;
                    end
                end 
            end
            else begin
                $display("entering last state");
                addrb = 0;
                count = 0;
                state = 3'b011;                  
            end
          end
        end         
    3'b010:begin//filling filtered image
          if(el_fill_done == 1)begin
            if(valid == 1)begin
                addrb = (i+1)*127+(j+1);
                dinb = data;
                $display("addrb=%d,dinb=%d",addrb,dinb);   
                j=j+1;
                element=1;
                if(j==126)begin
                    j = 0;
                    i=i+1;
                end
                k=i;
                l=j;
                m=0;  
                el_fill_done = 0;             
                state = 3'b001;
            end
          end                      
          end
    3'b011:begin//Sending filtered image
            web = 0;
//            $finish;
            if(addrb<16384)begin
                if(count<3)
                    count=count+1;
                else begin
                    senddata = doutb;
                    $display("addrb=%d,doutb=%d",addrb,doutb);
                    sendvalid = 1;
                    addrb = addrb+1;
                    count=0;
                end
            end
            else begin
                $finish;
            end
          end
    endcase
end
sobel s(clk,el_fill_done,el[0],el[1],el[2],el[3],el[4],el[5],el[6],el[7],el[8],valid,data);
endmodule
