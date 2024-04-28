\m4_TLV_version 1d: tl-x.org
\SV
   // This code can be found in: https://github.com/stevehoover/LF-Building-a-RISC-V-CPU-Core/risc-v_shell.tlv
   
   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/LF-Building-a-RISC-V-CPU-Core/main/lib/risc-v_shell_lib.tlv'])
   
   m4_test_prog()

   //---------------------------------------------------------------------------------
   // /====================\
   // | Sum 1 to 9 Program |
   // \====================/
   //
   // Program to test RV32I
   // Add 1,2,3,...,9 (in that order).
   //
   // Regs:
   //  x12 (a2): 10
   //  x13 (a3): 1..10
   //  x14 (a4): Sum
   // 
   
   //m4_asm(ADDI, x14, x0, 0)             // Initialize sum register a4 with 0
   //m4_asm(ADDI, x12, x0, 1010)          // Store count of 10 in register a2.
   //m4_asm(ADDI, x13, x0, 1)             // Initialize loop count register a3 with 0
   // Loop:
   //m4_asm(ADD, x14, x13, x14)           // Incremental summation
   //m4_asm(ADDI, x13, x13, 1)            // Increment loop count by 1
  // m4_asm(BLT, x13, x12, 1111111111000) // If a3 is less than a2, branch to label named <loop>
   // Test result value in x14, and set x31 to reflect pass/fail.
   //m4_asm(ADDI, x30, x14, 111111010100) // Subtract expected value of 44 to set x30 to 1 if and only iff the result is 45 (1 + 2 + ... + 9).
   //m4_asm(BGE, x0, x0, 0) // Done. Jump to itself (infinite loop). (Up to 20-bit signed immediate plus implicit 0 bit (unlike JALR) provides byte address; last immediate bit should also be 0)
   //m4_asm_end()
   //m4_define(['M4_MAX_CYC'], 50)
   //---------------------------------------------------------------------------------



\SV
   m4_makerchip_module   // (Expanded in Nav-TLV pane.)
   /* verilator lint_on WIDTH */
   
                   
