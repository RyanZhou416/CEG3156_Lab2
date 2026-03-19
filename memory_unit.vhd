library ieee;
use ieee.std_logic_1164.all;

entity memory_unit is
    port (
        i_clock      : in  std_logic;
        i_alu_result : in  std_logic_vector(7 downto 0);
        i_write_data : in  std_logic_vector(7 downto 0);
        i_mem_write  : in  std_logic;
        i_mem_to_reg : in  std_logic;
        o_write_back : out std_logic_vector(7 downto 0)
    );
end entity memory_unit;

architecture structural of memory_unit is

    component ram32 is
        port (
            clock     : in  std_logic;
            data      : in  std_logic_vector(31 downto 0);
            rdaddress : in  std_logic_vector(7 downto 0);
            wraddress : in  std_logic_vector(7 downto 0);
            wren      : in  std_logic;
            q         : out std_logic_vector(31 downto 0)
        );
    end component;

    component mux_2to1_8bit is
        port (
            data_in_0 : in  std_logic_vector(7 downto 0);
            data_in_1 : in  std_logic_vector(7 downto 0);
            sel_line  : in  std_logic;
            data_out  : out std_logic_vector(7 downto 0)
        );
    end component;

    signal mem_data_out : std_logic_vector(31 downto 0);
    signal data_in_32   : std_logic_vector(31 downto 0);

begin

    data_in_32 <= x"000000" & i_write_data;

    data_mem: ram32
        port map (
            clock     => i_clock,
            data      => data_in_32,
            rdaddress => i_alu_result,
            wraddress => i_alu_result,
            wren      => i_mem_write,
            q         => mem_data_out
        );

    mem_to_reg_mux: mux_2to1_8bit
        port map (
            data_in_0 => i_alu_result,
            data_in_1 => mem_data_out(7 downto 0),
            sel_line  => i_mem_to_reg,
            data_out  => o_write_back
        );

end architecture structural;
