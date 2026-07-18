`timescale 1ns / 1ps

module tb_sync_fifo;
    parameter DATA_WIDTH=8;
    parameter DEPTH=16;
    reg clk;
    reg reset;
    reg [DATA_WIDTH-1:0] data_in;
    reg wr_en;
    reg rd_en;
    wire [DATA_WIDTH-1:0] data_out;
    wire full;
    wire empty;
    sync_fifo #(.DATA_WIDTH(DATA_WIDTH),.DEPTH(DEPTH)) 
                DUT (.clk(clk),.reset(reset),.rd_en(rd_en),.wr_en(wr_en),.data_in(data_in),
                   .data_out(data_out),.full(full),.empty(empty));
    initial
        begin
            clk=0;
            forever #5 clk=~clk;
        end
        
    initial
        begin
            reset=1; wr_en=0; rd_en=0; data_in=0;
            #20 reset=0;
            
            #10 wr_en=1; data_in=8'hA5;            //WRITE 3 VALUES
            #10 data_in=8'h3C;
            #10 data_in=8'h55;   
            #10 wr_en=0;
            #10 rd_en=1;                           //READ 2 VALUES
            #20 rd_en=0; 
            #10 wr_en=1; rd_en=1; data_in=8'hAA;   //SIMULTANEOUS READ & WRITE
            #10 wr_en=0; rd_en=0;
            wr_en=1;                               //FILL FIFO
            repeat (16)
                begin
                    #10 data_in=data_in+1;
                end       
            wr_en=0;
            rd_en=1;                               //EMPTY FIFO
            repeat (16)
                #10;
            rd_en=0;
            #20 $finish;
        end
    initial
        begin
            $monitor("Time=%t, WR=%b, RD=%b, Data_in=%h, Dats_out=%h, Full=%b, Empty=%b",
                      $time,wr_en,rd_en,data_in,data_out,full,empty);
        end
endmodule
