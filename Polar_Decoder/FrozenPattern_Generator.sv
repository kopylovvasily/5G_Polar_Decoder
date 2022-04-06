// the module returns the frozen bits positions for the given values of K and E 

module FrozenPattern_Generator #(
  parameter int Bitwidth = 10
) (
  input logic frozen_start, // when applied, the generation begins 
  input logic clk_i,
  input logic rst_ni,
  input logic [8:0] K_i, 
  input logic [14:0] E_i, 
  output logic [511:0] frozen512_o, // the bus with results, updated with new values at each clock cycle (at the "Generation" step)
  output logic [2:0] N_o
);


  // Inputs and outputs of 2048 9-bit equality checks
  logic [511:0][Bitwidth-1:0] c1comp1_in1, c1comp1_in2;
  logic [511:0] c1comp1_out;
  logic [511:0][Bitwidth-1:0] c2comp1_in1, c2comp1_in2;
  logic [511:0] c2comp1_out;
  logic [511:0][Bitwidth-1:0] c3comp1_in1, c3comp1_in2;
  logic [511:0] c3comp1_out;
  logic [511:0][Bitwidth-1:0] c4comp1_in1, c4comp1_in2;
  logic [511:0] c4comp1_out;

  // inputs and outputs of 64 9-bit comparators 
  logic [63:0][Bitwidth-1:0] comp2_in1, comp2_in2;
  logic [Bitwidth-1:0] ulim;
  logic [63:0] comp2_out; 

  // inputs and outputs of 4 9-bit comparators 
  logic [3:0][Bitwidth-1:0] comp3_in1, comp3_in2;
  logic [Bitwidth-1:0] NE_sub; 
  logic [3:0] comp3_out; 

  // inputs and outputs of OR gates
  logic [511:0] or_in1, or_out1;
  logic [511:0] or_in2, or_out2;
  logic [511:0] or_in3, or_out3;
  logic [511:0] or_in4, or_out4;

  // sygnals for the "memory" and "genN" modules 
  logic [2:0] N_int; 
  logic [511:0][Bitwidth-1:0] Reliability_Sequence_512;
  logic [511:0] jn_init;
  logic [511:0][Bitwidth-1:0] jntable;
  logic [5:0] jn_addr;


  /////////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////   INSTANTIATION //////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////////////

  // 1) We instantiate "getN" and "memory_Vasily" modules
  memory_Frozen memory(
    .N_i(N_int),
    .index_i(jn_addr),
    .Jn_row_o(jn_init),
    .Jn_Sequence_o(jntable),
    .Reliability_Sequence_o(Reliability_Sequence_512)
  );


  getN getN(
    .K_i(K_i),
    .E_i(E_i), 
    .N_o(N_int) 
  );


  // 2) We instantiate 2048 9-bit equality checks
  genvar i; 
  generate
    for(i=0; i<512; i++) begin
      assign c1comp1_out[i] = (c1comp1_in1[i] == c1comp1_in2[i]);
    end
  endgenerate


  generate
    for(i=0; i<512; i++) begin
      assign c2comp1_out[i] = (c2comp1_in1[i] == c2comp1_in2[i]);
    end
  endgenerate


  generate
    for(i=0; i<512; i++) begin
      assign c3comp1_out[i] = (c3comp1_in1[i] == c3comp1_in2[i]);
    end
  endgenerate


  generate
    for(i=0; i<512; i++) begin
      assign c4comp1_out[i] = (c4comp1_in1[i] == c4comp1_in2[i]);
    end
  endgenerate

  // Reliability Sequence is the input of each of 4 blocks of 512 9-bit equality checks 
  assign c1comp1_in1 = Reliability_Sequence_512; 
  assign c2comp1_in1 = Reliability_Sequence_512;
  assign c3comp1_in1 = Reliability_Sequence_512;
  assign c4comp1_in1 = Reliability_Sequence_512;


  // 3) We instantiate 64 9-bit comparators 
  generate
    for(i=0; i<64; i++) begin
      assign comp2_in1[i] = ulim;
      assign comp2_out[i] = (comp2_in1[i] > comp2_in2[i]);
    end
  endgenerate

  // 4) We instantiate additional 4 9-bit comparators (>) 
  generate
    for(i=0; i<4; i++) begin
      assign comp3_in1[i] = NE_sub;
      assign comp3_out[i] = (comp3_in1[i] > comp3_in2[i]);
    end
  endgenerate

  // 5) We instantiate 2048 1-bit OR gates
  generate
    for(i=1; i<512; i++) begin
      assign or_out1[i-1] = (or_in1[i-1] | or_out1[i]); // Example: "0001000000000" -> "0001111111111" (makes rightmost guys from one to be ones)
    end
  endgenerate

  generate
    for(i=1; i<512; i++) begin
      assign or_out2[i-1] = (or_in2[i-1] | or_out2[i]);
    end
  endgenerate

  generate
    for(i=1; i<512; i++) begin
      assign or_out3[i-1] = (or_in3[i-1] | or_out3[i]);
    end
  endgenerate

  generate
    for(i=1; i<512; i++) begin
      assign or_out4[i-1] = (or_in4[i-1] | or_out4[i]);
    end
  endgenerate

  assign or_in1 = c1comp1_out[511:0]; // the "1" at c1comp1_out[511:0] indicates the position of a certain bit in the reliability sequence 
  assign or_in2 = c2comp1_out[511:0];
  assign or_in3 = c3comp1_out[511:0];
  assign or_in4 = c4comp1_out[511:0];

  assign or_out1[511] = or_in1[511]; 
  assign or_out2[511] = or_in2[511]; 
  assign or_out3[511] = or_in3[511]; 
  assign or_out4[511] = or_in4[511]; 

  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////// END OF INSTANTIATION /////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////////////



  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////// DATAPATH /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////////////

  assign N_o = N_int;

  logic [511:0] frozen512_d, frozen512_q;
  assign frozen512_o = frozen512_q; // the most important sygnal of the module - output of the decoder 

  logic [10:0] counter_gen_d, counter_gen_q;
  logic [7:0][Bitwidth-1:0] fr; // array of 8 bits positions, we want to know if those are frozen or not 

  logic [Bitwidth-1:0] N_i;
  always_comb begin
	// uncomment these if you desire skipping cycles at the beginning (for future implementation)
   // if (N_i == 10'd512) begin 
     // fr[0] = counter_gen_q * 8 + 11'd40;
    //end else begin 
      fr[0] = counter_gen_q * 8;
   // end
  end 

  //assign fr[0] = counter_gen_q * 8 + 11'd32; // fr[0] changes every two cycles (in the "Generation" state)
  assign fr[1] = fr[0] + 1'b1; // the rest positions are assigned sequentially
  assign fr[2] = fr[1] + 1'b1;
  assign fr[3] = fr[2] + 1'b1;
  assign fr[4] = fr[3] + 1'b1;
  assign fr[5] = fr[4] + 1'b1;
  assign fr[6] = fr[5] + 1'b1;
  assign fr[7] = fr[6] + 1'b1;


  assign NE_sub = N_i - E_i; 

  logic if_shortening;
  assign if_shortening = ((K_i * 16) > (E_i * 7)); // if true then shortening else puncturing

  logic [14:0] mult1, mult2, mult3, mult4; 
  logic [Bitwidth-1:0] ulim1, ulim2;
  assign ulim = (mult1 > E_i) ? ulim2 : ulim1;  // ulim is only used in case of puncturing
  assign ulim1 = mult1 - mult2; 
  assign ulim2 = mult3 - mult4; 
  assign mult1 = 3*N_i/4; 
  assign mult2 = E_i/2; 
  assign mult3 = 9*N_i/16; 
  assign mult4 = E_i/4; 

  // every clock cycle we compute frozen bits decisions for 4 bits, they are "frozen1", "frozen2", "frozen3", "frozen4"
  // frozen512_q resiters update every two clock cycles with new 4 decisions ("frozen1", "frozen2", "frozen3", "frozen4") and old 4 decisions (fr_q)
  logic frozen1, frozen2, frozen3, frozen4;
  logic [3:0] fr_d, fr_q; 
  logic [7:0 ] fr_o; 
  assign fr_o[7] = fr_q[3];
  assign fr_o[6] = fr_q[2];
  assign fr_o[5] = fr_q[1];
  assign fr_o[4] = fr_q[0];
  assign fr_o[3] = frozen1;
  assign fr_o[2] = frozen2;
  assign fr_o[1] = frozen3;
  assign fr_o[0] = frozen4;

  // the bit is frozen if it has already been found to be frozen during "Preparation" stage (prefrozen_q)
  // OR it is not among K top reliabile bits, and therefore it cannot carry information (if_frozen)    
  logic if_frozen1, if_frozen2, if_frozen3, if_frozen4;
  logic prefrozen1_d, prefrozen2_d, prefrozen3_d, prefrozen4_d;
  logic prefrozen1_q, prefrozen2_q, prefrozen3_q, prefrozen4_q;
  assign frozen1 = prefrozen1_q | if_frozen1; 
  assign frozen2 = prefrozen2_q | if_frozen2;
  assign frozen3 = prefrozen3_q | if_frozen3;
  assign frozen4 = prefrozen4_q | if_frozen4;

  logic [Bitwidth-1:0] number_of_inf_bits_above_frozen1; 
  logic [Bitwidth-1:0] number_of_inf_bits_above_frozen2; 
  logic [Bitwidth-1:0] number_of_inf_bits_above_frozen3; 
  logic [Bitwidth-1:0] number_of_inf_bits_above_frozen4; 
  assign if_frozen1 = (number_of_inf_bits_above_frozen1 > K_i); // if a bit is not among top K reliable bits then it is frozen
  assign if_frozen2 = (number_of_inf_bits_above_frozen2 > K_i); 
  assign if_frozen3 = (number_of_inf_bits_above_frozen3 > K_i); 
  assign if_frozen4 = (number_of_inf_bits_above_frozen4 > K_i); 


  logic [Bitwidth-1:0] countedones1, countedones2, countedones3, countedones4;
  logic [Bitwidth-1:0] ones_final1, ones_final2, ones_final3, ones_final4; 
  assign number_of_inf_bits_above_frozen1 = countedones1 + ones_final1; // the number of bits that are more reliable than a certain bit
  assign number_of_inf_bits_above_frozen2 = countedones2 + ones_final2;
  assign number_of_inf_bits_above_frozen3 = countedones3 + ones_final3;
  assign number_of_inf_bits_above_frozen4 = countedones4 + ones_final4;

  logic [127:0] countme1_in, countme2_in, countme3_in, countme4_in;
  assign countedones1 = $unsigned($countones(countme1_in)); // each takes 5000 area; counts number of ones in 128 bits sequence
  assign countedones2 = $unsigned($countones(countme2_in)); // each takes 5000 area; counts number of ones in 128 bits sequence
  assign countedones3 = $unsigned($countones(countme3_in)); // each takes 5000 area; counts number of ones in 128 bits sequence
  assign countedones4 = $unsigned($countones(countme4_in)); // each takes 5000 area; counts number of ones in 128 bits sequence

  // during the "Preparation" step we count only number of information bits in prefrozen_array_q
  // during the "Generation" step we count number of information bits that are more reliably than each of four bits (countme1, countme2, countme3, countme4)
  logic count_prep; 
  logic [127:0] countme1, countme2, countme3, countme4;
  logic [511:0] prefrozen_array_d, prefrozen_array_q; 
  assign countme1_in = (count_prep == '0) ? countme1 : ~prefrozen_array_q[127:0]; 
  assign countme2_in = (count_prep == '0) ? countme2 : ~prefrozen_array_q[255:128]; 
  assign countme3_in = (count_prep == '0) ? countme3 : ~prefrozen_array_q[383:256]; 
  assign countme4_in = countme4;

  logic [511:0] countme1_d, countme2_d, countme3_d, countme4_d; 
  logic [511:0] countme1_q, countme2_q, countme3_q, countme4_q;
  logic [1:0] locator1_d, locator2_d, locator3_d, locator4_d;
  logic [1:0] locator1_q, locator2_q, locator3_q, locator4_q;
  assign countme1 = (locator1_q == 2'b00) ? countme1_q[127:0] : (locator1_q == 2'b01) ? countme1_q[255:128] : (locator1_q == 2'b10) ? countme1_q[383:256] : countme1_q[511:384];  
  assign countme2 = (locator2_q == 2'b00) ? countme2_q[127:0] : (locator2_q == 2'b01) ? countme2_q[255:128] : (locator2_q == 2'b10) ? countme2_q[383:256] : countme2_q[511:384];  
  assign countme3 = (locator3_q == 2'b00) ? countme3_q[127:0] : (locator3_q == 2'b01) ? countme3_q[255:128] : (locator3_q == 2'b10) ? countme3_q[383:256] : countme3_q[511:384];  
  assign countme4 = (locator4_q == 2'b00) ? countme4_q[127:0] : (locator4_q == 2'b01) ? countme4_q[255:128] : (locator4_q == 2'b10) ? countme4_q[383:256] : countme4_q[511:384];  

  // we are not interested in the bits of prefrozen_array_q which are less reliable that the current bit 
  // therefore we perform AND operation to get rid of them
  assign countme1_d = or_out1 & ~prefrozen_array_q; // we put a register here to cut the longest path; therefore we introduce 1 clock delay
  assign countme2_d = or_out2 & ~prefrozen_array_q;
  assign countme3_d = or_out3 & ~prefrozen_array_q;
  assign countme4_d = or_out4 & ~prefrozen_array_q;

  // locator finds to which 128 block of the Reliability Sequence the current bit belongs 
  assign locator1_d = (or_out1[255:128] == '0) ? 2'b00 : (or_out1[383:256] == '0) ? 2'b01 : (or_out1[511:384] == '0) ? 2'b10 : 2'b11; 
  assign locator2_d = (or_out2[255:128] == '0) ? 2'b00 : (or_out2[383:256] == '0) ? 2'b01 : (or_out2[511:384] == '0) ? 2'b10 : 2'b11; 
  assign locator3_d = (or_out3[255:128] == '0) ? 2'b00 : (or_out3[383:256] == '0) ? 2'b01 : (or_out3[511:384] == '0) ? 2'b10 : 2'b11; 
  assign locator4_d = (or_out4[255:128] == '0) ? 2'b00 : (or_out4[383:256] == '0) ? 2'b01 : (or_out4[511:384] == '0) ? 2'b10 : 2'b11; 

  logic [Bitwidth-1:0] ones1_d, ones2_d, ones3_d;
  logic [Bitwidth-1:0] ones1_q, ones2_q, ones3_q;
  assign ones_final1 = (locator1_q == 2'b00) ? '0 : (locator1_q == 2'b01) ? ones1_q : (locator1_q == 2'b10) ? ones2_q : ones3_q; 
  assign ones_final2 = (locator2_q == 2'b00) ? '0 : (locator2_q == 2'b01) ? ones1_q : (locator2_q == 2'b10) ? ones2_q : ones3_q;  
  assign ones_final3 = (locator3_q == 2'b00) ? '0 : (locator3_q == 2'b01) ? ones1_q : (locator3_q == 2'b10) ? ones2_q : ones3_q;  
  assign ones_final4 = (locator4_q == 2'b00) ? '0 : (locator4_q == 2'b01) ? ones1_q : (locator4_q == 2'b10) ? ones2_q : ones3_q;  

  // ones1_d, ones2_d, ones3_d store the number of NOT Frozen bits in 1) prefrozen_array_q[127:0]; 2) prefrozen_array_q[255:0]
  // and prefrozen_array_q[383:0] respectively. Therefore, we don't need to count them during "Generation" step 
  assign ones1_d = (count_prep == '1) ? countedones1 : ones1_q; 
  assign ones2_d = (count_prep == '1) ? (countedones1 + countedones2) : ones2_q; 
  assign ones3_d = (count_prep == '1) ? (countedones1 + countedones2 + countedones3) : ones3_q; 

  logic [511:0] checkme1, checkme2, checkme3, checkme4;
  assign prefrozen1_d = (checkme1 != '0); 
  assign prefrozen2_d = (checkme2 != '0); 
  assign prefrozen3_d = (checkme3 != '0); 
  assign prefrozen4_d = (checkme4 != '0); 

  // c1comp1_out returns 512 sequence with a one at the position of the current bit
  assign checkme1 = c1comp1_out[511:0] & prefrozen_array_q; // if check is all zeros then the bit is not (yet) frozen according to the prefrozen_array
  assign checkme2 = c2comp1_out[511:0] & prefrozen_array_q;
  assign checkme3 = c3comp1_out[511:0] & prefrozen_array_q;
  assign checkme4 = c4comp1_out[511:0] & prefrozen_array_q;

  logic [511:0] ulim_out, jn_out;
  logic update_prefrozen; // if true then we are allowed to update the prefrozen_array 
  logic zeros_prefrozen; // if true then we fill the prefrozen_array with zeros
  assign prefrozen_array_d = (update_prefrozen == 1'b0) ? (prefrozen_array_q) : (zeros_prefrozen == 1'b1) ? ('0) : (ulim_out | jn_out | jn_init | prefrozen_array_q); //we don't update it after the Preparation step
  assign jn_out = (c1comp1_out[511:0] | c2comp1_out[511:0] | c3comp1_out[511:0] | c4comp1_out[511:0]);  

  logic [3:0][Bitwidth-1:0] jnjn, newjnjn;
  assign newjnjn[3] = (comp3_out[3] == 1'b1) ? jnjn[3] : 10'b1111111111; 
  assign newjnjn[2] = (comp3_out[2] == 1'b1) ? jnjn[2] : 10'b1111111111; 
  assign newjnjn[1] = (comp3_out[1] == 1'b1) ? jnjn[1] : 10'b1111111111; 
  assign newjnjn[0] = (comp3_out[0] == 1'b1) ? jnjn[0] : 10'b1111111111; 

  logic finish, finish512, finish256, finish128, finish64, finish32; 
  assign finish512 = ((counter_gen_q == 10'd64) && (N_int == 3'b110)); // finish if N = 512
  assign finish256 = ((counter_gen_q == 10'd32) && (N_int == 3'b101)); // finish if N = 256
  assign finish128 = ((counter_gen_q == 10'd16) && (N_int == 3'b100)); // finish if N = 128
  assign finish64 = ((counter_gen_q == 10'd8) && (N_int == 3'b011)); // finish if N = 64
  assign finish32 = ((counter_gen_q == 10'd4) && (N_int == 3'b010)); // finish if N = 32
  assign finish = finish512 || finish256 || finish128 || finish64 || finish32; // we finish the generation when either of these statements is true

  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////// END OF DATAPATH //////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////////////


  ///////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////// FSM  ///////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////////////////////


  logic [10:0] counter_d, counter_q;
  logic [31:0][Bitwidth-1:0] jn32seq;
  logic [Bitwidth-1:0] jn_precounted_d, jn_precounted_q;
  logic [Bitwidth-1:0] wire_i, wire_k;
  logic [511:0] jn_d, jn_q;

  typedef enum logic [2:0] {
  Preparation, 
  Generation,
  OnesGen,
  Idle
  } state_t;
  state_t state_d, state_q; 


  always_comb begin
    N_i = '0;
    jn_precounted_d = jn_precounted_q;
    jn32seq = '0;
    jn_addr = '0;
    state_d = state_q;
    jn_d = jn_q;
    fr_d = fr_q;
    frozen512_d = frozen512_q;
    counter_gen_d = counter_gen_q;
    counter_d = counter_q; 
    c1comp1_in2 = '0;
    c2comp1_in2 = '0;
    c3comp1_in2 = '0;
    c4comp1_in2 = '0;
    comp2_in2 = '0;
    comp3_in2 = '0;
    ulim_out = '0;
    jnjn = '0;
    update_prefrozen = '0;
    zeros_prefrozen = '0;
    count_prep = '0;

    if (N_int == 3'b110) begin // if N = 512 we choose the right jn32seq from the memory  
      N_i = 10'd512; 
      for(int i=0; i<16; i++) begin 
        wire_i = $unsigned(i); 
        if ((NE_sub > (10'd480 - wire_i*32)) && (NE_sub <= (10'd512 - wire_i*32))) begin 
          jn_precounted_d = (10'd480 - wire_i*32);
          if (if_shortening == 1'b1) begin //then shortening
            jn_addr = 6'd15 - wire_i; 
            jn32seq = jntable[480 - i*32 +: 32];  
          end else begin // else puncturing
            jn_addr = 6'd31 - wire_i; 
            jn32seq = jntable[i*32 +: 32];  
          end
        end
     end

    end else if (N_int == 3'b101) begin // if N = 256 we choose the right jn32seq from the memory  
      N_i = 10'd256; 
      for(int i=0; i<8; i++) begin 
        wire_i = $unsigned(i); 
        if ((NE_sub > (10'd224 - wire_i*32)) && (NE_sub <= (10'd256 - wire_i*32))) begin 
          jn_precounted_d = (10'd224 - wire_i*32);
          if (if_shortening == 1'b1) begin //then shortening
            jn_addr = 6'd7 - wire_i; 
            jn32seq = jntable[224 - i*32 +: 32];  
          end else begin // else puncturing
            jn_addr = 6'd15 - wire_i; 
            jn32seq = jntable[i*32 +: 32];  
          end
        end
      end
    end else if (N_int == 3'b100) begin // if N = 128 we choose the right jn32seq from the memory  
      N_i = 10'd128; 
      for(int i=0; i<4; i++) begin 
        wire_i = $unsigned(i); 
        if ((NE_sub > (10'd96 - wire_i*32)) && (NE_sub <= (10'd128 - wire_i*32))) begin 
          jn_precounted_d = (10'd96 - wire_i*32);
          if (if_shortening == 1'b1) begin //then shortening
            jn_addr = 6'd3 - wire_i; 
            jn32seq = jntable[96 - i*32 +: 32]; 
          end else begin // else puncturing
            jn_addr = 6'd7 - wire_i; 
            jn32seq = jntable[i*32 +: 32];  
          end
        end
      end
    end else if (N_int == 3'b011) begin // if N = 64 we choose the right jn32seq from the memory  
      N_i = 10'd64; 
      for(int i=0; i<2; i++) begin 
        wire_i = $unsigned(i); 
        if ((NE_sub > (10'd32 - wire_i*32)) && (NE_sub <= (10'd64 - wire_i*32))) begin 
          jn_precounted_d = (10'd32 - wire_i*32);
          if (if_shortening == 1'b1) begin //then shortening
            jn_addr = 6'd1 - wire_i; 
            jn32seq = jntable[32 - i*32 +: 32]; 
          end else begin // else puncturing
            jn_addr = 6'd3 - wire_i; 
            jn32seq = jntable[i*32 +: 32];  
          end
        end
      end
    end else if (N_int == 3'b010) begin // if N = 32 we choose the right jn32seq from the memory  
      N_i = 10'd32; 
      jn_precounted_d = '0;
      jn_addr = '0; 
      jn32seq = jntable[31:0];  
    end 


    case(state_q)
      Idle: begin //during the Idle state we wait for the frozen_start sygnal
        if (frozen_start == 1'b1) begin
          frozen512_d = '0; // we clear the register with the main result 
          if (N_i > E_i) begin
            state_d = Preparation; 
          end else begin
            state_d = Generation; // if E > N we don't need to "prepare"
          end
        end
      end // end of the Idle 

      Preparation: begin 
        count_prep = 1'b1;
        update_prefrozen = 1'b1; // during the Preparation stage we are updating the prefrozen array
        counter_d = counter_q + 1'b1;   
        ulim_out = '0;
        jn_precounted_d = jn_precounted_q + 10'd4;


        for(int i=0; i<8; i++) begin 
          wire_i = $unsigned(i); 
          if (counter_q == wire_i) begin
            comp2_in2 = Reliability_Sequence_512[448 - 64*i +: 64];
            if (if_shortening == 1'b0) begin 
              ulim_out[448 - 64*i +: 64] = comp2_out;
              jnjn = jn32seq[28 - i*4 +: 4];
            end else begin //shortening
              jnjn = jn32seq[i*4 +: 4];
            end
          end
        end

        if (counter_q == 10'd7) begin //after 8 clock cycles we go to the Generation step
          state_d = Generation;
          counter_d = '0;
          jn_precounted_d = '0;
        end


        for (int k = 0; k<512; k++) begin
          c1comp1_in2[k] = newjnjn[0];
          c2comp1_in2[k] = newjnjn[1];
          c3comp1_in2[k] = newjnjn[2];
          c4comp1_in2[k] = newjnjn[3];  
        end

          comp3_in2[3] = jn_precounted_q + 10'd3;
          comp3_in2[2] = jn_precounted_q + 10'd2;
          comp3_in2[1] = jn_precounted_q + 10'd1;
          comp3_in2[0] = jn_precounted_q + 10'd0;
      end // end of the Preparation

      Generation: begin
        counter_d = counter_q + 1'b1; 
        if (E_i > N_i) begin
          update_prefrozen = 1'b1;
          zeros_prefrozen = 1'b1;
        end 

        if (counter_gen_q == 11'd0) begin
          count_prep = 1'b1;
        end 

        if (counter_q == 10'd0) begin

          for (int k = 0; k<512; k++) begin
            c1comp1_in2[k] = fr[0]; // during first clock cycle we are interested in first 4 bits 
            c2comp1_in2[k] = fr[1];
            c3comp1_in2[k] = fr[2];
            c4comp1_in2[k] = fr[3];
          end

          for (int k = 1; k<65; k++) begin
            wire_k = $unsigned(k);
            if (counter_gen_q == wire_k) begin
              frozen512_d[512-8-((k-1)*8) +: 8]= fr_o; // we assign generated 8 frozen decisions to the right positions in frozen512_d
            end
          end

        end else if (counter_q == 10'd1) begin

          for (int k = 0; k<512; k++) begin
            c1comp1_in2[k] = fr[4]; // during second clock cycle we are interested in second 4 bits 
            c2comp1_in2[k] = fr[5];
            c3comp1_in2[k] = fr[6];
            c4comp1_in2[k] = fr[7];
          end

          fr_d[3] = frozen1; // these values will be written in frozen512_d during next clock cycle
          fr_d[2] = frozen2;
          fr_d[1] = frozen3;
          fr_d[0] = frozen4;

          counter_gen_d = counter_gen_q + 1'b1; // generation counter
          counter_d = '0;
     

          if (finish == 1'b1) begin
            state_d = Idle;
            counter_gen_d = '0;
            counter_d = '0;
            update_prefrozen = 1'b1;
            zeros_prefrozen = 1'b1;
          end
        end 
      end //Generation
    endcase
  end // always_comb

  ///////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////// END OF FSM  ////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////////////////////


  
  always_ff @(posedge clk_i, negedge rst_ni) begin
    if(~rst_ni) begin
      jn_precounted_q <= '0;
      prefrozen1_q <= '0;
      prefrozen2_q <= '0;
      prefrozen3_q <= '0;
      prefrozen4_q <= '0;
      counter_gen_q <= '0;
      counter_q <= '0;
      state_q <= Idle;
      prefrozen_array_q <= '0;
      jn_q <= '0;
      fr_q <= '0;
      countme1_q <= '0;
      countme2_q <= '0;
      countme3_q <= '0;
      countme4_q <= '0;
      frozen512_q <= '0;
      ones1_q <= '0;
      ones2_q <= '0;
      ones3_q <= '0;
      locator1_q <= '0;
      locator2_q <= '0;
      locator3_q <= '0;
      locator4_q <= '0;
    end else begin
      jn_precounted_q <= jn_precounted_d;
      prefrozen1_q <= prefrozen1_d;
      prefrozen2_q <= prefrozen2_d;
      prefrozen3_q <= prefrozen3_d;
      prefrozen4_q <= prefrozen4_d;
      counter_gen_q <= counter_gen_d;
      counter_q <= counter_d;
      state_q <= state_d;
      prefrozen_array_q <= prefrozen_array_d;
      jn_q <= jn_d;
      fr_q <= fr_d; 
      countme1_q <= countme1_d;
      countme2_q <= countme2_d;
      countme3_q <= countme3_d;
      countme4_q <= countme4_d;
      frozen512_q <= frozen512_d;
      ones1_q <= ones1_d;
      ones2_q <= ones2_d;
      ones3_q <= ones3_d;
      locator1_q <= locator1_d;
      locator2_q <= locator2_d;
      locator3_q <= locator3_d;
      locator4_q <= locator4_d;
    end
  end


endmodule 
