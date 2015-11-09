// Tri-state buffer module
// Takes in input d and enable
// Outputs d or tri-state based on enable input

module tristatebuffer
(
	input d,
	output q,
	input enable
);

assign q = enable? d : 'bz;

endmodule