\TLV
   
   $reset = *reset;
   //program counter
   $pc[31:0] = >>1$next_pc;
   $next_pc[31:0] = $reset?32'b00:
                    $taken_br | $is_jal? $br_tgt_pc:
                    $is_jalr? $jalr_tgt_pc:
                    $pc + 32'b100;;
   `READONLY_MEM($pc, $$instr[31:0]);
   //Decode logic
   $is_u_instr = $instr[6:2] ==? 5'b0x101;
   $is_b_instr = $instr[6:2] == 5'b11000;
   $is_j_instr = $instr[6:2] == 5'b11011;
   $is_s_instr = $instr[6:2] ==? 5'b0100x;
   $is_r_instr = $instr[6:2] == 5'b01011 ||
                 $instr[6:2] ==? 5'b011x0 ||
                 $instr[6:2] == 5'b10100;
   $is_i_instr = $instr[6:2] ==? 5'b0000x ||
                 $instr[6:2] ==? 5'b001x0 ||
                 $instr[6:2] == 5'b11001;
   $rs2[4:0] = $instr[24:20];
   $rs1[4:0] = $instr[19:15];
   $rd[4:0] = $instr[11:7];
   $funct3[2:0] = $instr[14:12];
   $opcode[6:0] = $instr[6:0];
   
   $rs2_valid = $is_r_instr || $is_s_instr || $is_b_instr;
   $rs1_valid = $is_r_instr || $is_i_instr || $is_s_instr || $is_b_instr;
   $rd_valid = $is_r_instr || $is_i_instr || $is_u_instr || $is_j_instr;
   $funct3_valid = $is_r_instr || $is_i_instr || $is_s_instr || $is_b_instr;
   $imm_valid = $is_u_instr || $is_i_instr || $is_s_instr || $is_b_instr || $is_j_instr;
   `BOGUS_USE($rd $rd_valid $rs1 $rs1_valid $rs2 $rs2_valid $funct3 $funct3_valid $opcode $imm_valid )
   
   $imm[31:0] = $is_i_instr ? { {21{$instr[31]}}, $instr[30:20] } :
             $is_s_instr ? { {21{$instr[31]}}, $instr[30:25], $instr[11:7] } :
             $is_b_instr ? { {20{$instr[31]}}, $instr[7], $instr[30:25], $instr[11:8], 1'b0  } :
             $is_u_instr ? { $instr[31:12] , 12'b0 } :
             $is_j_instr ? { {12{$instr[31]}}, $instr[19:12], $instr[20], $instr[30:21], 1'b0 } :
             32'b0; //default
   
   $dec_bits[10:0] = {$instr[30],$funct3,$opcode};
   $is_beq = $dec_bits ==? 11'bx_000_1100011;
   $is_bne = $dec_bits ==? 11'bx_001_1100011;
   $is_blt = $dec_bits ==? 11'bx_100_1100011;
   $is_bge = $dec_bits ==? 11'bx_101_1100011;
   $is_bltu = $dec_bits ==? 11'bx_110_1100011;
   $is_bgeu = $dec_bits ==? 11'bx_111_1100011;
   $is_addi = $dec_bits ==? 11'bx_000_0010011;
   $is_add = $dec_bits ==? 11'b0_000_0110011;
   $is_slti = $dec_bits ==? 11'bx_010_0010011;
   $is_jalr = $dec_bits ==? 11'bx_000_1100111;
   $is_jal = $dec_bits ==? 11'bx_xxx_1101111;
   $is_auipc = $dec_bits ==? 11'bx_xxx_0010111;
   $is_lui = $dec_bits ==? 11'bx_xxx_0110111;
   $is_sltiu = $dec_bits ==? 11'bx_011_0010011;
   $is_xori = $dec_bits ==? 11'bx_100_0010011;
   $is_ori = $dec_bits ==? 11'bx_110_0010011;
   $is_andi = $dec_bits ==? 11'bx_111_0010011;
   $is_slli = $dec_bits ==? 11'b0_001_0010011;
   $is_srli = $dec_bits ==? 11'b0_101_0010011;
   $is_srai = $dec_bits ==? 11'b1_101_0010011;
   $is_sub = $dec_bits ==? 11'b1_000_0110011;
   $is_sll = $dec_bits ==? 11'b0_001_0110011;
   $is_slt = $dec_bits ==? 11'b0_010_0110011;
   $is_sltu = $dec_bits ==? 11'b0_011_0110011;
   $is_xor = $dec_bits ==? 11'b0_100_0110011;
   $is_srl = $dec_bits ==? 11'b0_101_0110011;
   $is_sra = $dec_bits ==? 11'b1_101_0110011;
   $is_or = $dec_bits ==? 11'b0_110_0110011;
   $is_and = $dec_bits ==? 11'b0_111_0110011;
   $is_load = $opcode == 7'b0000011;
   
   `BOGUS_USE($imm $dec_bits $is_beq $is_bne $is_blt $is_bge $is_bltu $is_bgeu $is_addi $is_add )
   //ALU logic
   //Subexpressions
   //SLTU and SLTIU (Set if Less Than (Immediate), Unisgned) results:
   $sltu_rslt[31:0] = {31'b0, $src1_value < $src2_value};
   $sltiu_rslt[31:0] = {31'b0, $src1_value < $imm};
   //SRA and SRAI (Shift Right, Arithmetic (Immediate) results:
   //sign-extended src1
   $sext_src1[63:0] = {{32{$src1_value[31]}}, $src1_value[31:0]};
   //64-bit sign-extended results, to be truncated
   $sra_rslt[63:0] = $sext_src1 >> $src2_value[4:0];
   $srai_rslt[63:0] = $sext_src1 >> $imm[4:0];
   $result[31:0] =
                   $is_addi | $is_load | $is_s_instr ? $src1_value + $imm :
                   $is_add ? $src1_value + $src2_value :
                   $is_andi ? $src1_value & $imm :
                   $is_ori ? $src1_value | $imm :
                   $is_xori ? $src1_value ^ $imm :
                   $is_addi ? $src1_value + $imm :
                   $is_slli ? $src1_value << $imm[4:0] :
                   $is_srli ? $src1_value >> $imm[4:0] :
                   $is_and ? $src1_value & $src2_value :
                   $is_or ? $src1_value | $src2_value :
                   $is_xor ? $src1_value ^ $src2_value :
                   $is_add ? $src1_value + $src2_value :
                   $is_sub ? $src1_value - $src2_value :
                   $is_sll ? $src1_value << $src2_value[4:0] :
                   $is_srl ? $src1_value >> $src2_value[4:0] :
                   $is_sltu ? $sltu_rslt :
                   $is_sltiu ? $sltiu_rslt :
                   $is_lui ? {$imm[31:12], 12'b0} :
                   $is_auipc ? $pc + $imm :
                   $is_jal ? $pc + 32'd4 :
                   $is_jalr ? $pc + 32'd4 :
                   $is_slt ? $src1_value[31] == $src2_value[31] ?
                             $sltu_rslt :
                             {31'b0, $src1_value[31]} :
                   $is_slti ? $src1_value[31] == $imm[31] ?
                             $sltiu_rslt :
                             {31'b0, $src1_value[31]} :
                   $is_sra ? $sra_rslt[31:0] :
                   $is_srai ? $srai_rslt[31:0] :
		   $is_load ? ($src1_value + $imm) :
                   $is_s_instr ? ($src1_value + $imm) :
                   32'b0; //default
    
   //branch logic 
   $is_b = $is_beq || $is_bne || $is_blt || $is_bge || $is_bltu || $is_bgeu;
   $taken_br = $is_b ?
               ($is_beq && ($src1_value == $src2_value) ? 1'b1 :
               $is_bne && ($src1_value != $src2_value) ? 1'b1 :
               $is_blt && (($src1_value < $src2_value) ^ ($src1_value[31] != $src2_value[31])) ? 1'b1 :
               $is_bge && (($src1_value >= $src2_value) ^ ($src1_value[31] != $src2_value[31])) ? 1'b1 :
               $is_bltu && ($src1_value < $src2_value) ? 1'b1 :
               $is_bgeu && ($src1_value >= $src2_value) ? 1'b1 :1'b0) :
               1'b0;
   $br_tgt_pc[31:0] = $pc + $imm;
   $jalr_tgt_pc[31:0] = $src1_value + $imm;
   


   
   
   
   
   
   // Assert these to end simulation (before Makerchip cycle limit).
   m4+tb()
   *failed = *cyc_cnt > M4_MAX_CYC;
   //Multiplexor to choose between ALU results and load instructions
   $rf_w[31:0] = $is_load ? $ld_data : $result;
   //m4+rf(32, 32, $reset, $wr_en, $wr_index[4:0], $wr_data[31:0], $rd_en1, $rd_index1[4:0], $rd_data1, $rd_en2, $rd_index2[4:0], $rd_data2)
   m4+rf(32, 32, $reset, $rd_valid, $rd[4:0], $rf_w, $rs1_valid, $rs1[4:0], $src1_value, $rs2_valid, $rs2[4:0], $src2_value)
   
   m4+dmem(32, 32, $reset, $result, $is_s_instr, $src2_value, $is_load, $ld_data)
   m4+cpu_viz()
\SV
   endmodule