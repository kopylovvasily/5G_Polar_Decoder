/*----------------------------------------------------This is the main module of Polar Decoder SC_512-----------------------------------------------------------------------------------------
This decoder requires as inputs, K(number of Message Bits), E(number of Rate matched bits), and input LLRS. Note: Input LLRS must be applied for 4 consecutive clock cycles.
Input LLRS must be 7 bits where first bit is used to represent the sign, 5 bits are used to represent the integer part of the LLRs,and last bit is used to represent the 
floating part. Decoder will always produce a 512 bits decoded output. This decoder operates for any N={32,64,128,256,512}, and it is important to emphasize that when N<512, 
only N first bits of the output sequence will represent the correct decoded bits, the rest will be just zeros. So, when N=256, you must consider only first 256 outputs of this decoder,
when N=32, you should consider only first 32 and so on. The same thing happens when you apply input LLRS for N<512. Only N first input LLRS will be considered by the decoder. It is advisable to
put zeors on the rest of LLRS which will not be considered. Moreover, this decoder will also show as an output N(number of coded bits). For the proper operation of this decoder, handshake 
signals must be considered as well. Put valid_i = 1, whenever you apply input LLRS and submit new LLRs whenever ready_o=1. When ready_o=1, decoded values are ready.
*/

module SC_512_decoder
  import pkg::*;
(
  input logic [8:0] K_i, //number of message bits
  input logic [14:0] E_i, //number of rate matched bits
  input logic valid_i, // when valid = 1, new LLRS can be applied
  input logic clk_i,
  input logic rst_ni,
  input logic [N-1:0][BITWIDTH_LLRS-1:0] LLR_i,  //make it 4 times smaller
  output logic [N-1:0] decodedvalue_o, //decoded output
  output logic ready_o, // decoded values are ready and the decoder is ready to receive new LLRs next clock cycle
  output logic [2:0] N_i
);


  typedef logic [BITWIDTH_LLRS-1:0] temp_t; 

  /***************************************************************
                    Signal Instantiations
  ****************************************************************/
  temp_t[NR_PROCESSING_UNITS-1:0] f1_i, f2_i, ftemp_o, g1_i, g2_i, gtemp_o, fgtemp_o; 
  logic [NR_PROCESSING_UNITS-1:0] s; 
  
  logic [BITWIDTH_LLRS-1:0] facc1temp_in, facc2temp_in, facc3temp_in, facc4temp_in;
  logic [BITWIDTH_LLRS-1:0] facc5temp_in, facc6temp_in, facc7temp_in, facc8temp_in;
  logic facc1temp_o, facc2temp_o, facc3temp_o, facc4temp_o; 
  logic [BITWIDTH_LLRS-1:0] gacc1temp_in, gacc2temp_in, gacc3temp_in, gacc4temp_in;
  logic [BITWIDTH_LLRS-1:0] gacc5temp_in, gacc6temp_in, gacc7temp_in, gacc8temp_in;
  logic gacc1temp_o, gacc2temp_o, gacc3temp_o, gacc4temp_o; 
  logic s20_o, s21_o, s22_o, s23_o; 
  logic s20_d, s21_d, s22_d, s23_d;
  logic s20_q, s21_q, s22_q, s23_q;

  //Frozen bit signals
  logic [7:0] counterFrozen_d, counterFrozen_q; 
  logic [511:0] frozen;
  logic fr_start;
  logic [7:0] frozenBits_d, frozenBits_q; 


  //Signals for combiners
  logic [3:0] l_4, r_4, o_4;
  logic [7:0] o_8, l_8, r_8;
  logic [15:0] o_16, l_16, r_16;
  logic [31:0] o_32, l_32, r_32;
  logic [63:0] o_64, l_64, r_64;
  logic [127:0] o_128, l_128, r_128;
  logic [255:0] o_256;
  logic l_11,r_11,l_21,r_21;
  logic [1:0] o_21, o_22;
  logic gl_11,gr_11, gl_21,gr_21;
  logic [1:0] go_21, go_22;
  logic[3:0] combine_g4;


  //signals for memories 
  logic wr_alpha1, wr_alpha2;
  logic [2:0] address_alpha1;
  logic [1:0] address_alpha2;
  logic [127:0][BITWIDTH_LLRS-1:0] indata_alpha1, indata_alpha2, outdata_alpha1, outdata_alpha2;  

  //control signals 
  logic control_32, control_64, control_128, control_256, control_512;
  logic [10:0] checkcounter_d, checkcounter_q;
  logic s_set_to_zeros;
  temp_t[63:0] fgtemp1, fgtemp2, f128temp1, f128temp2, f64temp1, f64temp2, f32temp1, f32temp2, f16temp1, f16temp2, f8temp1, f8temp2;
  temp_t[127:0] indata_f, s128reg1_q, s128reg2_q;
  temp_t[63:0] reg1_d, reg2_d, reg1_q, reg2_q, reg_int;
  logic [1:0] fread_RAM;
  logic [2:0] choose_rdpattern;


  //signals for FSM
  logic [N-1:0] Memory_Beta_q, Memory_Beta_d, Output_reg_q, Output_reg_d;
  logic [(N/8-1):0]counter_8f_q,counter_8f_d;
  logic [(N/8-1):0]counter_8g_q,counter_8g_d;
  logic [2:0] load_counter_d, load_counter_q;
  logic [5:0] counter16g_q,counter16g_d;
  logic [4:0] counter32g_q,counter32g_d;
  logic [3:0] counter64g_q,counter64g_d;
  logic [7:0] counter128g_q,counter128g_d;
  logic [3:0] counter512f_d,counter512f_q,counter512g_d,counter512g_q;
  logic [1:0] counter256f_d,counter256f_q,counter256g_d,counter256g_q, counter256gg_d, counter256gg_q; 
  logic f_512_q,f_512_d,f_256_q,f_256_d,f_128_q,f_128_d,f_64_q,f_64_d;
  logic f_32_q,f_32_d,f_16_q,f_16_d,f_8_q,f_8_d;
  logic g_512_q,g_512_d,g_256_q,g_256_d,g_128_q,g_128_d,g_64_q,g_64_d;
  logic g_32_q,g_32_d,g_16_q,g_16_d;
  logic ready_d, ready_q; 
  logic [511:0] counter_ccc_d, counter_ccc_q;
  logic [7:0] wire_k;
  logic [7:0] counter_8c_q,counter_8c_d;
  logic [7:0] counter_16c_q,counter_16c_d;
  logic [7:0] counter_32c_q,counter_32c_d;
  logic [7:0] counter_64c_q,counter_64c_d;
  logic [7:0] counter_128c_q,counter_128c_d;
  logic [7:0] counter_256c_q,counter_256c_d;
  logic [5:0] additional_latency_d, additional_latency_q;

  logic [4:0] additional_latency;



  /***************************************************************
                    Module Instantiations
  ****************************************************************/


