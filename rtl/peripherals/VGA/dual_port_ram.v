module dual_port_ram #(
    parameter RAM_WIDTH = 8,                        // Specify RAM data width
    parameter RAM_DEPTH = 16,                       // Specify RAM depth (number of entries)
    parameter INIT_FILE = ""                        // Specify name/location of RAM initialization file if using one (leave blank if not)
)(
    input wire [clogb2(RAM_DEPTH)-1:0] addra, // Write address bus, width determined from RAM_DEPTH
    input wire [clogb2(RAM_DEPTH)-1:0] addrb, // Read address bus, width determined from RAM_DEPTH
    input wire [RAM_WIDTH-1:0] dina,          // RAM input data
    input wire clka,                          // Clock
    input wire wea,                           // Write enable
    input wire enb,                           // Read Enable, for additional power savings, disable when not in use
    input wire rstb,                          // Output reset (does not affect memory contents)
    input wire regceb,                        // Output register enable
    output wire [RAM_WIDTH-1:0] douta,                  // RAM output data
    output wire [RAM_WIDTH-1:0] doutb                  // RAM output data
);
  reg [RAM_WIDTH-1:0] ram [RAM_DEPTH-1:0];
  reg [RAM_WIDTH-1:0] ram_data_a = {RAM_WIDTH{1'b0}};
  reg [RAM_WIDTH-1:0] ram_data_b = {RAM_WIDTH{1'b0}};

  // The following code either initializes the memory values to a specified file or to all zeros to match hardware
  generate
    if (INIT_FILE != "") begin: use_init_file
      initial
        $readmemh(INIT_FILE, ram, 0, RAM_DEPTH-1);
    end else begin: init_bram_to_zero
      integer ram_index;
      initial
        for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
          ram[ram_index] = {RAM_WIDTH{1'b0}};
    end
  endgenerate

  always @(posedge clka) begin
    if (wea)
      ram[addra] <= dina;
    else
      ram_data_a <= ram[addra];
    if (enb)
      ram_data_b <= ram[addrb];
  end        

  assign douta = ram_data_a;
  assign doutb = ram_data_b;

  //  The following function calculates the address width based on specified RAM depth
  function integer clogb2;
    input integer depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
  endfunction
endmodule

