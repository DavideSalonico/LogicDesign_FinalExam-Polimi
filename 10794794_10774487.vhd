library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity project_reti_logiche is
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_start : in std_logic;
        i_w : in std_logic;
        
        o_z0 : out std_logic_vector(7 downto 0);
        o_z1 : out std_logic_vector(7 downto 0);
        o_z2 : out std_logic_vector(7 downto 0);
        o_z3 : out std_logic_vector(7 downto 0);
        o_done : out std_logic;
        
        o_mem_addr : out std_logic_vector(15 downto 0);
        i_mem_data : in std_logic_vector(7 downto 0);
        o_mem_we : out std_logic;
        o_mem_en : out std_logic
    );
end project_reti_logiche;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity reg_out_index is 
    port(
        clk, rst, input, start, switch_in: in std_logic;
        output: out std_logic_vector(1 downto 0)
    );
end reg_out_index;

architecture behavioural of reg_out_index is 
    signal en : std_logic;
    signal temp_out : std_logic_vector(1 downto 0);
    begin
        process(clk,rst)
            begin
                if rst = '1' then
                    temp_out <= "00";
                elsif rising_edge(clk) and en = '1' then
                    temp_out(1) <= temp_out(0);
                    temp_out(0) <= input;  
                end if;
        end process;
        en <= start and (not switch_in);
        output <= temp_out;
end behavioural;  

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity reg_mem_addr is 
    port(
        clk, rst, routine_rst, input, start, switch_in: in std_logic;
        output: out std_logic_vector(15 downto 0)
    );
end reg_mem_addr;

architecture behavioural of reg_mem_addr is 
    signal en : std_logic;
    signal temp_out : std_logic_vector(15 downto 0);
    begin
        process(clk,rst)
            begin
                if rst = '1' or (routine_rst = '1' and rising_edge(clk)) then
                    temp_out <= (others => '0');
                elsif rising_edge(clk) and en = '1' then
                    temp_out(15 downto 1) <= temp_out(14 downto 0);
                    temp_out(0) <= input;
                end if;
        end process;
        en <= start and switch_in;
        output <= temp_out;
end behavioural;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity reg_out is 
    port(
        clk, rst, en: in std_logic;
        input: in std_logic_vector(7 downto 0);
        output: out std_logic_vector(7 downto 0)
    );
end reg_out;

architecture behavioural of reg_out is 
    begin
        process(clk,rst)
            begin
                if rst = '1' then
                    output <= (others => '0');
                elsif rising_edge(clk) and en = '1' then
                    output <= input;  
                end if;
        end process;
end behavioural;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity demux is 
    port(
        input : in std_logic;
        ctrl: in std_logic_vector(1 downto 0);
        out1,out2, out3, out4: out std_logic
    );
end demux;

architecture behavioural of demux is
    begin
        process(input,ctrl)
            begin
                case ctrl is
                    when "00" =>
                        out1 <= input;
                        out2 <= '0';
                        out3 <= '0';
                        out4 <= '0';
                    when "01" =>
                        out1 <= '0';
                        out2 <= input;
                        out3 <= '0';
                        out4 <= '0';
                    when "10" =>
                        out1 <= '0';
                        out2 <= '0';
                        out3 <= input;
                        out4 <= '0';
                    when others =>
                        out1 <= '0';
                        out2 <= '0';
                        out3 <= '0';
                        out4 <= input;
                end case;
        end process;      
end behavioural;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity show is 
    port(
        clr: in std_logic;
        input: in std_logic_vector(7 downto 0);
        output: out std_logic_vector(7 downto 0)
    );
end show;

architecture behavioural of show is
    begin
        process(clr)
            begin
                if clr = '0' then
                    output <= (others => '0');
                else
                    output <= input;
                end if;
        end process;      
end behavioural;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity fsm is 
    port(
        start, clk, rst: in std_logic;
        switch_in, o_mem_en, reg_we, o_done: out std_logic
    );
end fsm;