/*-------------------Accelerators--------------------------------*/
//main processing units of the decoder, in total we have 2 of them
  F_Acc #(
    .bitwidth(BITWIDTH_LLRS)
    ) F_Accelerator (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .f11_i(facc1temp_in),
    .f12_i(facc2temp_in),
    .f21_i(facc3temp_in),
    .f22_i(facc4temp_in),
    .f31_i(facc5temp_in),
    .f32_i(facc6temp_in),
    .f41_i(facc7temp_in),
    .f42_i(facc8temp_in),
    .four_frozen_bits(frozenBits_q[7:4]),
    .f1_o(facc1temp_o),
    .g1_o(facc2temp_o),
    .f2_o(facc3temp_o),
    .g2_o(facc4temp_o)
  );

  G_Acc #(
    .bitwidth(BITWIDTH_LLRS)
    ) G_Accelerator (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .g11_i(gacc1temp_in),
    .g12_i(gacc2temp_in),
    .g21_i(gacc3temp_in),
    .g22_i(gacc4temp_in),
    .g31_i(gacc5temp_in),
    .g32_i(gacc6temp_in),
    .g41_i(gacc7temp_in),
    .g42_i(gacc8temp_in),
    .s20_i(s20_o),
    .s21_i(s21_o),
    .s22_i(s22_o),
    .s23_i(s23_o),
    .four_frozen_bits(frozenBits_q[3:0]),
    .f1_o(gacc1temp_o),
    .g1_o(gacc2temp_o),
    .f2_o(gacc3temp_o),
    .g2_o(gacc4temp_o)
  );


  /*-------------------Frozen Pattern Generation Module---------*/
  //This module is used in order to generate the forzen bit pattern for any K and E combination
  
  FrozenPattern_Generator #(.Bitwidth(BITWIDTH_REL_SEQ)
    ) fr (
    .frozen_start(fr_start),
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .K_i(K_i), 
    .E_i(E_i), 
    .frozen512_o(frozen), 
    .N_o(N_i)
  );


  /*---------------------Memories--------------------------------*/

  MemoryAlpha1 #(.BITWIDTH_ADDRESS(3), 
    .BITWIDTH_LLRS(BITWIDTH_LLRS),
    .DEPTH(6)
    ) Alpha1 (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .wr_i(wr_alpha1),
    .address_i(address_alpha1),
    .data_i(indata_alpha1),
    .data_o(outdata_alpha1)
   ); 

  MemoryAlpha2 #(.BITWIDTH_ADDRESS(2), 
    .BITWIDTH_LLRS(BITWIDTH_LLRS),
    .DEPTH(3)
    ) Alpha2 (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .wr_i(wr_alpha2),
    .address_i(address_alpha2),
    .data_i(indata_alpha2),
    .data_o(outdata_alpha2)
  ); 

  /*---------------------combiners--------------------------------*/
  // combiners are responsible for xor and feedforward operation which will be required from G processing units      

  //combiners responsible for 2 bit output

   combiner #(
      .bitwidth_outLLR(2),
      .bitwidth_inLLR(1)
   ) combiner_f2_1
   (
    .clk_i(clk_i), 
    .rst_ni(rst_ni),
    .gl_i(l_11),
    .gr_i(r_11),
    .g_o(o_21)
  );

   combiner #(
      .bitwidth_outLLR(2),
      .bitwidth_inLLR(1)
   ) combiner_g2_1
   (
    .clk_i(clk_i), 
    .rst_ni(rst_ni),
    .gl_i(gl_11),
    .gr_i(gr_11),
    .g_o(go_21)
  );

   combiner #(
      .bitwidth_outLLR(2),
      .bitwidth_inLLR(1)
   ) combiner_g2_2
   (
    .clk_i(clk_i), 
    .rst_ni(rst_ni),
    .gl_i(gl_21),
    .gr_i(gr_21),
    .g_o(go_22)
  );

   combiner #(
      .bitwidth_outLLR(2),
      .bitwidth_inLLR(1)
   ) combiner_f2_2
   (
    .clk_i(clk_i), 
    .rst_ni(rst_ni),
    .gl_i(l_21),
    .gr_i(r_21),
    .g_o(o_22)
  );

  //combiners responsible for 4 bit output
   combiner #(
      .bitwidth_outLLR(4),
      .bitwidth_inLLR(2)
   ) combiner_f4
   (
    .clk_i(clk_i), 
    .rst_ni(rst_ni),
    .gl_i(o_21),
    .gr_i(o_22),
    .g_o(o_4)
  );

  combiner #(
      .bitwidth_outLLR(4),
      .bitwidth_inLLR(2)
   ) combiner_g4
   (
    .clk_i(clk_i), 
    .rst_ni(rst_ni),
    .gl_i(go_21),
    .gr_i(go_22),
    .g_o(combine_g4)
  );

  //combiners responsible for 8 bit output
   combiner #(
      .bitwidth_outLLR(8),
      .bitwidth_inLLR(4)
   ) combiner_8
   (
    .clk_i(clk_i), 
    .rst_ni(rst_ni),
    .gl_i(l_4),
    .gr_i(r_4),
    .g_o(o_8)
  );

  //combiners responsible for 16 bit output
   combiner #(
      .bitwidth_outLLR(16),
      .bitwidth_inLLR(8)
   ) combiner_16
   (
    .clk_i(clk_i), 
    .rst_ni(rst_ni),
    .gl_i(l_8),
    .gr_i(r_8),
    .g_o(o_16)
  );


  //combiners responsible for 32 bit output
   combiner #(
      .bitwidth_outLLR(32),
      .bitwidth_inLLR(16)
   ) combiner_32
   (
    .clk_i(clk_i), 
    .rst_ni(rst_ni),
    .gl_i(l_16),
    .gr_i(r_16),
    .g_o(o_32)
  );


  //combiners responsible for 64 bit output
   combiner #(
      .bitwidth_outLLR(64),
      .bitwidth_inLLR(32)
   ) combiner_64
   (
    .clk_i(clk_i), 
    .rst_ni(rst_ni),
    .gl_i(l_32),
    .gr_i(r_32),
    .g_o(o_64)
  );

  //combiners responsible for 128 bit output
   combiner #(
      .bitwidth_outLLR(128),
      .bitwidth_inLLR(64)
   ) combiner_128
   (
    .clk_i(clk_i), 
    .rst_ni(rst_ni),
    .gl_i(l_64),
    .gr_i(r_64),
    .g_o(o_128)
  );


  //combiners responsible for 256 bit output
   combiner #(
      .bitwidth_outLLR(256),
      .bitwidth_inLLR(128)
   ) combiner_256
   (
    .clk_i(clk_i), 
    .rst_ni(rst_ni),
    .gl_i(l_128),
    .gr_i(r_128),
    .g_o(o_256)
  );


  /*-------------------Processing units--------------------------*/
  //In total we have 64 f-s and 64 g-s
  // 64 fs  
  genvar i;
  generate
    for(i=0; i<64;i++) begin
      F_func #(.bitwidth(BITWIDTH_LLRS)) f_fun (.clk_i(clk_i), .rst_ni(rst_ni), .r1_i(f1_i[i]), .r2_i(f2_i[i]), .f_o(ftemp_o[i]));
    end
  endgenerate

  // 64 gs
  genvar j;
  generate
    for(j=0; j<64;j++) begin
      G_func #(.bitwidth(BITWIDTH_LLRS)) g_fun (.clk_i(clk_i), .rst_ni(rst_ni), .r1_i(g1_i[j]), .r2_i(g2_i[j]), .b_i(s[j]), .g_o(gtemp_o[j]));
    end
  endgenerate


  /***************************************************************
                DataPath
  ****************************************************************/
