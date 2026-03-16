library ieee;
use ieee.std_logic_1164.all;

entity register_file_32bit is
    port (
        GClock       : in  std_logic;
        GReset       : in  std_logic;
        reg_write    : in  std_logic;                      -- RegWrite control signal
        read_reg1    : in  std_logic_vector(2 downto 0);   -- rs address
        read_reg2    : in  std_logic_vector(2 downto 0);   -- rt address
        write_reg    : in  std_logic_vector(2 downto 0);   -- destination register
        write_data   : in  std_logic_vector(31 downto 0);  -- data to write
        read_data1   : out std_logic_vector(31 downto 0);  -- rs value
        read_data2   : out std_logic_vector(31 downto 0)   -- rt value
    );
end entity register_file_32bit;

architecture structural of register_file_32bit is

    component reg_32bit is
        port (
            GClock      : in  std_logic;
            GReset      : in  std_logic;
            data_in     : in  std_logic_vector(31 downto 0);
            load_enable : in  std_logic;
            data_out    : out std_logic_vector(31 downto 0)
        );
    end component;

    component decoder_3to8 is
        port (
            i_sel : in  std_logic_vector(2 downto 0);
            o_out : out std_logic_vector(7 downto 0)
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

    -- Decoded write enable lines (one per register)
    signal dec_out : std_logic_vector(7 downto 0);

    -- Per-register write enable = decoder output AND reg_write
    -- we(0) is permanently '0' — $0 is hardwired to zero
    signal we : std_logic_vector(7 downto 0);

    -- Register outputs
    type reg_array_t is array(0 to 7) of std_logic_vector(31 downto 0);
    signal reg_out : reg_array_t;

begin

    -- $0 is hardwired to zero — no register instantiated
    reg_out(0) <= (others => '0');

    -- Decode write address into 8 one-hot write enable lines
    write_decoder: decoder_3to8
        port map (
            i_sel => write_reg,
            o_out => dec_out
        );

    -- Gate each decoded line with the global RegWrite signal
    -- $0 write is permanently blocked
    we(0) <= '0';
    gen_we: for i in 1 to 7 generate
        we(i) <= dec_out(i) and reg_write;
    end generate gen_we;

    -- Instantiate registers $1 to $7
    gen_regs: for i in 1 to 7 generate
        reg_i: reg_32bit
            port map (
                GClock      => GClock,
                GReset      => GReset,
                data_in     => write_data,
                load_enable => we(i),
                data_out    => reg_out(i)
            );
    end generate gen_regs;

    -- Read port 1 (rs): selects from all 8 registers
    read_mux1: mux_8to1_32bit
        port map (
            sel_line  => read_reg1,
            data_in_0 => reg_out(0),
            data_in_1 => reg_out(1),
            data_in_2 => reg_out(2),
            data_in_3 => reg_out(3),
            data_in_4 => reg_out(4),
            data_in_5 => reg_out(5),
            data_in_6 => reg_out(6),
            data_in_7 => reg_out(7),
            data_out  => read_data1
        );

    -- Read port 2 (rt): selects from all 8 registers
    read_mux2: mux_8to1_32bit
        port map (
            sel_line  => read_reg2,
            data_in_0 => reg_out(0),
            data_in_1 => reg_out(1),
            data_in_2 => reg_out(2),
            data_in_3 => reg_out(3),
            data_in_4 => reg_out(4),
            data_in_5 => reg_out(5),
            data_in_6 => reg_out(6),
            data_in_7 => reg_out(7),
            data_out  => read_data2
        );

end architecture structural;