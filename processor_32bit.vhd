library ieee;
use ieee.std_logic_1164.all;

entity processor_32bit is
    port (
        GClock         : in  std_logic;
        GReset         : in  std_logic;
        ValueSelect    : in  std_logic_vector(2 downto 0);
        MuxOut         : out std_logic_vector(31 downto 0);
        InstructionOut : out std_logic_vector(31 downto 0);
        BranchOut      : out std_logic;
        ZeroOut        : out std_logic;
        MemWriteOut    : out std_logic;
        RegWriteOut    : out std_logic
    );
end entity processor_32bit;

architecture structural of processor_32bit is

    component rom32 is
        port (
            address : in  std_logic_vector(7 downto 0);
            clock   : in  std_logic;
            q       : out std_logic_vector(31 downto 0)
        );
    end component;

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

    component control_unit_32bit is
        port (
            i_opcode     : in  std_logic_vector(5 downto 0);
            o_reg_dst    : out std_logic;
            o_alu_src    : out std_logic;
            o_mem_to_reg : out std_logic;
            o_reg_write  : out std_logic;
            o_mem_read   : out std_logic;
            o_mem_write  : out std_logic;
            o_branch     : out std_logic;
            o_bne        : out std_logic;
            o_jump       : out std_logic;
            o_alu_op     : out std_logic_vector(1 downto 0)
        );
    end component;

    component fetch_unit_32bit is
        port (
            GClock         : in  std_logic;
            GReset         : in  std_logic;
            i_branch       : in  std_logic;
            i_bne          : in  std_logic;
            i_zero         : in  std_logic;
            i_jump         : in  std_logic;
            i_imm16        : in  std_logic_vector(15 downto 0);
            i_jump_addr    : in  std_logic_vector(7 downto 0);
            o_pc           : out std_logic_vector(7 downto 0);
            o_sign_ext_imm : out std_logic_vector(31 downto 0)
        );
    end component;

    component register_file_32bit is
        port (
            GClock     : in  std_logic;
            GReset     : in  std_logic;
            reg_write  : in  std_logic;
            read_reg1  : in  std_logic_vector(2 downto 0);
            read_reg2  : in  std_logic_vector(2 downto 0);
            write_reg  : in  std_logic_vector(2 downto 0);
            write_data : in  std_logic_vector(31 downto 0);
            read_data1 : out std_logic_vector(31 downto 0);
            read_data2 : out std_logic_vector(31 downto 0)
        );
    end component;

    component alu_module_32bit is
        port (
            i_alu_op   : in  std_logic_vector(1 downto 0);
            i_funct    : in  std_logic_vector(5 downto 0);
            i_a        : in  std_logic_vector(31 downto 0);
            i_b        : in  std_logic_vector(31 downto 0);
            o_result   : out std_logic_vector(31 downto 0);
            o_zero     : out std_logic;
            o_overflow : out std_logic
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

    component mux_2to1_32bit is
        port (
            data_in_0 : in  std_logic_vector(31 downto 0);
            data_in_1 : in  std_logic_vector(31 downto 0);
            sel_line  : in  std_logic;
            data_out  : out std_logic_vector(31 downto 0)
        );
    end component;

    component mux_8to1_32bit is
        port (
            sel_line  : in  std_logic_vector(2 downto 0);
            data_in_0 : in  std_logic_vector(31 downto 0);
            data_in_1 : in  std_logic_vector(31 downto 0);
            data_in_2 : in  std_logic_vector(31 downto 0);
            data_in_3 : in  std_logic_vector(31 downto 0);
            data_in_4 : in  std_logic_vector(31 downto 0);
            data_in_5 : in  std_logic_vector(31 downto 0);
            data_in_6 : in  std_logic_vector(31 downto 0);
            data_in_7 : in  std_logic_vector(31 downto 0);
            data_out  : out std_logic_vector(31 downto 0)
        );
    end component;

    signal instruction    : std_logic_vector(31 downto 0);
    signal opcode         : std_logic_vector(5 downto 0);
    signal rs, rt, rd     : std_logic_vector(2 downto 0);
    signal funct          : std_logic_vector(5 downto 0);
    signal imm16          : std_logic_vector(15 downto 0);
    signal jump_addr      : std_logic_vector(7 downto 0);

    signal reg_dst        : std_logic;
    signal alu_src        : std_logic;
    signal mem_to_reg     : std_logic;
    signal reg_write      : std_logic;
    signal mem_read       : std_logic;
    signal mem_write      : std_logic;
    signal branch         : std_logic;
    signal bne            : std_logic;
    signal jump           : std_logic;
    signal alu_op         : std_logic_vector(1 downto 0);

    signal pc_out         : std_logic_vector(7 downto 0);
    signal sign_ext_imm   : std_logic_vector(31 downto 0);
    signal write_reg_addr : std_logic_vector(2 downto 0);
    signal read_data1     : std_logic_vector(31 downto 0);
    signal read_data2     : std_logic_vector(31 downto 0);
    signal alu_input_b    : std_logic_vector(31 downto 0);
    signal alu_result     : std_logic_vector(31 downto 0);
    signal zero_flag      : std_logic;
    signal mem_data_out   : std_logic_vector(31 downto 0);
    signal write_back     : std_logic_vector(31 downto 0);
    signal pc_out_32      : std_logic_vector(31 downto 0);
    signal ctrl_byte_32   : std_logic_vector(31 downto 0);

begin

    pc_out_32    <= x"000000" & pc_out;
    ctrl_byte_32 <= x"000000" & "00" & reg_dst & jump & mem_read & mem_to_reg & alu_op(1) & alu_op(0);


    instr_mem: rom32
        port map (
            address => pc_out,
            clock   => GClock,
            q       => instruction
        );

    instr_dec: instruction_decoder
        port map (
            i_instruction => instruction,
            o_opcode      => opcode,
            o_rs          => rs,
            o_rt          => rt,
            o_rd          => rd,
            o_funct       => funct,
            o_imm16       => imm16,
            o_jump_addr   => jump_addr
        );

    ctrl: control_unit_32bit
        port map (
            i_opcode     => opcode,
            o_reg_dst    => reg_dst,
            o_alu_src    => alu_src,
            o_mem_to_reg => mem_to_reg,
            o_reg_write  => reg_write,
            o_mem_read   => mem_read,
            o_mem_write  => mem_write,
            o_branch     => branch,
            o_bne        => bne,
            o_jump       => jump,
            o_alu_op     => alu_op
        );

    fetch: fetch_unit_32bit
        port map (
            GClock         => GClock,
            GReset         => GReset,
            i_branch       => branch,
            i_bne          => bne,
            i_zero         => zero_flag,
            i_jump         => jump,
            i_imm16        => imm16,
            i_jump_addr    => jump_addr,
            o_pc           => pc_out,
            o_sign_ext_imm => sign_ext_imm
        );

    reg_dst_mux: mux_2to1_3bit
        port map (
            data_in_0 => rt,
            data_in_1 => rd,
            sel_line  => reg_dst,
            data_out  => write_reg_addr
        );

    reg_file: register_file_32bit
        port map (
            GClock     => GClock,
            GReset     => GReset,
            reg_write  => reg_write,
            read_reg1  => rs,
            read_reg2  => rt,
            write_reg  => write_reg_addr,
            write_data => write_back,
            read_data1 => read_data1,
            read_data2 => read_data2
        );

    alu_src_mux: mux_2to1_32bit
        port map (
            data_in_0 => read_data2,
            data_in_1 => sign_ext_imm,
            sel_line  => alu_src,
            data_out  => alu_input_b
        );

    alu_mod: alu_module_32bit
        port map (
            i_alu_op   => alu_op,
            i_funct    => funct,
            i_a        => read_data1,
            i_b        => alu_input_b,
            o_result   => alu_result,
            o_zero     => zero_flag,
            o_overflow => open
        );

    data_mem: ram32
        port map (
            clock     => GClock,
            data      => read_data2,
            rdaddress => alu_result(7 downto 0),
            wraddress => alu_result(7 downto 0),
            wren      => mem_write,
            q         => mem_data_out
        );

    mem_to_reg_mux: mux_2to1_32bit
        port map (
            data_in_0 => alu_result,
            data_in_1 => mem_data_out,
            sel_line  => mem_to_reg,
            data_out  => write_back
        );

    obs_mux: mux_8to1_32bit
        port map (
            sel_line  => ValueSelect,
            data_in_0 => pc_out_32,
            data_in_1 => alu_result,
            data_in_2 => read_data1,
            data_in_3 => read_data2,
            data_in_4 => write_back,
            data_in_5 => ctrl_byte_32,
            data_in_6 => (others => '0'),
            data_in_7 => (others => '0'),
            data_out  => MuxOut
        );

    InstructionOut <= instruction;
    BranchOut      <= branch;
    ZeroOut        <= zero_flag;
    MemWriteOut    <= mem_write;
    RegWriteOut    <= reg_write;

end architecture structural;
