library ieee;
use ieee.std_logic_1164.all;

entity decode_unit is
    port (
        i_instruction : in  std_logic_vector(31 downto 0);
        o_rs          : out std_logic_vector(2 downto 0);
        o_rt          : out std_logic_vector(2 downto 0);
        o_write_reg   : out std_logic_vector(2 downto 0);
        o_funct       : out std_logic_vector(5 downto 0);
        o_imm16       : out std_logic_vector(15 downto 0);
        o_jump_addr   : out std_logic_vector(7 downto 0);
        o_reg_dst     : out std_logic;
        o_alu_src     : out std_logic;
        o_mem_to_reg  : out std_logic;
        o_reg_write   : out std_logic;
        o_mem_read    : out std_logic;
        o_mem_write   : out std_logic;
        o_branch      : out std_logic;
        o_jump        : out std_logic;
        o_alu_op      : out std_logic_vector(1 downto 0)
    );
end entity decode_unit;

architecture structural of decode_unit is

    component instruction_decoder is
        port (
            i_instruction : in  std_logic_vector(31 downto 0);
            o_opcode      : out std_logic_vector(5 downto 0);
            o_rs          : out std_logic_vector(2 downto 0);
            o_rt          : out std_logic_vector(2 downto 0);
            o_rd          : out std_logic_vector(2 downto 0);
            o_funct       : out std_logic_vector(5 downto 0);
            o_imm16       : out std_logic_vector(15 downto 0);
            o_jump_addr   : out std_logic_vector(7 downto 0)
        );
    end component;

    component control_unit is
        port (
            i_opcode     : in  std_logic_vector(5 downto 0);
            o_reg_dst    : out std_logic;
            o_alu_src    : out std_logic;
            o_mem_to_reg : out std_logic;
            o_reg_write  : out std_logic;
            o_mem_read   : out std_logic;
            o_mem_write  : out std_logic;
            o_branch     : out std_logic;
            o_jump       : out std_logic;
            o_alu_op     : out std_logic_vector(1 downto 0)
        );
    end component;

    component mux_2to1_3bit is
        port (
            data_in_0 : in  std_logic_vector(2 downto 0);
            data_in_1 : in  std_logic_vector(2 downto 0);
            sel_line  : in  std_logic;
            data_out  : out std_logic_vector(2 downto 0)
        );
    end component;

    signal opcode  : std_logic_vector(5 downto 0);
    signal rt_int  : std_logic_vector(2 downto 0);
    signal rd_int  : std_logic_vector(2 downto 0);
    signal reg_dst : std_logic;

begin

    dec: instruction_decoder
        port map (
            i_instruction => i_instruction,
            o_opcode      => opcode,
            o_rs          => o_rs,
            o_rt          => rt_int,
            o_rd          => rd_int,
            o_funct       => o_funct,
            o_imm16       => o_imm16,
            o_jump_addr   => o_jump_addr
        );

    o_rt <= rt_int;

    ctrl: control_unit
        port map (
            i_opcode     => opcode,
            o_reg_dst    => reg_dst,
            o_alu_src    => o_alu_src,
            o_mem_to_reg => o_mem_to_reg,
            o_reg_write  => o_reg_write,
            o_mem_read   => o_mem_read,
            o_mem_write  => o_mem_write,
            o_branch     => o_branch,
            o_jump       => o_jump,
            o_alu_op     => o_alu_op
        );

    o_reg_dst <= reg_dst;

    reg_dst_mux: mux_2to1_3bit
        port map (
            data_in_0 => rt_int,
            data_in_1 => rd_int,
            sel_line  => reg_dst,
            data_out  => o_write_reg
        );

end architecture structural;
