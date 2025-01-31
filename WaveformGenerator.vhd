------------------------------------------------------------------------
-- Engineer:    Dalmasso Loic
-- Create Date: 30/01/2025
-- Module Name: WaveformGenerator
-- Description:
--      Simple ROM-based Waveform Generator Module handling Sine, Triangle, Sawtooth and Square waveform according to selector signal.
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
USE IEEE.MATH_REAL.ALL;

ENTITY WaveformGenerator is

GENERIC(
	rom_addr_bits: INTEGER range 1 to 30 := 8;
	rom_data_bits: INTEGER range 1 to 31 := 8
);

PORT(
	i_clock: IN STD_LOGIC;
    i_waveform_select: IN STD_LOGIC_VECTOR(1 downto 0);
    i_waveform_step: IN UNSIGNED(rom_addr_bits-1 downto 0);
	o_waveform: OUT UNSIGNED(rom_data_bits-1 downto 0)
);

END WaveformGenerator;

ARCHITECTURE Behavioral of WaveformGenerator is

------------------------------------------------------------------------
-- Constant Declarations
------------------------------------------------------------------------
-- ROM Type
type rom_type is array(INTEGER range 0 to 2**rom_addr_bits -1) of UNSIGNED(rom_data_bits-1 downto 0);

-- Sine ROM Initialization
function sine_rom_initialization return rom_type is
constant period: real := real((2.0 * MATH_PI) / 2.0**rom_addr_bits);
variable angle: real;
variable rom_angle: real;
variable rom_temp: rom_type;
begin

    for addr in INTEGER range 0 to 2**rom_addr_bits -1 loop
        -- Compute Angle from ROM Address
        angle := real(addr) * period;

        -- Scale ROM Angle
        rom_angle := (1.0 + sin(angle)) * (2.0**rom_data_bits - 1.0) / 2.0;

        -- Convert ROM Angle into UNSIGNED and Add to Memory
        rom_temp(addr) := TO_UNSIGNED(INTEGER(round(rom_angle)), rom_data_bits);
    end loop;
    
    return rom_temp;
end sine_rom_initialization;

-- Triangle ROM Initialization
function triangle_rom_initialization return rom_type is
    constant period: real := real(2**rom_addr_bits);
    variable angle: real;
    variable rom_angle: real;
    variable rom_temp: rom_type;
    begin
    
        for addr in INTEGER range 0 to 2**rom_addr_bits -1 loop
            -- Compute Angle from ROM Address
            angle := 2.0 * abs( (real(addr)/period) - floor( (real(addr)/period) + (1.0/2.0) ) );
    
            -- Scale ROM Angle
            rom_angle := angle * (2.0**rom_data_bits - 1.0);
    
            -- Convert ROM Angle into UNSIGNED and Add to Memory
            rom_temp(addr) := TO_UNSIGNED(INTEGER(round(rom_angle)), rom_data_bits);
        end loop;
        
        return rom_temp;
end triangle_rom_initialization;

-- Sawtooth ROM Initialization
function sawtooth_rom_initialization return rom_type is
    variable rom_angle: real;
    variable rom_temp: rom_type;
    begin
    
        for addr in INTEGER range 0 to 2**rom_addr_bits -1 loop
            -- Compute ROM Angle from ROM Address & Scale it
            rom_angle := round( real(addr) * ((2.0**rom_data_bits -1.0) / (2.0**rom_addr_bits -1.0)) );
    
            -- Convert ROM Angle into UNSIGNED and Add to Memory
            rom_temp(addr) := TO_UNSIGNED(INTEGER(round(rom_angle)), rom_data_bits);
        end loop;

        return rom_temp;
end sawtooth_rom_initialization;

-- ROM Memories
constant SINE_ROM: rom_type := sine_rom_initialization;
constant TRIANGLE_ROM: rom_type := triangle_rom_initialization;
constant SAWTOOTH_ROM: rom_type := sawtooth_rom_initialization;

-- Max ROM Address
constant ROM_ADDR_MAX: UNSIGNED(rom_addr_bits -1 downto 0) := (others => '1');

-- Waveform Types (Sine, Triangle, Sawtooth and Square)
constant SINE_WAVEFORM: STD_LOGIC_VECTOR(1 downto 0) := "00";
constant TRIANGLE_WAVEFORM: STD_LOGIC_VECTOR(1 downto 0) := "01";
constant SAWTOOTH_WAVEFORM: STD_LOGIC_VECTOR(1 downto 0) := "10";

------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------
-- Waveform Selector Register
signal waveform_select_reg: STD_LOGIC_VECTOR(1 downto 0) := (others => '0');

-- Waveform Output Register
signal waveform_output_reg: UNSIGNED(rom_data_bits-1 downto 0) := (others => '0');

------------------------------------------------------------------------
-- Module Implementation
------------------------------------------------------------------------
begin

	-------------------------------------
	-- Waveform Selector Input Handler --
	-------------------------------------
	process(i_clock)
	begin
		if rising_edge(i_clock) then

			-- End of ROM Memory
			if (i_waveform_step = ROM_ADDR_MAX) then
				waveform_select_reg <= i_waveform_select;
			end if;
		end if;
	end process;

    -----------------------
	-- Waveform Selector --
	-----------------------
	process(i_clock)
	begin
		if rising_edge(i_clock) then

            -- Waveform 0: Sine
            if (waveform_select_reg = SINE_WAVEFORM) then
                waveform_output_reg <= SINE_ROM(TO_INTEGER(i_waveform_step));

            -- Waveform 1: Triangle
            elsif (waveform_select_reg = TRIANGLE_WAVEFORM) then
                waveform_output_reg <= TRIANGLE_ROM(TO_INTEGER(i_waveform_step));

            -- Waveform 2: Sawtooth
            elsif (waveform_select_reg = SAWTOOTH_WAVEFORM) then
                waveform_output_reg <= SAWTOOTH_ROM(TO_INTEGER(i_waveform_step));

            -- Waveform 3: Square
            else
                -- Maximum Value
                if (i_waveform_step <= ROM_ADDR_MAX/2) then
                    waveform_output_reg <= (others => '1');
                
                -- Minimum Value
                else
                    waveform_output_reg <= (others => '0');
                end if;
            end if;
		end if;
	end process;
    o_waveform <= waveform_output_reg;

end Behavioral;