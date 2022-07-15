-- uart_fsm.vhd: UART controller - finite state machine
-- Author(s): 
--
library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------
entity UART_FSM is
port(
   CLK : in std_logic;
   RST : in std_logic;
   DIN : in std_logic;
   START_COUNT : in std_logic_vector(2 downto 0);
   BIT_COUNT : in std_logic_vector(3 downto 0);
   STOP_COUNT : in std_logic_vector(3 downto 0);
   COUNT : in std_logic_vector(3 downto 0);
   DOUT_VAL : out std_logic;
   COUNTERS_ON : out std_logic;
   RECEIVING   : out std_logic
   );
end entity UART_FSM;

-------------------------------------------------
architecture behavioral of UART_FSM is
type STATE_TYPE is (WAIT_STATE, START_BIT, VAL_START_BIT, DATA, STOP_BIT, VAL_STOP_BIT, OUTPUT_STATE);
signal state : STATE_TYPE := WAIT_STATE;
begin

   DOUT_VAL <= '1' when state = OUTPUT_STATE
   else '0';
   COUNTERS_ON <= '1' when state = START_BIT or state = DATA 
   else '0';
   RECEIVING <= '1' when state = DATA 
   else '0';

   process(CLK) begin
      if rising_edge(CLK) then
         if RST = '1' then
            state <= WAIT_STATE;
         else
            case state is
               when WAIT_STATE =>      if DIN = '0' then
                                          state <= START_BIT;
                                       end if;
               when START_BIT =>       if START_COUNT = "111" then --tady bude mozna problem ze me to posune o jeden hodinovej cyklus mimo, to kdyztak budu porovnavat s 110
                                          state <= VAL_START_BIT;
                                       end if;
               when VAL_START_BIT =>   if DIN = '0' then --spojenej problem se stavem START_BIT
                                          state <= DATA;
                                       else
                                          state <= WAIT_STATE;
                                       end if;
               when DATA =>            if BIT_COUNT = "111" then --tady mozna 1000 misto sedm, uvidim
                                          state <= STOP_BIT;
                                       end if;
               when STOP_BIT =>        if STOP_COUNT = "1111" then --tady porovnavat s 1110, viz nize
                                          state <= VAL_STOP_BIT;
                                       end if;
               when VAL_STOP_BIT =>    if DIN = '1' then --mozna taky problem s posunutim offsetu o jeden cas, uvidim v simulaci kdyztak klasicky porovnavat s 1110 i guess
                                          state <= OUTPUT_STATE;
                                       else
                                          state <= WAIT_STATE;
                                       end if;
               when OUTPUT_STATE =>    state <= WAIT_STATE;
               when others => null;
            end case;
         end if;
      end if;
   end process;
         
end behavioral;
