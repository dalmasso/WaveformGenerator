------------------------------------------------------------------------
-- Engineer:    Dalmasso Loic
-- Create Date: 30/01/2025
-- Module Name: WaveformGenerator
-- Description:
--      Simple ROM-based Waveform Generator Module handling Sine, Triangle, Sawtooth and Square waveform according to selector signal.
--      The Waveform Output Frequency is defined by (i_sys_clock_freq / 2^rom_addr_bits).
--
-- Generics
--		rom_addr_bits: ROM Address Bits length
--		rom_data_bits: ROM Data Bits length
-- Ports
--		Input 	-	i_clock: System Input Clock
--		Input 	-	i_waveform_select: Waveform Generator Type Selector ("00": Sine, "01": Triangle, "10": Sawtooth, "11": Square)
--		Input 	-	i_waveform_step: Waveform Step Value (Value Range: [0;2^rom_addr_bits -1])
--		Output 	-	o_waveform: Waveform Signal Ouput Value (Value Range: [0;2^rom_data_bits -1])
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity Testbench_WaveformGenerator is
end Testbench_WaveformGenerator;

architecture Behavioral of Testbench_WaveformGenerator is

COMPONENT WaveformGenerator is

GENERIC(
	rom_addr_bits: INTEGER range 1 to 30 := 8;
	rom_data_bits: INTEGER range 1 to 31 := 8
);

PORT(
	i_sys_clock: IN STD_LOGIC;
    i_waveform_select: IN STD_LOGIC_VECTOR(1 downto 0);
    i_waveform_step: IN UNSIGNED(rom_addr_bits-1 downto 0);
	o_waveform: OUT UNSIGNED(rom_data_bits-1 downto 0)
);

END COMPONENT;

signal clock: STD_LOGIC := '0';
signal waveform_select: STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
signal waveform_step: UNSIGNED(8-1 downto 0) := (others => '0');
signal waveform: UNSIGNED(8-1 downto 0) := (others => '0');

begin

-- Clock 100 MHz
clock <= not(clock) after 5 ns;

-- Waveform Select
waveform_select <= "00", "01" after 615 ns, "10" after 6.86 us, "11" after 14.2 us;

-- Waveform Step Increment
process(clock)
begin
    if rising_edge(clock) then
        waveform_step <= waveform_step +1;
    end if;
end process;

uut: WaveformGenerator
    GENERIC map(
        rom_addr_bits => 8,
        rom_data_bits => 8
    )
    PORT map(
        i_sys_clock => clock,
        i_waveform_select=> waveform_select,
        i_waveform_step => waveform_step,
        o_waveform => waveform);

end Behavioral;