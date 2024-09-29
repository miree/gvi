library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;

use work.wbp_pkg.all;

entity testbench is
end entity;

architecture simulation of testbench is
	signal clk_i : std_logic := '1';
	signal rst_i : std_logic := '1';
	signal irq_i : std_logic_vector(31 downto 0) := (others => '0');
	signal wbp_cpu_ins : t_wbp := c_wbp_init;
	signal wbp_cpu_dat : t_wbp := c_wbp_init;
	signal wbp_mem     : t_wbp := c_wbp_init;
	signal wbp_out     : t_wbp := c_wbp_init;
begin

	clk_i <= not clk_i after 5 ns;
	rst_i <= '0' after 20 ns;

	cpu : entity work.urv_cpu_wbp
	--cpu : entity work.picorv32_wbp2
	--cpu : entity work.serv_rf_wbp
	port map (
		clk_i  => clk_i,
		rst_i  => rst_i,
		irq_i  => irq_i,
		wbi_o  => wbp_cpu_ins.mosi,
		wbi_i  => wbp_cpu_ins.miso,
		wbd_o  => wbp_cpu_dat.mosi,
		wbd_i  => wbp_cpu_dat.miso
	);

	splitter: entity work.wbp_1s2m
	generic map (
		adr_bit => 31
		)
	port map (
		clk_i => clk_i,
		slave_i => wbp_cpu_dat.mosi,
		slave_o => wbp_cpu_dat.miso,
		masters_o(0) => wbp_mem.mosi,
		masters_o(1) => wbp_out.mosi,
		masters_i(0) => wbp_mem.miso,
		masters_i(1) => wbp_out.miso
		);

	memory: entity work.dpram_wbp
	generic map (
			g_adr_width => 12,
			g_initfile  => "firmware/firmware.bitvector"
		)
	port map (
		clk_i      => clk_i,
		rst_i      => rst_i,
		slave_rw_i => wbp_mem.mosi,
		slave_rw_o => wbp_mem.miso,
		slave_ro_i => wbp_cpu_ins.mosi,
		slave_ro_o => wbp_cpu_ins.miso
	);


	output: process
		FILE stdout : text;-- is "cpu_output.txt";
		variable cpu_output : line;
		variable ch : character;
	begin
		file_open(stdout, "cpu_output.txt", write_mode);
		while true loop

			wait until rising_edge(clk_i);

			wbp_out.miso.ack <= '0';
			wbp_out.miso.err <= '0';
			if wbp_out.mosi.cyc = '1' and wbp_out.mosi.stb = '1' then
				if wbp_out.mosi.we = '1' then
					wbp_out.miso.ack <= '1';
					ch := character'val(to_integer(unsigned(wbp_out.mosi.dat(7 downto 0))));
					if ch = LF then
						writeline(stdout,cpu_output);
						flush(stdout);
					else
						write(cpu_output, ch);
					end if;
					report "output => " & ch;
				else
					wbp_out.miso.err <= '1';
				end if; 
			end if;
		end loop;
		
	end process;


end architecture simulation;

