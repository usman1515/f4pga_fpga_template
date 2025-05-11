----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Design Name:
-- Module Name: counter_seven_segment_display - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions: 2021.2
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity counter_seven_segment_display is
    port (
        clk : in std_logic;         -- system clk (100MHz)
        rst_n : in std_logic;       -- reset
        o_anode_sel : out std_logic_vector(3 downto 0);     -- anode select
        o_seven_segment : out std_logic_vector(6 downto 0)  -- 7 segemtn output
    );
end entity counter_seven_segment_display;

architecture rtl of counter_seven_segment_display is

    -- signals
    signal counter_one_sec : unsigned(26 downto 0) := (others => '0');  -- counter for generating 1 sec clk enable
    signal en_one_sec : std_logic := '0';   -- one sec enable for counting numbers
    signal led_bcd : unsigned(3 downto 0) := (others => '0');
    signal select_anode : std_logic_vector(1 downto 0) := (others => '0');
    signal num_displayed : unsigned(15 downto 0) := (others => '0');
    signal refresh_counter : unsigned(19 downto 0) := (others => '0');

begin

    -- one second counter
    one_sec_counter : process(clk)
    begin
        if rising_edge(clk) then
            if rst_n = '1' then
                counter_one_sec <= (others => '0');
            else
                if counter_one_sec <= to_unsigned(99999999, 27) then
                    counter_one_sec <= counter_one_sec + '1';
                else
                    counter_one_sec <= (others => '0');
                end if;
            end if;
        end if;
    end process one_sec_counter;

    en_one_sec <= '1' when (counter_one_sec = to_unsigned(99999999, 27)) else '0';

    -- increment number after every 1 sec
    inc_count : process(clk)
    begin
        if rising_edge(clk) then
            if rst_n = '1' then
                num_displayed <= (others => '0');
            elsif en_one_sec = '1' then
                num_displayed <= num_displayed + '1';
            end if;
        end if;
    end process inc_count ;

    -- the first 18-bit for creating 2.6ms digit period
    -- the other 2-bit for creating 4 LED-activating signals
    refresh_cntr : process(clk)
    begin
        if rising_edge(clk) then
            if rst_n = '1' then
                refresh_counter <= (others => '0');
            else
                refresh_counter <= refresh_counter + '1';
            end if;
        end if;
    end process refresh_cntr;

    select_anode <= std_logic_vector(refresh_counter(19 downto 18));

    -- decoder to generate anode signals
    sig_anode : process(all)
    begin
        case select_anode is
            when "00" =>
                o_anode_sel <= "0111";
                -- activate LED1 and Deactivate LED2, LED3, LED4
                led_bcd <= resize(num_displayed / 1000, 4);
                -- the first digit of the 16-bit number
            when "01" =>
                o_anode_sel <= "1011";
                -- activate LED2 and Deactivate LED1, LED3, LED4
                led_bcd <= resize((num_displayed mod 1000) / 100, 4);
                -- the second digit of the 16-bit number
            when "10" =>
                o_anode_sel <= "1101";
                -- activate LED3 and Deactivate LED2, LED1, LED4
                led_bcd <= resize(((num_displayed mod 1000) mod 100) / 10, 4);
                -- the third digit of the 16-bit number
            when others =>
                o_anode_sel <= "1110";
                -- activate LED4 and Deactivate LED2, LED3, LED1
                led_bcd <= resize(((num_displayed mod 1000) mod 100) mod 10, 4);
                -- the fourth digit of the 16-bit number
        end case;
    end process sig_anode;

    -- Cathode patterns of the 7-segment LED display
    display_seven_segment : process(all)
    begin
        case led_bcd is
            when "0000" => o_seven_segment <= "0000001"; -- 0
            when "0001" => o_seven_segment <= "1001111"; -- 1
            when "0010" => o_seven_segment <= "0010010"; -- 2
            when "0011" => o_seven_segment <= "0000110"; -- 3
            when "0100" => o_seven_segment <= "1001100"; -- 4
            when "0101" => o_seven_segment <= "0100100"; -- 5
            when "0110" => o_seven_segment <= "0100000"; -- 6
            when "0111" => o_seven_segment <= "0001111"; -- 7
            when "1000" => o_seven_segment <= "0000000"; -- 8
            when "1001" => o_seven_segment <= "0000100"; -- 9
            when others => o_seven_segment <= "0000001"; -- default: 0
        end case;
    end process display_seven_segment;

end architecture rtl;

