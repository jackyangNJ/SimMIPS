module SinglePortRam#(
    parameter NB_COL = 4,                       // Specify number of columns (number of bytes)
    parameter COL_WIDTH = 8,                  // Specify column width (byte width, typically 8 or 9)
    parameter RAM_DEPTH = 1024,                  // Specify RAM depth (number of entries)
    parameter INIT_FILE = ""                       // Specify name/location of RAM initialization file if using one (leave blank if not)
)(
    input clk_i,
    input we_i,
    input [clogb2(RAM_DEPTH)-1:0]  adr_i,    // Address bus; width determined from RAM_DEPTH
    input [NB_COL-1:0]             be_i,     // Byte-write enable
    input [(NB_COL*COL_WIDTH)-1:0] dat_i,    // RAM input data
    output[(NB_COL*COL_WIDTH)-1:0] dat_o     // RAM output data
);

    //memory
    reg [(NB_COL*COL_WIDTH)-1:0] ram [RAM_DEPTH-1:0];
    reg [(NB_COL*COL_WIDTH)-1:0] q = {(NB_COL*COL_WIDTH){1'b0}};

  // The following code either initializes the memory values to a specified file or to all zeros to match hardware
  generate
    if (INIT_FILE != "") begin: use_init_file
      initial
        $readmemh(INIT_FILE, ram, 0, RAM_DEPTH-1);
    end else begin: init_bram_to_zero
      integer ram_index;
      initial
        for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
          ram[ram_index] = {(NB_COL*COL_WIDTH){1'b0}};
    end
  endgenerate

  //data read
  always @(posedge clk_i)
      q <= ram[adr_i];
  assign dat_o = q;
  
  //data write
  generate
  genvar i;
     for (i = 0; i < NB_COL; i = i+1) begin: byte_write
       always @(posedge clk_i)
         if (we_i & be_i[i])
           ram[adr_i][(i+1)*COL_WIDTH-1:i*COL_WIDTH] <= dat_i[(i+1)*COL_WIDTH-1:i*COL_WIDTH];
      end
  endgenerate

  //  The following function calculates the address width based on specified RAM depth
  function integer clogb2;
    input integer depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
  endfunction
  
endmodule
