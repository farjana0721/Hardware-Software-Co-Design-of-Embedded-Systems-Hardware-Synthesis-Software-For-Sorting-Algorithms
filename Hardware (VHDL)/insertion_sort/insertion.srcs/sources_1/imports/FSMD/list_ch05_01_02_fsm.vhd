-- (adapted from) Listing 5.1

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity ctr_path is
   generic(
      N: integer := 13;     -- size of array
      M: integer := 8       -- size of RAM address bus   
   );
   port(
      clk, reset: in std_logic;
      rx_done, tx_done, new_min: in std_logic;
	  ascii_r, data_out: in std_logic_vector(7 downto 0);
	  rec_value, lec_value, alc_value, fec_value, sec_value: in std_logic_vector(M-1 downto 0);
	  
      tx_start, ld_mvar, ld_ler, ld_mvr, clr_lec, inc_lec, dec_lec: out std_logic;
      clr_rec, inc_rec, dec_rec, ld_rec, wr: out std_logic;
      
      --alc = array length counter
      --fec = first element counter
      --sec = sorted element counter
      
      clr_sec, inc_sec, clr_fec, clr_alc, inc_alc: out std_logic; 
      ctr_data_mux: out std_logic_vector(1 downto 0);
      ctr_addr_mux: out std_logic_vector(2 downto 0)
      
   );
end ctr_path;

architecture arch of ctr_path is
   type state_type is (S0, S1, S2, S3, S4, S5a, S5b, S6a, S6b,  S7, S8, S9, S10, S11, S12);
   signal state_reg, state_nxt: state_type;
   
begin

   -- state register
   process(clk,reset)
   begin
      
      if (reset='1') then
         state_reg <= s0;
      elsif rising_edge(clk) then
         state_reg <= state_nxt;
      end if;
   end process;
   
   -- next-state and outputs logic
   process(state_reg, rx_done, tx_done, ascii_r, data_out, new_min, lec_value, rec_value, alc_value, fec_value, sec_value)
   begin
   clr_lec <= '0';
   inc_lec <= '0';
   dec_lec <= '0';
   clr_rec <= '0';
   inc_rec <= '0';
   dec_rec <= '0';
   ld_rec <= '0';
   
   clr_sec <= '0';
   inc_sec <= '0';
   clr_fec <= '0';
   clr_alc <= '0';
   inc_alc <= '0';
   
   ld_mvar <= '0';
   ld_mvr <= '0';
   ld_ler <= '0';
   wr <= '0';
   tx_start <= '0';
   ctr_addr_mux <= "000"; -- 000: bottom (lec)
   ctr_data_mux <= "00"; -- 00: bottom (UART R); 01 or 10: middle (mvr); 11: top (data_out)
   state_nxt <= state_reg;
   
      case state_reg is
         when s0 =>
            clr_lec <= '1';
			clr_rec <= '1';
			clr_sec <= '1';
			clr_fec <= '1';
			clr_alc <= '1';
            state_nxt <= s1;
            
         when S1 =>
                                  -- sel addr from left elements cnt, data from UART R (muxs ctr = "00")
            if (rx_done='1') then
               wr <= '1';
 			   if (ascii_r=x"0D") then  -- Enter key?
				   clr_lec <= '1';
				   state_nxt <= S2;
			   else
			       inc_lec <= '1';
			       inc_alc <= '1';
 			   end if;
			end if;
			
         when S2 =>
                                  -- sel addr from left elements cnt
            ld_rec <= '1';
            ld_mvr <= '1';
            state_nxt <= S3;

		 when S3 =>
		    ld_mvar <= '1';
            state_nxt <= S4;

         when S4 =>
                                -- set sec, fec
            inc_rec <= '1';
            state_nxt <= S5a;

		 when S5a =>  
		    ctr_addr_mux <= "110"; 
		    state_nxt <= S5b;
		    
		 when S5b =>   
		    if (new_min = '1') then
		        ld_ler <= '1';
		        state_nxt<=S7;
		    else
		        state_nxt<=S6a; 
		    end if;
		    
		 when S6a =>
             inc_rec <= '1';
		     inc_lec <= '1';
		     inc_sec <= '1';
		     state_nxt<=S6b;
		     
         when S6b =>
             if (sec_value = alc_value) then
		          state_nxt <= S11;
		     else
		          state_nxt <= S5b;
		     end if;   
		      
		           
         when S7 =>
                                     
            ctr_addr_mux <= "001"; 
		    ctr_data_mux <= "10"; 
		    wr <= '1';
		    state_nxt <= S8;

		 when S8 =>
		    ctr_addr_mux <= "000";
		    ctr_data_mux <= "01"; 
		    wr <= '1';
		    state_nxt <= S9;
		    
         when S9 =>
            ctr_addr_mux <= "100";                      
		    if (lec_value=fec_value) then
		        inc_sec <= '1';
		        state_nxt <= S10;
		    else
		        dec_lec <= '1';
		        dec_rec <= '1';
		        state_nxt <= S5b;  		    
		    end if;

		 when S10 =>
	        if (sec_value = alc_value) then
	             state_nxt <= S11;
	        else
	             --lec_value <= lec_value + (sec_value - 1);
	             --rec_value <= rec_value + (sec_value - 1);
	             state_nxt <= S5b;
	        end if;

		 when S11 =>
		    ctr_addr_mux <= "000";                      
		    if (data_out=x"0D") then
                 state_nxt <= S0;
             else
                 tx_start <= '1';
                 state_nxt <= S12;
             end if;
 
		 when S12 =>
             ctr_addr_mux <= "000";                    
             if (tx_done='1') then
                 inc_lec <= '1';
                 state_nxt <= S11;
             else
                state_nxt <= S12;
             end if;
                 
      end case;
   end process;

end arch;