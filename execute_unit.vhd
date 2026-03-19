library ieee;
use ieee.std_logic_1164.all;

entity execute_unit is
    port (
        i_alu_op       : in  std_logic_vector(1 downto 0);
        i_funct        : in  std_logic_vector(5 downto 0);
        i_alu_src      : in  std_logic;
        i_read_data1   : in  std_logic_vector(7 downto 0);
        i_read_data2   : in  std_logic_vector(7 downto 0);
        i_sign_ext_imm : in  std_logic_vector(7 downto 0);
        o_result       : out std_logic_vector(7 downto 0);
        o_zero         : out std_logic
    );
end entity execute_unit;

architecture structural of execute_unit is

    component mux_2to1_8bit is
        port (
            data_in_0 : in  std_logic_vector(7 downto 0);
            data_in_1 : in  std_logic_vector(7 downto 0);
            sel_line  : in  std_logic;
            data_out  : out std_logic_vector(7 downto 0)
        );
    end component;

    component alu_module is
        port (
            i_alu_op   : in  std_logic_vector(1 downto 0);
            i_funct    : in  std_logic_vector(5 downto 0);
            i_a        : in  std_logic_vector(7 downto 0);
            i_b        : in  std_logic_vector(7 downto 0);
            o_result   : out std_logic_vector(7 downto 0);
            o_zero     : out std_logic;
            o_overflow : out std_logic
        );
    end component;

    signal alu_input_b : std_logic_vector(7 downto 0);

begin

    alu_src_mux: mux_2to1_8bit
        port map (
            data_in_0 => i_read_data2,
            data_in_1 => i_sign_ext_imm,
            sel_line  => i_alu_src,
            data_out  => alu_input_b
        );

    alu_mod: alu_module
        port map (
            i_alu_op   => i_alu_op,
            i_funct    => i_funct,
            i_a        => i_read_data1,
            i_b        => alu_input_b,
            o_result   => o_result,
            o_zero     => o_zero,
            o_overflow => open
        );

end architecture structural;
