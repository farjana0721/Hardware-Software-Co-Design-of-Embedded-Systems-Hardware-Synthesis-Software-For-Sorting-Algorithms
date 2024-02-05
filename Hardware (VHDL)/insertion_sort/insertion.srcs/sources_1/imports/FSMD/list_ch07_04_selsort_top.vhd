-- (adapted from) Listing 7.4
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity insertion is
   generic(
     -- Default setting:
     -- 19,200 baud, 8 data bis, 1 stop bits
      DBIT: integer:=8;     -- # data bits
      SB_TICK: integer:=16; -- # ticks for stop bits, 16/24/32: for 1/1.5/2 stop bits
      DVSR: integer:= 326;  -- baud rate divisor: DVSR = 100M/(16*baud rate)
      DVSR_BIT: integer:=9; -- # bits of DVSR
	  RAM_ADDR_WIDTH: integer:=8;  -- # maximum size of the RAM: 2^10 (1024)
	  RAM_DATA_WIDTH: integer:=8   -- # 8-bit data words
   );
   port(
      clk, reset: in std_logic;
      rx: in std_logic;
      tx: out std_logic
   );
end insertion;

architecture str_arch of insertion is
   signal tick: std_logic;
   signal rx_done: std_logic;
   signal ascii_r, ascii_t: std_logic_vector(7 downto 0);
   signal tx_start, tx_done: std_logic;
   signal clr_lec, inc_lec, clr_rec, inc_rec, ld_rec: std_logic;
   signal dec_lec, dec_rec, clr_alc, inc_alc, clr_sec, inc_sec, clr_fec: std_logic;
   signal new_min, mvar_ld, mvr_ld, ler_ld: std_logic;
   signal min_value_addr, min_value, ler_value: std_logic_vector(7 downto 0);
   signal lec_value, rec_value, sec_value, alc_value, fec_value: std_logic_vector(7 downto 0);
   signal ctr_data_mux: std_logic_vector(1 downto 0);
   signal ctr_addr_mux: std_logic_vector(2 downto 0);
   signal addr_ram, data_ram, data_in, data_out: std_logic_vector(7 downto 0);
   signal wr: std_logic;

begin

   baud_gen_unit: entity work.mod_m_counter(arch)
      generic map(M=>DVSR, N=>DVSR_BIT)
      port map(
	  clk=>clk, reset=>reset,
      q=>open, max_tick=>tick
	  );

   uart_rx_unit: entity work.uart_rx(arch)
      generic map(DBIT=>DBIT, SB_TICK=>SB_TICK)
      port map(
	  clk=>clk, reset=>reset, rx=>rx,
      s_tick=>tick, rx_done_tick=>rx_done,
      dout=>ascii_r
	  ); 

   uart_tx_unit: entity work.uart_tx(arch)
      generic map(DBIT=>DBIT, SB_TICK=>SB_TICK)
      port map(
	  clk=>clk, reset=>reset,
      tx_start=>tx_start,
      s_tick=>tick, din=>data_out,
      tx_done_tick=> tx_done, tx=>tx
	  );

   lec_cnt_unit: entity work.xec_cnt(arch)
      generic map(N=>RAM_ADDR_WIDTH)
      port map(
      clk=>clk, reset=>reset,
      clr=>clr_lec, ld=>'0', inc=>inc_lec, dec=>dec_lec,
      d=>(others=>'0'),
      q=>lec_value   
	  );

   rec_cnt_unit: entity work.xec_cnt(arch)
      generic map(N=>RAM_ADDR_WIDTH)
      port map(
      clk=>clk, reset=>reset,
      clr=>clr_rec, ld=>ld_rec, inc=>inc_rec, dec=>dec_rec,
      d=>lec_value,
      q=>rec_value   
	  );

   alc_cnt_unit: entity work.xec_cnt(arch)
      generic map(N=>RAM_ADDR_WIDTH)
      port map(
      clk=>clk, reset=>reset,
      clr=>clr_alc, ld=>'0', dec=>'0', inc=>inc_alc,
      d=>lec_value,
      q=>alc_value   
	  ); 
	  
   sec_cnt_unit: entity work.xec_cnt(arch)
      generic map(N=>RAM_ADDR_WIDTH)
      port map(
      clk=>clk, reset=>reset,
      clr=>clr_sec, ld=>'0', dec=>'0', inc=>inc_sec,
      d=>lec_value,
      q=>sec_value   
	  );
	  
   mvar_unit: entity work.xreg(arch)
      port map(
      clk=>clk, reset=>reset,
      clr=>'0', load=>mvar_ld, 
      d=>rec_value,
      q=>min_value_addr   
	  );
	  
   ram_unit: entity work.xilinx_one_port_ram_sync(arch)
      generic map(ADDR_WIDTH=>RAM_ADDR_WIDTH, DATA_WIDTH=>RAM_DATA_WIDTH)
      port map(
      clk=>clk, wr=>wr,
      addr=>addr_ram,
      din=>data_in, dout=>data_out	  
	  );

   ler_unit: entity work.xreg(arch)
      port map(
      clk=>clk, reset=>reset,
      clr=>'0', load=>ler_ld, 
      d=>data_out,
      q=>ler_value   
	  );

   mvr_unit: entity work.xreg(arch)
      port map(
      clk=>clk, reset=>reset,
      clr=>'0', load=>mvr_ld, 
      d=>data_out,
      q=>min_value   
	  );
 
   ctr_path_unit: entity work.ctr_path(arch)
      port map(
      clk=>clk, reset=>reset,
      clr_lec=>clr_lec, inc_lec=>inc_lec,
      lec_value=>lec_value, 
      clr_rec=>clr_rec, ld_rec=>ld_rec, inc_rec=>inc_rec,
      rx_done=>rx_done, 
      rec_value=>rec_value,
      
      alc_value=>alc_value,
      sec_value=>sec_value,
      fec_value=>fec_value,
      inc_sec=>inc_sec,
      inc_alc=>inc_alc,
      clr_sec=>clr_sec,
      clr_alc=>clr_alc,
      clr_fec=>clr_fec,
      
       
      ascii_r=>ascii_r,
      ld_mvar=>mvar_ld, 
      ctr_addr_mux=>ctr_addr_mux, ctr_data_mux=>ctr_data_mux,
      wr=>wr,
      data_out=>data_out,
      ld_ler=>ler_ld,
      ld_mvr=>mvr_ld,
      new_min=>new_min,
      tx_done=>tx_done, tx_start=>tx_start
	  );
	  
-- glue logic at the top level (two muxes and one magnitude comparator)

	addr_ram <= lec_value when (ctr_addr_mux="000") else 
	            rec_value when (ctr_addr_mux="110") else
	            sec_value when (ctr_addr_mux="101") else
	            alc_value when (ctr_addr_mux="011") else
	            fec_value when (ctr_addr_mux="100") else
	            min_value_addr;
	data_in <=  ascii_r when (ctr_data_mux="00") else
	            min_value when (ctr_data_mux="01") else
	            ler_value;  
	new_min <= '1' when unsigned(min_value) > unsigned(data_out) else '0';
			   
end str_arch;