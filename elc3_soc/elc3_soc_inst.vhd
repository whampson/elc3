	component elc3_soc is
		port (
			clk_clk       : in  std_logic := 'X'; -- clk
			reset_reset_n : in  std_logic := 'X'; -- reset_n
			sdram_clk_clk : out std_logic         -- clk
		);
	end component elc3_soc;

	u0 : component elc3_soc
		port map (
			clk_clk       => CONNECTED_TO_clk_clk,       --       clk.clk
			reset_reset_n => CONNECTED_TO_reset_reset_n, --     reset.reset_n
			sdram_clk_clk => CONNECTED_TO_sdram_clk_clk  -- sdram_clk.clk
		);

