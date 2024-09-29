library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use work.wbp_pkg.all;

-- Wishbone dual-port memory that should be sythesized into block ram
-- The slave_rw port provides read-write access
-- The slave_ro port provides read-only access (e.g. for the instruction bus of CPU)
entity dpram_wbp is 
	generic ( 
		g_adr_width : natural  := 4;
		g_initfile : string := "none"
	);
	port (
		clk_i      :  in std_logic;
		rst_i      :  in std_logic;
		-- read-write access
		slave_rw_i :  in t_wbp_slave_in; 
		slave_rw_o : out t_wbp_slave_out;
		-- read-only access
		slave_ro_i :  in t_wbp_slave_in;   
		slave_ro_o : out t_wbp_slave_out
	);
end entity;


architecture rtl of dpram_wbp is
    type t_memory is array (0 to 2**g_adr_width-1) of bit_vector(31 downto 0);

    impure 
    function InitRamFromFile(RamFileName : in string) return t_memory is
        FILE RamFile : text;
        variable RamFileLine : line;
        variable RAM : t_memory := (others => (others =>'0')) ;
    begin
		file_open(RamFile, RamFileName);
        for i in t_memory'range loop
        	if endfile(RamFile) then
        		report "dpram_wpb: initialized content with " & RamFileName; 
        		return RAM; 
        	end if;
        	--report integer'image(i);
            readline(RamFile, RamFileLine);
            read(RamFileLine, RAM(i));
        end loop;
        return RAM;
    end function;
    
    impure 
    function init(filename : in string) return t_memory is 
    begin
        if filename /= "none" then 
            return InitRamFromFile(filename);
        end if;
        return (others => (others => '0')); 
    end function;


--	constant c_zeros : t_memory(g_mem_init'length to 2**g_adr_width-1) := (others => (others => '0'));
	signal memory : t_memory := init(g_initfile);
	signal slave_rw_out : t_wbp_slave_out := c_wbp_slave_out_init;
	signal slave_ro_out : t_wbp_slave_out := c_wbp_slave_out_init;

    
begin

	slave_rw_o <= slave_rw_out;
	slave_ro_o <= slave_ro_out;

	slave_rw_out.stall <= '0';
	slave_rw_out.rty   <= '0';
	slave_rw_out.err   <= '0';

	slave_ro_out.rty   <= '0';
	slave_ro_out.stall <= '0';

	read_write: process
		variable adr_a : integer;
		variable adr_b : integer;
	begin
		wait until rising_edge(clk_i);

		-- Reading and writing
		-- Ignore sel bits while reading because otherwise we'll not get block ram.
		-- Ignoring the sel bits here doesn't matter because the master can apply them.
		adr_a := to_integer(unsigned(slave_rw_i.adr(g_adr_width-1+2 downto 2)));
		if slave_rw_i.cyc = '1' and slave_rw_i.stb = '1' then 
			if slave_rw_i.we = '1' then
				for i in slave_rw_i.sel'range loop
					if slave_rw_i.sel(i) = '1' then 
						memory(adr_a)(8*i+7 downto 8*i) <= to_bitvector(slave_rw_i.dat(8*i+7 downto 8*i));
					end if;
				end loop;
			else
        		slave_rw_out.dat <= to_stdlogicvector(memory(adr_a));	
			end if;
			slave_rw_out.ack <= '1';
		else 
            slave_rw_out.ack <= '0';
		end if;

		-- Read-only
		adr_b := to_integer(unsigned(slave_ro_i.adr(g_adr_width-1+2 downto 2)));
		if slave_ro_i.cyc = '1' and slave_ro_i.stb = '1' then 
			if slave_ro_i.we = '1' then
                slave_ro_out.err <= '1';
                slave_ro_out.ack <= '0';
            else 
        		slave_ro_out.dat <= to_stdlogicvector(memory(adr_b));
                slave_ro_out.err <= '0';
                slave_ro_out.ack <= '1';
			end if;
		else 
		  slave_ro_out.ack <= '0';
		  slave_ro_out.err <= '0';
		end if;
		
	end process;

end architecture;