// this always_comb block will be responsible to generate the control signals depending on computed N

  always_comb begin
    control_32 = '0; 
    control_64 = '0;
    control_128 = '0; 
    control_256 = '0;
    control_512 = '0;
    additional_latency = '0; // we introduce some latency at the beginning to make it the same for all Ns (required for FrozenBits Generation)
    if (N_i == 3'b010) begin //activated when N = 32
      control_32 = 1'b1; 
      control_64 = '0;
      control_128 = '0; 
      control_256 = '0;
      control_512 = '0;
      additional_latency = 5'd12; // we introduce 12 additional clock cycles at the beginning to make the latency at par with N = 512 case
    end else if (N_i == 3'b011) begin // activated when N = 64
      control_32 = '0; 
      control_64 = 1'b1;
      control_128 = '0; 
      control_256 = '0;
      control_512 = '0;
      additional_latency = 5'd11;
    end else if (N_i == 3'b100) begin //activated when N = 128
      control_32 = '0; 
      control_64 = '0;
      control_128 = 1'b1; 
      control_256 = '0;
      control_512 = '0;
      additional_latency = 5'd10;
    end else if (N_i == 3'b101) begin //activated when N = 256
      control_32 = '0; 
      control_64 = '0;
      control_128 = '0; 
      control_256 = 1'b1;
      control_512 = '0;
      additional_latency = 5'd8;
    end else if (N_i == 3'b110) begin //activated when N = 512
      control_32 = '0; 
      control_64 = '0;
      control_128 = '0; 
      control_256 = '0;
      control_512 = 1'b1;
      additional_latency = '0;
    end
  end

  assign s20_o = (s_set_to_zeros == 1'b0) ? s20_q : 1'b0; // we set to zeros partial sums for the G accelerator in case of detected 4 frozen bits pattern
  assign s21_o = (s_set_to_zeros == 1'b0) ? s21_q : 1'b0; 
  assign s22_o = (s_set_to_zeros == 1'b0) ? s22_q : 1'b0; 
  assign s23_o = (s_set_to_zeros == 1'b0) ? s23_q : 1'b0; 
  assign indata_f = (fread_RAM == 2'b00) ? outdata_alpha1 : (fread_RAM == 2'b01) ? outdata_alpha2 : (fread_RAM == 2'b10) ? s128reg1_q : s128reg2_q;  
  assign s128reg1_q[127:64] = reg1_q; 
  assign s128reg1_q[63:0] = '0; 
  assign s128reg2_q[127:96] = reg2_q[63:32];
  assign s128reg2_q[95:0] = '0; 

  // 1) reading fs
  assign f128temp1 = indata_f[127:64]; // when the referred LLRs are stored in all 128 cells of a particular address 
  assign f128temp2 = indata_f[63:0];
  assign f64temp1[63:32] = indata_f[127:96]; // when the referred LLRs are stored in 64 cells of a particular address 
  assign f64temp2[63:32] = indata_f[95:64];
  assign f64temp1[31:0] = '0;
  assign f64temp2[31:0] = '0;
  assign f32temp1[63:48] = indata_f[127:112]; // when the referred LLRs are stored in 32 cells of a particular address 
  assign f32temp2[63:48] = indata_f[111:96];
  assign f32temp1[47:0] = '0;
  assign f32temp2[47:0] = '0;
  assign f16temp1[63:56] = indata_f[63:56]; // when the referred LLRs are stored in 16 cells of a particular address (others 64 are empty) 
  assign f16temp2[63:56] = indata_f[55:48];
  assign f16temp1[55:0] = '0;
  assign f16temp2[55:0] = '0;
  assign f8temp1[63:60] = indata_f[63:60]; // when the referred LLRs are stored in 8 cells of a particular address (others 64 are empty) 
  assign f8temp2[63:60] = indata_f[59:56];
  assign f8temp1[59:0] = '0;
  assign f8temp2[59:0] = '0;
  assign fgtemp1 = (choose_rdpattern == 3'b000) ? f128temp1 : (choose_rdpattern == 3'b001) ? f64temp1 : (choose_rdpattern == 3'b010) ? f32temp1 : (choose_rdpattern == 3'b011) ? f16temp1 : f8temp1;      
  assign fgtemp2 = (choose_rdpattern == 3'b000) ? f128temp2 : (choose_rdpattern == 3'b001) ? f64temp2 : (choose_rdpattern == 3'b010) ? f32temp2 : (choose_rdpattern == 3'b011) ? f16temp2 : f8temp2; 

  // 2) writing Fs 
  temp_t[63:0] indata_reg12;
  temp_t[127:0] fwr128_temp, fwr64and16_temp, fwr32and8_temp, fwr_temp, LLRs_loading;
  logic selectF_or_G; // if one we select 64F output; otherwise we select 64G outpup
  logic update_reg1, update_reg2, choose_reg; // control signals
  logic [1:0] choose_wrpattern; // another control signal
  logic LLRs_coming;

  // fop accessing the block diagram, check the 19th page in the notes
  assign fgtemp_o = (selectF_or_G == 1'b1) ? ftemp_o : gtemp_o;
  assign indata_reg12 = (LLRs_coming == 1'b1) ? LLRs_loading[127:64] : fgtemp_o;  // recentle added
  assign fwr128_temp[127:64] = reg_int[63:0];
  assign fwr128_temp[63:0] = fgtemp_o[63:0];
  assign fwr64and16_temp[127:96] = reg_int[63:32]; // the second written pattern
  assign fwr64and16_temp[95:64] = reg_int[31:0];
  assign fwr64and16_temp[63:56] = fgtemp_o[63:56]; 
  assign fwr64and16_temp[55:48] = fgtemp_o[55:48];
  assign fwr64and16_temp[47:0] = '0; 
  assign fwr32and8_temp[127:96] = reg_int[63:32]; // the third written pattern 
  assign fwr32and8_temp[95:64] = '0; // the third written pattern 
  assign fwr32and8_temp[63:56] = fgtemp_o[63:56];
  assign fwr32and8_temp[55:0] = '0;
  assign reg1_d = (update_reg1 == 1'b1) ? indata_reg12 : reg1_q; // update (or not) the first register
  assign reg2_d = (update_reg2 == 1'b1) ? indata_reg12 : reg2_q; // update (or not) the second register
  assign reg_int = (choose_reg == 1'b1) ? reg1_q : reg2_q; // if choose_reg = 1, we choose to read from the first register; otherwise - from the second 
  assign fwr_temp = (choose_wrpattern == 2'b00) ? fwr128_temp : (choose_wrpattern == 2'b01) ? fwr64and16_temp : fwr32and8_temp; 
  assign indata_alpha1 = (LLRs_coming == 1'b1) ? LLRs_loading : fwr_temp; // we write our data in the alpha memory
  assign indata_alpha2 = (LLRs_coming == 1'b1) ? LLRs_loading : fwr_temp; // potentially requires replacement for a multiplexer
  logic[3:0] tempoutput_f,tempoutput_g;
  assign s20_d = facc1temp_o ^ facc2temp_o ^ facc3temp_o ^ facc4temp_o;
  assign s21_d = facc2temp_o ^ facc4temp_o;
  assign s22_d = facc3temp_o ^ facc4temp_o;
  assign s23_d = facc4temp_o;

  // 3) connect 64 fs to vectors ftemp1 and ftemp2; 
  assign f1_i = fgtemp1;
  assign f2_i = fgtemp2;
  assign g1_i = fgtemp1;
  assign g2_i = fgtemp2;

  // connect inputs of the accelerators to the memory 
  assign facc1temp_in = outdata_alpha1[63];
  assign facc2temp_in = outdata_alpha1[59];
  assign facc3temp_in = outdata_alpha1[62];
  assign facc4temp_in = outdata_alpha1[58];
  assign facc5temp_in = outdata_alpha1[61];
  assign facc6temp_in = outdata_alpha1[57];
  assign facc7temp_in = outdata_alpha1[60];
  assign facc8temp_in = outdata_alpha1[56];
  assign gacc1temp_in = outdata_alpha1[63];
  assign gacc2temp_in = outdata_alpha1[59];
  assign gacc3temp_in = outdata_alpha1[62];
  assign gacc4temp_in = outdata_alpha1[58];
  assign gacc5temp_in = outdata_alpha1[61];
  assign gacc6temp_in = outdata_alpha1[57];
  assign gacc7temp_in = outdata_alpha1[60];
  assign gacc8temp_in = outdata_alpha1[56];
  assign l_11=tempoutput_f[3];
  assign r_11=tempoutput_f[2];
  assign l_21=tempoutput_f[1];
  assign r_21=tempoutput_f[0];
  assign gl_11=tempoutput_g[3];
  assign gr_11=tempoutput_g[2];
  assign gl_21=tempoutput_g[1];
  assign gr_21=tempoutput_g[0];
  assign ready_o = ready_q;

  /***************************************************************
                               FSM
  ****************************************************************/
  typedef enum logic [5:0] {
    Idle, 
    Idle2,
    Load,
    Five_one_two,
    Two_Five_six,
    One_Two_Eight,
    Six_four,
    Three_Two,
    One_Six,
    Eight
  } state_e;
  state_e state_d, state_q; 

  always_comb begin 

    LLRs_coming = 1'b0;
    checkcounter_d = checkcounter_q + 1'b1;
    counterFrozen_d = counterFrozen_q;
    frozenBits_d = frozenBits_q;
    wire_k = 8'd0;
    load_counter_d = load_counter_q; 
    counter512f_d = counter512f_q; 
    counter256f_d = counter256f_q; 
    counter512g_d = counter512g_q; 
    counter256g_d = counter256g_q; 
    counter128g_d = counter128g_q; 
    counter64g_d = counter64g_q; 
    counter32g_d = counter32g_q; 
    counter16g_d = counter16g_q; 
    counter256gg_d = counter256gg_q; 
    Output_reg_d = Output_reg_q;
    Memory_Beta_d = Memory_Beta_q;
    counter_8f_d = counter_8f_q;
    counter_8g_d = counter_8g_q;
    counter_8c_d = counter_8c_q;
    counter_16c_d = counter_16c_q;
    counter_32c_d = counter_32c_q;
    counter_64c_d = counter_64c_q;
    counter_128c_d = counter_128c_q;
    counter_256c_d = counter_256c_q;
    wr_alpha1 = 1'b0; 
    wr_alpha2 = 1'b0; 
    ready_d = 1'b0;
    state_d = state_q;
    f_512_d = f_512_q;
    f_256_d = f_256_q;
    f_128_d = f_128_q;
    f_64_d = f_64_q;
    f_32_d = f_32_q;
    f_16_d = f_16_q;
    f_8_d = f_8_q;
    g_512_d = g_512_q;
    g_256_d = g_256_q;
    g_128_d = g_128_q;
    g_64_d = g_64_q;
    g_32_d = g_32_q;
    g_16_d = g_16_q;
    decodedvalue_o = Output_reg_q;
    s_set_to_zeros = '0;
    additional_latency_d = additional_latency_q;

    case(state_q) 
    
      Idle: begin
        Output_reg_d = '0;
        if (valid_i == 1'b1) begin
          additional_latency_d = additional_latency_q + 1'b1;
          fr_start = 1'b1; // the generation of frozen bits begins
          if (additional_latency_q == additional_latency) begin // we introduced some latency at the beginning for N != 512 states  
            state_d = Load; // and we go to the LLRs Loading
          end
        end
      end

      //in this state input LLRs are received and stored
      Load: begin // we have 7 loading scenarios (for different values of N) 
        fr_start = 1'b0;
        LLRs_coming = 1'b1;
        load_counter_d = load_counter_q + 1'b1;
        if (control_512 == 1'b1) begin
          if (load_counter_q == 3'b000) begin
            wr_alpha1 = 1'b1; 
            address_alpha1 = 3'b000;
            LLRs_loading[127:64] = LLR_i[511:448];
            LLRs_loading[63:0] = LLR_i[255:192];
          end else if (load_counter_q == 3'b001) begin
            wr_alpha1 = 1'b1; 
            address_alpha1 = 3'b001;
            LLRs_loading[127:64] = LLR_i[447:384];
            LLRs_loading[63:0] = LLR_i[191:128];
          end else if (load_counter_q == 3'b010) begin
            wr_alpha1 = 1'b1; 
            address_alpha1 = 3'b010;
            LLRs_loading[127:64] = LLR_i[383:320];
            LLRs_loading[63:0] = LLR_i[127:64];
          end else if (load_counter_q == 3'b011) begin
            wr_alpha1 = 1'b1; 
            address_alpha1 = 3'b011;
            LLRs_loading[127:64] = LLR_i[319:256];
            LLRs_loading[63:0] = LLR_i[63:0];
            state_d = Five_one_two; 
            load_counter_d = '0; 
            /////////////////// we skip the beginning of the tree (for future implemetation)
            //f_64_d = 1'b1; 
            //f_16_d = 1'b1; 
            //counter32g_d = 5'd1;
            //counter16g_d = 6'd2;
            //counter_8f_d = 64'd5;
            //counter_8g_d = 64'd5;
            //counter_8c_d = 8'd5;
            //counter_16c_d = 8'd2;
            //counter_32c_d = 8'd1;
            ///////////////////
          end 
        end

        if (control_256 == 1'b1) begin
          if (load_counter_q == 3'b000) begin
            wr_alpha2 = 1'b1; 
            address_alpha2 = 2'b00;
            LLRs_loading[127:64] = LLR_i[511:448];
            LLRs_loading[63:0] = LLR_i[383:320];
          end else if (load_counter_q == 3'b001) begin
            wr_alpha2 = 1'b1; 
            address_alpha2 = 2'b01;
            LLRs_loading[127:64] = LLR_i[447:384];
            LLRs_loading[63:0] = LLR_i[319:256];
            state_d = Two_Five_six; 
            load_counter_d = '0; 
          end 
        end

        if (control_128 == 1'b1) begin
          wr_alpha1 = 1'b1; 
          address_alpha1 = 3'b100;
          LLRs_loading[127:64] = LLR_i[511:448];
          LLRs_loading[63:0] = LLR_i[447:384];
          state_d = One_Two_Eight; 
        end

        if (control_64 == 1'b1) begin
          LLRs_loading[127:64] = LLR_i[511:448];
          LLRs_loading[63:0] = '0;
          update_reg1 = 1'b1;
          state_d = Six_four; 
        end

        if (control_32 == 1'b1) begin
          LLRs_loading[127:96] = LLR_i[511:480];
          LLRs_loading[95:0] = '0;
          update_reg2 = 1'b1;
          state_d = Three_Two; 
        end
      end
    /************************************************************************************************/
      Five_one_two: begin 

        LLRs_coming = 1'b0;
        wr_alpha1 = 1'b0; 
        fread_RAM = 2'b00; 
        update_reg2 = 1'b0;
        choose_rdpattern = 3'b000;
        choose_wrpattern = 2'b00;
        choose_reg = 1'b1;
        if (f_512_q == 1'b0) begin // perform 256 "f" functions on 512 LLRs (4 clock cycles required)
          selectF_or_G = 1'b1; 
          counter512f_d = counter512f_q + 1'b1; 
          if (counter512f_q == 4'd0) begin // the first clock cycle
            address_alpha1 = 3'b000;
            update_reg1 = 1'b1;
            wr_alpha2 = 1'b0; 
          end else if (counter512f_q == 4'd1) begin // the second clock cycle 
            address_alpha1 = 3'b010;
            update_reg1 = 1'b0;
            wr_alpha2 = 1'b1; 
            address_alpha2 = 2'b00;
          end else if (counter512f_q == 4'd2) begin // the third clock cycle 
            address_alpha1 = 3'b001;
            update_reg1 = 1'b1;
            wr_alpha2 = 1'b0; 
          end else if (counter512f_q == 4'd3) begin // the fourth clock cycle
            address_alpha1 = 3'b011;
            update_reg1 = 1'b0;
            wr_alpha2 = 1'b1; 
            address_alpha2 = 2'b01;
            counter512f_d = 0; 
            state_d = Two_Five_six; 
            f_512_d =1'b1;  
          end 
        end else begin // perform 256 "g" functions on 512 LLRs (4 clock cycles required)
          selectF_or_G = 1'b0; 
          counter512g_d = counter512g_q + 1'b1; //counts clock cyles 
          if (counter512g_q == 4'd0) begin // the first clock cycle
            s[63:0] = Memory_Beta_q[N-1-0*64:N-64-0*64];
          end else if (counter512g_q == 4'd1) begin // the second clock cycle 
            s[63:0] = Memory_Beta_q[N-1-2*64:N-64-2*64];
          end else if (counter512g_q == 4'd2) begin // the third clock cycle 
            s[63:0] = Memory_Beta_q[N-1-1*64:N-64-1*64];
          end else if (counter512g_q == 4'd3) begin // the fourth clock cycle
            s[63:0] = Memory_Beta_q[N-1-3*64:N-64-3*64];
          end 
          if (counter512g_q == 4'd0) begin // the first clock cycle
            address_alpha1 = 3'b000;
            update_reg1 = 1'b1;
            wr_alpha2 = 1'b0; 
          end else if (counter512g_q == 4'd1) begin // the second clock cycle 
            address_alpha1 = 3'b010;
            update_reg1 = 1'b0;
            wr_alpha2 = 1'b1; 
            address_alpha2 = 2'b00;
          end else if (counter512g_q == 4'd2) begin // the third clock cycle 
            address_alpha1 = 3'b001;
            update_reg1 = 1'b1;
            wr_alpha2 = 1'b0; 
          end else if (counter512g_q == 4'd3) begin // the fourth clock cycle
            address_alpha1 = 3'b011;
            update_reg1 = 1'b0;
            wr_alpha2 = 1'b1; 
            address_alpha2 = 2'b01;
            counter512g_d = 0; 
            state_d = Two_Five_six; 
            g_512_d = 1'b1;
          end 
        end
      end
    /************************************************************************************************/
      Two_Five_six:begin

        wr_alpha2 = 1'b0; 
        fread_RAM = 2'b01; 
        update_reg2 = 1'b0;
        choose_rdpattern = 3'b000;
        choose_wrpattern = 2'b00;
        choose_reg = 1'b1;
        if(f_256_q == 1'b0) begin // perform 128 "f" functions on 256 LLRs (2 clock cycles required)
          selectF_or_G = 1'b1; 
          counter256f_d = counter256f_q + 1'b1; 
          if (counter256f_q == 2'd0) begin // the first clock cycle
            address_alpha2 = 2'b00;
            update_reg1 = 1'b1;
            wr_alpha1 = 1'b0; 
          end else if (counter256f_q == 2'd1) begin // the second clock cycle 
            address_alpha2 = 2'b01;
            update_reg1 = 1'b0;
            wr_alpha1 = 1'b1; 
            address_alpha1 = 3'b100;
            counter256f_d = 0;
            state_d = One_Two_Eight;
            f_256_d =1'b1;
          end 
        end else begin // perform 128 "g" functions on 256 LLRs (2 clock cycles required)
          selectF_or_G = 1'b0; 
          counter256gg_d = counter256gg_q + 1'b1; // counts the clock cycles
          if (counter256g_q == 2'd0) begin // the first 256 encounter
            if (counter256gg_q == 2'd0) begin // the first clock cycle
              s[63:0] = Memory_Beta_q[511:448]; 
            end else if(counter256gg_q == 2'd1) begin
              s[63:0] = Memory_Beta_q[447:384]; 
            end 

          end else if(counter256g_q == 2'd1) begin
            if (counter256gg_q == 2'd0) begin // the first clock cycle
              s[63:0] = Memory_Beta_q[255:192];     
            end else if(counter256gg_q == 2'd1) begin
              s[63:0] = Memory_Beta_q[191:128];    
            end 
          end 

          if (counter256gg_q == 2'd0) begin // the first clock cycle
            address_alpha2 = 2'b00;
            update_reg1 = 1'b1;
            wr_alpha1 = 1'b0; 
          end else if (counter256gg_q == 2'd1) begin // the second clock cycle 
            address_alpha2 = 2'b01;
            update_reg1 = 1'b0;
            wr_alpha1 = 1'b1; 
            address_alpha1 = 3'b100;
            state_d = One_Two_Eight;
            counter256gg_d = 0;
            counter256g_d = counter256g_q + 1'b1;
            g_256_d = 1'b1;
          end 
        end 
      end 
    /************************************************************************************************/
      One_Two_Eight: begin

        if(f_128_q == 1'b0) begin 
          f_128_d =1'b1;  
        end else begin
          g_128_d = 1'b1;
        end

        address_alpha1 = 3'b100;
        wr_alpha1 = 1'b0; 
        wr_alpha2 = 1'b0; 
        fread_RAM = 2'b00; 
        update_reg1 = 1'b1; // now 64 calculated values are stored in the first register
        update_reg2 = 1'b0;
        choose_reg = 1'b1;
        choose_rdpattern = 3'b000;
        if(f_128_q == 1'b0) begin
          selectF_or_G = 1'b1; 
        end else begin
          selectF_or_G = 1'b0; 
          counter128g_d = counter128g_q + 1'b1; 
          for (int k = 0; k<40; k++) begin
            wire_k = k;
              if (counter128g_q == wire_k) begin
                s[63:0] = Memory_Beta_q[N-64-(2*k)*64 +: 64];   
              end
          end 
        end 
        state_d = Six_four;
      end
    /************************************************************************************************/
      Six_four:begin

        if(f_64_q == 1'b0) begin  
          f_64_d =1'b1; 
        end else begin
          g_64_d = 1'b1;
        end
        wr_alpha1 = 1'b0; 
        wr_alpha2 = 1'b0; 
         // we read the data (64 values) from the first register fread_RAM = 2'b10;
        update_reg1 = 1'b0;
        update_reg2 = 1'b1; // and write 32 values to the second register
        choose_reg = 1'b1;
        choose_rdpattern = 3'b001;
        //choose_wrpattern = 2'b00;
        if(f_64_q == 1'b0) begin
          fread_RAM = 2'b10; 
          selectF_or_G = 1'b1; 
        end else begin
          fread_RAM = 2'b01;
          //fread_RAM = 2'b10; // delete11
          choose_rdpattern = 3'b001;
          selectF_or_G = 1'b0; 
          counter64g_d = counter64g_q + 1'b1; 
          for (int k = 0; k<40; k++) begin
            wire_k = k;
              if (counter64g_q == wire_k) begin
                s[63:32] = Memory_Beta_q[N-32-(2*k)*32 +: 32];    
              end
          end
          s[31:0] = '0; 
        end 
        state_d = Three_Two;
      end
    /************************************************************************************************/
      Three_Two:begin
        if(f_32_q == 1'b0) begin  
          f_32_d = 1'b1;  
        end else begin
          g_32_d = 1'b1;
        end
        wr_alpha1 = 1'b0; 
        wr_alpha2 = 1'b1; 
        address_alpha2 = 2'b10;
        fread_RAM = 2'b11; // we read the data (32 values) from the second register 
        update_reg1 = 1'b0;
        update_reg2 = 1'b0; 
        choose_reg = 1'b1; 
        choose_rdpattern = 3'b010;
        choose_wrpattern = 2'b01; // we write 64 (old) + 16 (fresh) into alpha 2 memory under 10 address
        if(f_32_q == 1'b0) begin
          selectF_or_G = 1'b1; 
        end else begin
          selectF_or_G = 1'b0;  
          counter32g_d = counter32g_q + 1'b1; 
          for (int k = 0; k<40; k++) begin
            wire_k = k;
              if (counter32g_q == wire_k) begin
                s[63:48] = Memory_Beta_q[N-16-(2*k)*16 +: 16];    
              end
          end
          s[47:0] = '0; 
        end 
        state_d = One_Six;  
      end
    /************************************************************************************************/
      One_Six:begin
        //counterFrozen_d = counterFrozen_q + 1'b1;
        if(f_16_q == 1'b0) begin  
          f_16_d =1'b1; 
        end else begin
          g_16_d = 1'b1;
        end
        wr_alpha1 = 1'b1; 
        wr_alpha2 = 1'b0; 
        address_alpha1 = 3'b101;
        address_alpha2 = 2'b10;
        fread_RAM = 2'b01; // we take 16 values from alpha2 memory
        update_reg1 = 1'b0;
        update_reg2 = 1'b0; 
        choose_reg = 1'b0; // and collect previously stored 32 values from the second register
        choose_rdpattern = 3'b011;
        choose_wrpattern = 2'b10; // we write 32 (old) + 8 (fresh) into alpha 2 memory under 10 address
        if(f_16_q == 1'b0) begin
          selectF_or_G = 1'b1; 
        end else begin
          selectF_or_G = 1'b0; 
          counter16g_d = counter16g_q + 1'b1; 
          for (int k = 0; k<40; k++) begin
            wire_k = k;
            if (counter16g_q == wire_k) begin
              s[63:56] = Memory_Beta_q[N-8-(2*k)*8 +: 8];   
            end
          end
          s[55:0] = '0; 
          
        end 
        state_d = Eight;
        counterFrozen_d = counterFrozen_q  + 1'b1; 
        for (int k = 0; k<64; k++) begin
          wire_k = k;
          if (counterFrozen_q == wire_k) begin
            frozenBits_d = frozen[504 - 8*k +: 8]; 
          end
        end
      end
    /************************************************************************************************/
      Eight:begin

        address_alpha1 = 3'b101; // we read 8 LLRs from the AlphaMemory1 

        if (f_8_q == 1'b0) begin  
          f_8_d = 1'b1; // indicated that F accelerator has been already run for these 8 LLRs 
        end 
  
        if ((f_8_q == 1'b0) && (frozenBits_q[7:4] != 4'b1111)) begin // if F accelerator has not been executed yet, then we run it. However, we skipped the execution if there are four consecutive frozen bits
          counter_8f_d = counter_8f_q + 1'b1; // we count how many times F Accelerator has been executed in the decoding process
          for (int k = 0; k<100; k++) begin
            wire_k = k;
              if (counter_8f_q == wire_k) begin
                tempoutput_f[0] = facc4temp_o; // results from the F accelerator 
                tempoutput_f[1] = facc3temp_o;
                tempoutput_f[2] = facc2temp_o;
                tempoutput_f[3] = facc1temp_o;
                Memory_Beta_d[N-4-(k*8) +: 4] = o_4; // we store partial sums 
                Output_reg_d[N-4-(k*8) +: 4] = tempoutput_f; // we update the output register
              end
          end
          state_d = Eight;
        end else begin // if we encountered 4 frozen bits or if F accelerator has already been executed on these 8 LLRs, then we run G Accelerator
          if (frozenBits_q[7:4] == 4'b1111) begin  //if we encounter four consecutive frozen bits 
            for (int k = 0; k < 100; k++) begin
              wire_k = k;
              if (counter_8f_q == wire_k) begin
                Memory_Beta_d[N-4-(k*8) +: 4] = '0; // we update memory beta with zero partial sums
                Output_reg_d[N-4-(k*8) +: 4] = '0; // we update the output register with four zeros
                s_set_to_zeros = 1'b1; // we set to zero all the partial sums required by the G Accelerator  
                counter_8f_d = counter_8f_q + 1'b1; 
              end
            end
          end

          counter_8g_d = counter_8g_q + 1'b1; // we count how many times G Accelerator has been executed in the decoding process
          for (int k = 0; k<100; k++) begin
            wire_k = k;
              if (counter_8g_q == wire_k) begin
                tempoutput_g[0] = gacc4temp_o;// results from the G accelerator 
                tempoutput_g[1] = gacc3temp_o;
                tempoutput_g[2] = gacc2temp_o;
                tempoutput_g[3] = gacc1temp_o;
                Output_reg_d[N-8-(k*8) +: 4] = tempoutput_g; // we update the output register
              end
          end

          //Then we update partial sums in memory beta
          r_4 = combine_g4;
          r_8 = o_8;
          r_16 = o_16;
          r_32 = o_32;
          r_64 = o_64;
          r_128 = o_128;
          for (int k = 0; k<100; k++) begin
            wire_k = k;
            if (counter_8c_q == wire_k) begin
              l_4 = Memory_Beta_q[N-4-(k*8) +: 4]; 
            end
            if (counter_16c_q == wire_k) begin
              l_8 = Memory_Beta_q[N-8-(k*16) +: 8];         
            end
            if (counter_32c_q == wire_k) begin
              l_16 = Memory_Beta_q[N-16-(k*32) +: 16];  
            end
            if (counter_64c_q == wire_k) begin
              l_32 = Memory_Beta_q[N-32-(k*64) +: 32];  
            end
            if (counter_128c_q == wire_k) begin
              l_64 = Memory_Beta_q[N-64-(k*128) +: 64]; 
            end
            if (counter_256c_q == wire_k) begin
              l_128 = Memory_Beta_q[N-128-(k*256) +: 128]; 
            end
          end
    
          if (g_16_q == 1'b0) begin // if the G block has not processed 16 LLRs yet
            f_8_d = 1'b0; // we reset all states below "16" 
            state_d = One_Six; // then we go to the "16" state
            counter_8c_d = counter_8c_q + 1'b1;
            for (int k = 0; k<100; k++) begin
              wire_k = k;
              if (counter_8c_q == wire_k) begin
                Memory_Beta_d[N-8-(k*8) +: 8]= o_8; 
              end
            end
          end else if (g_32_q == 1'b0) begin // if the G block has not processed 32 LLRs yet
            f_16_d = 1'b0; // we reset all states below "32"
            g_16_d = 1'b0;
            f_8_d = 1'b0;
            state_d = Three_Two;
            counter_8c_d = counter_8c_q + 1'b1;
            counter_16c_d = counter_16c_q + 1'b1;
            for (int k = 0; k<100; k++) begin
              wire_k = k;
              if (counter_16c_q == wire_k) begin
                Memory_Beta_d[N-16-(k*16) +: 16]= o_16; 
              end
            end
          end else if (g_64_q == 1'b0) begin 
            f_32_d = 1'b0;
            g_32_d=1'b0;
            f_16_d = 1'b0;
            g_16_d=1'b0;
            f_8_d = 1'b0;
            state_d = Six_four;
            counter_8c_d = counter_8c_q + 1'b1;
            counter_16c_d = counter_16c_q + 1'b1;
            counter_32c_d = counter_32c_q + 1'b1;
            for (int k = 0; k<100; k++) begin
              wire_k = k;
              if (counter_32c_q == wire_k) begin
                Memory_Beta_d[N-32-(k*32) +: 32]= o_32; 
              end
           end
          end else if (g_128_q == 1'b0) begin 
            f_64_d = 1'b0;
            g_64_d = 1'b0;
            f_32_d = 1'b0;
            g_32_d = 1'b0;
            f_16_d = 1'b0;
            g_16_d = 1'b0;
            f_8_d = 1'b0;
            state_d = One_Two_Eight;
            counter_8c_d = counter_8c_q + 1'b1;
            counter_16c_d = counter_16c_q + 1'b1;
            counter_32c_d = counter_32c_q + 1'b1;
            counter_64c_d = counter_64c_q + 1'b1;
            for (int k = 0; k<100; k++) begin
              wire_k = k;
              if (counter_64c_q == wire_k) begin
                Memory_Beta_d[N-64-(k*64) +: 64]= o_64; 
              end
            end
          end else if (g_256_q == 1'b0) begin 
            f_128_d = 1'b0;
            g_128_d = 1'b0;
            f_64_d = 1'b0;
            g_64_d = 1'b0;
            f_32_d = 1'b0;
            g_32_d = 1'b0;
            f_16_d = 1'b0;
            g_16_d = 1'b0;
            f_8_d = 1'b0;
            state_d = Two_Five_six; 
            counter_8c_d = counter_8c_q + 1'b1;
            counter_16c_d = counter_16c_q + 1'b1;
            counter_32c_d = counter_32c_q + 1'b1;
            counter_64c_d = counter_64c_q + 1'b1;
            counter_128c_d = counter_128c_q + 1'b1;
            for (int k = 0; k<100; k++) begin
              wire_k = k;
              if (counter_128c_q == wire_k) begin
                Memory_Beta_d[N-128-(k*128) +: 128]= o_128; 
              end
            end 
          end else if (g_512_q == 1'b0) begin 
            f_256_d = 1'b0;
            g_256_d = 1'b0;
            f_128_d = 1'b0;
            g_128_d = 1'b0;
            f_64_d = 1'b0;
            g_64_d = 1'b0;
            f_32_d = 1'b0;
            g_32_d = 1'b0;
            f_16_d = 1'b0;
            g_16_d = 1'b0;
            f_8_d = 1'b0;
            state_d = Five_one_two;   
            counter_8c_d = counter_8c_q + 1'b1;
            counter_16c_d = counter_16c_q + 1'b1;
            counter_32c_d = counter_32c_q + 1'b1;
            counter_64c_d = counter_64c_q + 1'b1;
            counter_128c_d = counter_128c_q + 1'b1;
            counter_256c_d = counter_256c_q + 1'b1; 
            for (int k = 0; k<100; k++) begin
              wire_k = k;
              if (counter_256c_q == wire_k) begin
                Memory_Beta_d[N-256-(k*256) +: 256]= o_256; 
              end
            end
          end
        
        // reset sygnals and go back to the Idle state when the decoding process finishes 
          if ((control_512 == 1'b1 && g_16_q == 1'b1 && g_32_q == 1'b1 && g_64_q == 1'b1 && g_128_q == 1'b1 && g_256_q == 1'b1 && g_512_q == 1'b1) || 
            (control_256 == 1'b1 && g_16_q == 1'b1 && g_32_q == 1'b1 && g_64_q == 1'b1 && g_128_q == 1'b1 && g_256_q == 1'b1) || 
            (control_128 == 1'b1 && g_16_q == 1'b1 && g_32_q == 1'b1 && g_64_q == 1'b1 && g_128_q == 1'b1) ||
            (control_64 == 1'b1 && g_16_q == 1'b1 && g_32_q == 1'b1 && g_64_q == 1'b1) ||
            (control_32 == 1'b1 && g_16_q == 1'b1 && g_32_q == 1'b1)) begin
            state_d = Idle;
            ready_d=1'b1;
            f_512_d = 1'b0;
            g_512_d=1'b0;   
            f_256_d = 1'b0;
            g_256_d=1'b0;
            f_128_d = 1'b0;
            g_128_d=1'b0;
            f_64_d = 1'b0;
            g_64_d=1'b0;
            f_32_d = 1'b0;
            g_32_d=1'b0;
            f_16_d = 1'b0;
            g_16_d=1'b0;
            f_8_d = 1'b0;
            Memory_Beta_d ='0;
            counter_8f_d = '0;
            counter_8g_d = '0;
            counter_8c_d = '0;
            counter_16c_d = '0;
            counter_32c_d = '0;
            counter_64c_d = '0;
            counter_128c_d = '0;
            counter_256c_d = '0;
            counter512f_d = '0;
            counter256f_d = '0;
            counter512g_d = '0;
            counter256g_d = '0;
            counter128g_d = '0;
            counter64g_d = '0;
            counter32g_d = '0;
            counter16g_d = '0;
            counter256gg_d = '0;
            counterFrozen_d = '0;
            frozenBits_d = '0;
            additional_latency_d = '0;
          end 
        end // g accelerator
      end // eight state
    endcase // state_q
  end 




  /***********************************Sequential Logic*************************************************************/
  always_ff @(posedge clk_i, negedge rst_ni)begin
    if(~rst_ni) begin
      counterFrozen_q <= '0;
      frozenBits_q <= '0;
      checkcounter_q <= '0;
      s20_q <= '0; 
      s21_q <= '0;
      s22_q <= '0; 
      s23_q <= '0; 
      counter_ccc_q <= '0;
      counter512f_q <= '0; 
      counter256f_q <= '0; 
      counter512g_q <= '0; 
      counter256g_q <= '0; 
      counter128g_q <= '0; 
      counter64g_q <= '0; 
      counter32g_q <= '0; 
      counter16g_q <= '0; 
      counter256gg_q <= '0; 
      load_counter_q <= '0; 
      state_q <= Idle;
      f_512_q <= 1'b0;
      f_256_q <= 1'b0;
      f_128_q <= 1'b0;
      f_64_q <= 1'b0;
      f_32_q <= 1'b0;
      f_16_q <= 1'b0;
      f_8_q <= 1'b0;
      g_512_q <= 1'b0;
      g_256_q <= 1'b0;
      g_128_q <= 1'b0;
      g_64_q <= 1'b0;
      g_32_q <= 1'b0;
      g_16_q <= 1'b0;
      counter_8f_q <= '0;
      counter_8g_q <= '0;
      Output_reg_q <= '0;
      Memory_Beta_q<= '0;
      counter_8c_q <= '0;
      counter_16c_q <= '0;
      counter_32c_q <= '0;
      counter_64c_q <= '0;
      counter_128c_q <='0;
      counter_256c_q <='0;
      ready_q <='0; 
      additional_latency_q <= '0;
      reg1_q <= '0;
      reg2_q <= '0;
    end else begin
      additional_latency_q <= additional_latency_d;
      checkcounter_q <= checkcounter_d;
      counterFrozen_q <= counterFrozen_d;
      frozenBits_q <= frozenBits_d;
      s20_q <= s20_d; 
      s21_q <= s21_d;
      s22_q <= s22_d; 
      s23_q <= s23_d; 
      counter_ccc_q <= counter_ccc_d;
      counter512f_q <= counter512f_d; 
      counter256f_q <= counter256f_d; 
      counter512g_q <= counter512g_d; 
      counter256g_q <= counter256g_d; 
      counter128g_q <= counter128g_d; 
      counter64g_q <= counter64g_d; 
      counter32g_q <= counter32g_d; 
      counter16g_q <= counter16g_d; 
      counter256gg_q <= counter256gg_d; 
      load_counter_q <= load_counter_d; 
      counter_8f_q <= counter_8f_d;
      counter_8g_q <= counter_8g_d;
      Output_reg_q <= Output_reg_d;
      Memory_Beta_q <= Memory_Beta_d;
      counter_8c_q <= counter_8c_d;
      counter_16c_q <= counter_16c_d;
      counter_32c_q <= counter_32c_d;
      counter_64c_q <= counter_64c_d;
      counter_128c_q <= counter_128c_d;
      counter_256c_q <= counter_256c_d;
      state_q <= state_d;
      f_512_q <= f_512_d;
      f_256_q <= f_256_d;
      f_128_q <= f_128_d;
      f_64_q <= f_64_d;
      f_32_q <= f_32_d;
      f_16_q <= f_16_d;
      f_8_q <= f_8_d;
      g_512_q <= g_512_d;
      g_256_q <= g_256_d;
      g_128_q <= g_128_d;
      g_64_q <= g_64_d;
      g_32_q <= g_32_d;
      g_16_q <= g_16_d;
      ready_q <= ready_d; 
      reg1_q <= reg1_d;
      reg2_q <= reg2_d;
    end
  end
endmodule 