architecture FSM of fsm is
    type state_type is (s0,s1,s2,s3,s4,s5);
    signal next_state,current_state: state_type;
    begin
        state_reg: process(clk,rst)
        begin
            if rst = '1' then
                current_state <= s0;
            elsif rising_edge(clk) then
                current_state <= next_state;
            end if;
        end process;
        lambda: process(current_state,start)
        begin
            case current_state is
                when s0 =>
                    if start = '1' then
                        next_state <= s1;
                    else
                        next_state <= s0;
                    end if;
                when s1 =>
                    next_state <= s2;
                when s2 =>
                    if start = '0' then
                        next_state <= s3;
                    else
                        next_state <= s2;
                    end if;
                when s3 =>
                    next_state <= s4;
                when s4 =>
                    next_state <= s5;
                when s5 =>
                    if start = '0' then
                        next_state <= s0;
                    else
                        next_state <= s1;
                    end if;
            end case;
        end process;
        delta: process(current_state)
        begin
            case current_state is
                when s0 =>
                    switch_in <= '0';
                    o_mem_en <= '0';
                    reg_we <= '0';
                    o_done <= '0';
                when s1 =>
                    switch_in <= '0';
                    o_mem_en <= '0';
                    reg_we <= '0';
                    o_done <= '0';
                when s2 =>
                    switch_in <= '1';
                    o_mem_en <= '0';
                    reg_we <= '0';
                    o_done <= '0';
                when s3 =>
                    switch_in <= '0';
                    o_mem_en <= '1';
                    reg_we <= '0';
                    o_done <= '0'; 
                when s4 =>
                    switch_in <= '0';
                    o_mem_en <= '1';
                    reg_we <= '1';
                    o_done <= '0';
                when s5 =>
                    switch_in <= '0';
                    o_mem_en <= '0';
                    reg_we <= '0';
                    o_done <= '1';
            end case;
        end process;
end FSM;

architecture structural of project_reti_logiche is
    
    component reg_out_index is 
    port(
        clk, rst, input, start, switch_in: in std_logic;
        output: out std_logic_vector(1 downto 0)
    );
    end component reg_out_index;
    
    component reg_mem_addr is 
    port(
        clk, rst, routine_rst, input, start, switch_in: in std_logic;
        output: out std_logic_vector(15 downto 0)
    );
    end component reg_mem_addr;
    
    component reg_out is 
    port(
        clk, rst, en: in std_logic;
        input: in std_logic_vector(7 downto 0);
        output: out std_logic_vector(7 downto 0)
    );
    end component reg_out;
    
    component demux is 
    port(
        input : in std_logic;
        ctrl: in std_logic_vector(1 downto 0);
        out1,out2, out3, out4: out std_logic
    );
    end component demux;
    
    component show is 
    port(
        clr: in std_logic;
        input: in std_logic_vector(7 downto 0);
        output: out std_logic_vector(7 downto 0)
    );
    end component show;

    component fsm is 
    port(
        start, clk, rst: in std_logic;
        switch_in, o_mem_en, reg_we, o_done: out std_logic
    );
    end component fsm;
    
    signal switch_in, reg_we, sig_o_done: std_logic;
    signal out_index: std_logic_vector(1 downto 0);
    signal out_en_0, out_en_1, out_en_2, out_en_3: std_logic;
    signal data_out_0, data_out_1, data_out_2, data_out_3: std_logic_vector(7 downto 0);
    
    
    begin
        inst_fsm : fsm
            port map(start => i_start, clk => i_clk, rst => i_rst, switch_in => switch_in, o_mem_en => o_mem_en, reg_we => reg_we, o_done => sig_o_done);
    
        inst_reg_out_index : reg_out_index
            port map(clk => i_clk, rst => i_rst, input => i_w, start => i_start, switch_in => switch_in, output => out_index);
            
        inst_reg_mem_addr : reg_mem_addr
            port map(clk => i_clk, rst => i_rst, routine_rst => sig_o_done, input => i_w, start => i_start, switch_in => switch_in, output => o_mem_addr);
            
        inst_demux : demux
            port map(input => reg_we, ctrl => out_index, out1 => out_en_0, out2 => out_en_1, out3 => out_en_2, out4 => out_en_3);
            
        inst_reg_out_0 : reg_out
            port map(clk => i_clk, rst =>i_rst, en => out_en_0, input => i_mem_data, output => data_out_0);
            
        inst_reg_out_1 : reg_out
            port map(clk => i_clk, rst =>i_rst, en => out_en_1, input => i_mem_data, output => data_out_1);
            
        inst_reg_out_2 : reg_out
            port map(clk => i_clk, rst =>i_rst, en => out_en_2, input => i_mem_data, output => data_out_2);
            
        inst_reg_out_3 : reg_out
            port map(clk => i_clk, rst =>i_rst, en => out_en_3, input => i_mem_data, output => data_out_3);
            
        show_0 : show
            port map(clr => sig_o_done, input => data_out_0, output => o_z0);
            
        show_1 : show
            port map(clr => sig_o_done, input => data_out_1, output => o_z1);
            
        show_2 : show
            port map(clr => sig_o_done, input => data_out_2, output => o_z2);
            
        show_3 : show
            port map(clr => sig_o_done, input => data_out_3, output => o_z3);
            
        o_done <= sig_o_done;
        o_mem_we <= '0';
    
end structural;