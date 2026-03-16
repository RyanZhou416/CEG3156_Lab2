library ieee;
use ieee.std_logic_1164.all;

entity decoder_3to8 is
    port (
        i_sel : in  std_logic_vector(2 downto 0);
        o_out : out std_logic_vector(7 downto 0)
    );
end entity decoder_3to8;

architecture gate_logic of decoder_3to8 is

    signal a    : std_logic;  -- i_sel(2)
    signal b    : std_logic;  -- i_sel(1)
    signal c    : std_logic;  -- i_sel(0)
    signal na   : std_logic;  -- NOT i_sel(2)
    signal nb   : std_logic;  -- NOT i_sel(1)
    signal nc   : std_logic;  -- NOT i_sel(0)

begin

    a  <= i_sel(2);
    b  <= i_sel(1);
    c  <= i_sel(0);

    na <= not a;
    nb <= not b;
    nc <= not c;

    -- Each output is a minterm of the 3-bit input
    o_out(0) <= na and nb and nc;   -- 000
    o_out(1) <= na and nb and c;    -- 001
    o_out(2) <= na and b  and nc;   -- 010
    o_out(3) <= na and b  and c;    -- 011
    o_out(4) <= a  and nb and nc;   -- 100
    o_out(5) <= a  and nb and c;    -- 101
    o_out(6) <= a  and b  and nc;   -- 110
    o_out(7) <= a  and b  and c;    -- 111

end architecture gate_logic;