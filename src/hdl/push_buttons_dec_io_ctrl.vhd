
----------------------------------------------------------------------------------
-- Logicko projektovanje racunarskih sistema 1
-- 2020
--
-- Input/Output controler for RGB matrix
--
-- authors:
-- Milos Subotic (milos.subotic@uns.ac.rs)
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library work;

entity push_buttons_dec_io_ctrl is
	generic(
		constant CLK_FREQ         : positive
	);
	port(
		iCLK       : in  std_logic;
		inRST      : in  std_logic;
		iPB_UP     : in  std_logic;
		iPB_DOWN   : in  std_logic;
		iPB_LEFT   : in  std_logic;
		iPB_RIGHT  : in  std_logic;
		iPB_CENTER : in  std_logic;
		iBUS_A     : in  std_logic_vector(7 downto 0);
		oBUS_RD    : out std_logic_vector(15 downto 0);
		iBUS_WD    : in  std_logic_vector(15 downto 0);
		iBUS_WE    : in  std_logic
	);
end entity push_buttons_dec_io_ctrl;

architecture Behavioral of push_buttons_dec_io_ctrl is

	type tDIR is (NONE, UP, DOWN, LEFT, RIGHT);
	signal sDIR : tDIR;
	
	signal sMOVE_X : std_logic_vector(15 downto 0);
	signal sMOVE_Y : std_logic_vector(15 downto 0);
	
	signal tc_sec : std_logic;
	
	signal sPB_CENTER : std_logic;
begin
	
	
	
	
	process(iBUS_A, sMOVE_X, sMOVE_Y, sPB_CENTER)
	begin
		case iBUS_A is
			when x"00" =>
				oBUS_RD <= sMOVE_X;
			when x"01" =>
				oBUS_RD <= sMOVE_Y;
			when x"02" =>
				oBUS_RD <= "000000000000000" & sPB_CENTER;
			when others =>
				oBUS_RD <= (others => '0');
		end case;
	end process;
	
	
	
	
	process (iCLK, inRST)
	begin
		if (inRST = '0') then
			sPB_CENTER <= '0';
		elsif (rising_edge(iCLK)) then
			if (iPB_CENTER = '1') then
				sPB_CENTER <= '1';
			end if;
			
			if (iBUS_A = x"03" and iBUS_WE = '1') then
				sPB_CENTER <= '0';
			end if;
		end if;
	end process;
	
	process(iCLK, inRST)
	begin
		if inRST = '0' then
			sDIR <= NONE;
		elsif rising_edge(iCLK) then
			if iPB_UP = '1' then
				sDIR <= UP;
			elsif iPB_DOWN = '1' then
				sDIR <= DOWN;
			elsif iPB_LEFT = '1' then
				sDIR <= LEFT;
			elsif iPB_RIGHT = '1' then
				sDIR <= RIGHT;
			elsif tc_sec = '1' then
				sDIR <= NONE;
			end if;
		end if;
	end process;
	
	count_secs: entity work.counter
	generic map(
		CNT_MOD  => CLK_FREQ,
		CNT_BITS => 24
	)
	port map(
		i_clk  => iCLK,
		in_rst => inRST,
		
		i_rst  => '0',
		i_en   => '1',
		o_cnt  => open,
		o_tc   => tc_sec
	);
	
	process(sDIR)
	begin
		case sDIR is
			when NONE =>
				sMOVE_X <= conv_std_logic_vector( 0, 16);
				sMOVE_Y <= conv_std_logic_vector( 0, 16);
			when UP =>
				sMOVE_X <= conv_std_logic_vector( 0, 16);
				sMOVE_Y <= conv_std_logic_vector(-1, 16);
			when DOWN =>
				sMOVE_X <= conv_std_logic_vector( 0, 16);
				sMOVE_Y <= conv_std_logic_vector( 1, 16);
			when LEFT =>
				sMOVE_X <= conv_std_logic_vector(-1, 16);
				sMOVE_Y <= conv_std_logic_vector( 0, 16);
			when RIGHT =>
				sMOVE_X <= conv_std_logic_vector( 1, 16);
				sMOVE_Y <= conv_std_logic_vector( 0, 16);
		end case;
	end process;
	
	
end architecture;
