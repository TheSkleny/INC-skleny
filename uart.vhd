-- uart.vhd: UART controller - receiving part
-- Author(s): 
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-------------------------------------------------
entity UART_RX is
port(	
    CLK: 	    in std_logic;
	RST: 	    in std_logic;
	DIN: 	    in std_logic;
	DOUT: 	    out std_logic_vector(7 downto 0);
	DOUT_VLD: 	out std_logic
);
end UART_RX;  

-------------------------------------------------
architecture behavioral of UART_RX is
signal start_cnt : std_logic_vector(2 downto 0):="000";
signal bit_cnt : std_logic_vector(3 downto 0):="0000";
signal stop_cnt : std_logic_vector(3 downto 0):="0000";
signal cnt : std_logic_vector(3 downto 0):="0000";
signal dout_validate : std_logic:='0';
signal counter_start: std_logic := '0';
signal receiving_t   : std_logic := '0';
signal tmp: std_logic_vector(7 downto 0);
begin
	FSM: entity work.UART_FSM(behavioral)
    port map (
        CLK 	         => CLK,
        RST 	         => RST,
        DIN 	         => DIN,
        COUNT       => cnt,
        BIT_COUNT       => bit_cnt,
        STOP_COUNT       => stop_cnt,
        DOUT_VAL        => dout_validate,
		COUNTERS_ON    => counter_start,
		RECEIVING      => receiving_t,
		START_COUNT => start_cnt
    );


	process(CLK) begin
		if rising_edge(CLK) then
			
			DOUT_VLD<=dout_validate;

			if RST = '1' then
				DOUT<="00000000";
			end if;


			if counter_start = '1' then
				start_cnt <= start_cnt + "1";
			else
				start_cnt <= "000";
			end if;

			if start_cnt = "111" then
				cnt <= cnt + "1";
			end if;

			if bit_cnt = "1000" then
				stop_cnt<= stop_cnt + "1";
			end if;

			if stop_cnt = "1111" then
				DOUT_VLD <= '1';
				bit_cnt <= "000";
				stop_cnt <= "000";
			end if;

			if receiving_t = '1' then
				if cnt = "1111" then
					cnt <= "0000";

					tmp <= tmp(6 downto 0) & DIN;


					bit_cnt <= bit_cnt + "1";
				end if;
				if bit_cnt = "1000" then
					DOUT <= tmp;
				end if;
			end if;

		end if;


	end process;
end behavioral;
