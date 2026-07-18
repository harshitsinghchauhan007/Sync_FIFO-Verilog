`timescale 1ns / 1ps

module sync_fifo #(
    parameter DATA_WIDTH=8,
    parameter DEPTH=16)( 
    input clk,
    input reset,
    input wr_en,
    input rd_en,
    input [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out,
    output full,
    output empty
    );
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    reg [3:0] wr_ptr;
    reg [3:0] rd_ptr;
    reg [4:0] count;
    
    always @(posedge clk)
        begin
            if (reset) 
                begin
                    wr_ptr<=0;
                    rd_ptr<=0;
                    count<=0;
                    data_out<=0;
                end
            else
                begin
                    if (wr_en && !rd_en && !full)
                        begin
                            mem[wr_ptr]<=data_in;
                            if(wr_ptr==DEPTH-1)
                                wr_ptr<=0;
                            else
                                wr_ptr<=wr_ptr+1;
                            count<=count+1;
                        end
                    else if (rd_en && !wr_en && !empty)
                        begin
                            data_out<=mem[rd_ptr];
                            if(rd_ptr==DEPTH-1)
                                rd_ptr<=0;
                            else
                                rd_ptr<=rd_ptr+1;
                            count<=count-1;
                        end
                    else if (rd_en && wr_en)
                        begin
                            if (empty)
                                begin
                                    mem[wr_ptr]<=data_in;  //WRITE ONLY
                                    if (wr_ptr==DEPTH-1)   //UPDATE WRITE POINTER
                                        wr_ptr<=0;
                                    else
                                        wr_ptr<=wr_ptr+1;
                                    count<=count+1;
                                end
                            else
                                begin
                                    data_out<=mem[rd_ptr];
                                    mem[wr_ptr]<=data_in;
                                    if (wr_ptr==DEPTH-1)   //UPDATE WRITE POINTER
                                        wr_ptr<=0;
                                    else
                                        wr_ptr<=wr_ptr+1;
                                    if (rd_ptr==DEPTH-1)   //UPDATE READ POINTER
                                        rd_ptr<=0;
                                    else
                                        rd_ptr<=rd_ptr+1;
                                end
                        end
                end
        end
    assign full=(count==DEPTH);
    assign empty=(count==0);
endmodule
