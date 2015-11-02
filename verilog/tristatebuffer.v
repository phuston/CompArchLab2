module tristatebuffer
(
	input d,
	output q,
	input enable
);

assign q = enable? d : 'bz;

endmodule