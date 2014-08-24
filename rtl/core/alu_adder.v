module alu_adder (
	cin,
	dataa,
	datab,
	cout,
	result);

	input	  cin;
	input	[31:0]  dataa;
	input	[31:0]  datab;
	output	  cout;
	output	[31:0]  result;

	assign{cout,result} = dataa + datab + cin;
	
endmodule