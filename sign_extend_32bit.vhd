library ieee;
use ieee.std_logic_1164.all;

entity sign_extend_32bit is
    port (
        i_imm16 : in  std_logic_vector(15 downto 0);
        o_imm32 : out std_logic_vector(31 downto 0)
    );
end entity sign_extend_32bit;

architecture structural of sign_extend_32bit is
begin
    o_imm32(15 downto 0) <= i_imm16;
    gen_sign: for i in 16 to 31 generate
        o_imm32(i) <= i_imm16(15);
    end generate gen_sign;
end architecture structural;
