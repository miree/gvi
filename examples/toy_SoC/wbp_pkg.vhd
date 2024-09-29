library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Useful types for working with wishbone protocol, pipelined version as described
-- in the Wishbone B4 document: https://cdn.opencores.org/downloads/wbspec_b4.pdf
package wbp_pkg is

  constant c_wbp_adr_width : integer := 32;
  constant c_wbp_dat_width : integer := 32;

  subtype t_wbp_adr is
    std_logic_vector(c_wbp_adr_width-1 downto 0);
  subtype t_wbp_dat is
    std_logic_vector(c_wbp_dat_width-1 downto 0);
  subtype t_wbp_sel is
    std_logic_vector((c_wbp_adr_width/8)-1 downto 0);

  type t_wbp_master_out is record
    cyc : std_logic;
    stb : std_logic;
    adr : t_wbp_adr;
    sel : t_wbp_sel;
    we  : std_logic;
    dat : t_wbp_dat;
  end record t_wbp_master_out;
  subtype t_wbp_slave_in is t_wbp_master_out;
  type t_wbp_master_out_array  is array(natural range<>) of t_wbp_master_out;
  subtype t_wbp_slave_in_array is t_wbp_master_out_array;

  type t_wbp_slave_out is record
    ack   : std_logic;
    err   : std_logic;
    rty   : std_logic;
    stall : std_logic;
    dat   : t_wbp_dat;
  end record t_wbp_slave_out;
  subtype t_wbp_master_in is t_wbp_slave_out;
  type t_wbp_master_in_array is array(natural range<>) of t_wbp_master_in;
  subtype t_wbp_slave_out_array is t_wbp_master_in_array;

  constant c_wbp_master_out_init : t_wbp_master_out := (cyc=>'0',stb=>'0',we=>'0',adr=>(others=>'-'),dat=>(others=>'-'),sel=>(others=>'-'));  
  constant c_wbp_master_in_init  : t_wbp_master_in  := (ack=>'0',err=>'0',rty=>'0',stall=>'0',dat=>(others=>'-'));
  constant c_wbp_slave_out_init  : t_wbp_slave_out  := (ack=>'0',err=>'0',rty=>'0',stall=>'0',dat=>(others=>'-'));
  constant c_wbp_slave_in_init   : t_wbp_slave_in   := (cyc=>'0',stb=>'0',we=>'0',adr=>(others=>'-'),dat=>(others=>'-'),sel=>(others=>'-'));  

  type t_wbp is record
    mosi : t_wbp_master_out;
    miso : t_wbp_master_in;
  end record;
  type t_wbp_array is array(natural range<>) of t_wbp;

  constant c_wbp_init : t_wbp := (c_wbp_master_out_init, c_wbp_master_in_init);


end package;

package body wbp_pkg is
end package body;
