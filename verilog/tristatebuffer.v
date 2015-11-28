// Tri-state buffer module
// Takes in input d and enable
// Outputs d or tri-state based on enable input

module tristatebuffer
(
	input enable
	input d,
	output q,
);

    assign q = enable? d : 'bz;

endmodule
