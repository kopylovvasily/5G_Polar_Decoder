module SC_512_decoder_tb ();

//responsible for timing
timeunit 1ns;
timeprecision 10ps;
localparam time HALF_PERIOD         = 2ns;
localparam time CLK_PERIOD          = 4ns;
localparam time APPL_DELAY          = 1ns;
localparam time ACQ_DELAY           = 3ns;
localparam unsigned RST_CLK_CYCLES  = 2;
localparam unsigned TOT_STIMS       = 10; // Define how much simvectors you will be applying
localparam unsigned TIMEOUT_LIM     = 1000; // Define how much time do you want your testbench to run
localparam unsigned BITWIDTH        = 7;
localparam unsigned N               = 512;
localparam unsigned BITWIDTH_REL    = 9;


logic [N-1:0][BITWIDTH-1:0] stim; //stimuli applied every 4 clock cycles to the device unnder test 
logic [N-1:0][BITWIDTH-1:0] stim_temp; //this keeps the same stimuli block for 4 consecutive clock cycles 
logic[N-1:0] act_resp,   // actual response
             acq_resp,   // acquired response
             exp_resp;   // expected response

//Those are using for counting along the testbench
integer clockcycle, 
        n_stims,
        n_checks,
        n_errs,
        n_timeout;

//Those signals are responsible for the Handshake with the Device Under Test    
logic ready;              
logic valid;

logic[N-1:0] queue_mon2chk[$]; // responsible to store the response from stimuli for a particular period of time

logic clk,
      stim_applied, //singlas if the stimuli is applied
      rst_n,
      next_stimuli, //proceed with next stimuli after 4 clock cycles
      end_of_stim; //stimuli is finished

//clock generation
initial begin:clk_gen
 do begin
     clk = 1'b1;
     #(HALF_PERIOD);
     clk = 1'b0;
     #(HALF_PERIOD);
 end while(!end_of_stim);
end

//reset generation
initial begin:rst_gen
 rst_n=1'b0;
 #((RST_CLK_CYCLES*CLK_PERIOD)+APPL_DELAY);
 rst_n=1'b1;
end

//Signals that will be attached to the device under test
logic[2:0] N_i; //It stores the N(number of coded bits) generated by the device under test
logic unsigned [8:0] K_i;
logic unsigned [14:0] E_i;

 
//Instantiation of the device under test 
SC_512_decoder dut (
  .K_i(K_i),
  .E_i(E_i),
  .valid_i (valid), 
  .clk_i   (clk),
  .rst_ni  (rst_n),
  .LLR_i   (stim),
  .decodedvalue_o(act_resp),
  .ready_o(ready),
  .N_i(N_i)
);


//At this block stimuli is applied at the device under test
initial begin: application_block
 
  integer stim_fd;
  integer ret_code;
  integer counter;
  stim_fd = $fopen("../simvectors/Ultimate_Stimuli_2.txt", "r"); //stimuli applied to the decice under test
  //stim_fd = $fopen("../simvectors/Latest_stimuli_512_2.txt", "r"); //stimuli applied to the decice under test
  if (stim_fd == 0) begin
      $fatal("Could not open stimuli file!");
  end
  next_stimuli=1'b0;
  counter =0;
  n_stims = 0;
  stim_applied = 0;
  stim = '0;
  end_of_stim ='0;
  clockcycle=0;
  valid=  '0;
  wait (rst_n);
  while (!$feof(stim_fd)) begin

    @(posedge clk);
    #(APPL_DELAY); 
    clockcycle = clockcycle+1;
    //it makes sure that new stimuli is applied every 4 clock cycles
    if(counter == 4) begin
      counter=0;
      next_stimuli = 1'b0;
      n_stims = n_stims + 1;
    end

    if(n_stims==0) begin
      if(counter == 0)begin
        ret_code = $fscanf(stim_fd, "%9d,%15d,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b\n",K_i,E_i,stim_temp[511], stim_temp[510], stim_temp[509], stim_temp[508], stim_temp[507], stim_temp[506], stim_temp[505], stim_temp[504], stim_temp[503], stim_temp[502], stim_temp[501], stim_temp[500], stim_temp[499], stim_temp[498], stim_temp[497], stim_temp[496], stim_temp[495], stim_temp[494], stim_temp[493], stim_temp[492], stim_temp[491], stim_temp[490], stim_temp[489], stim_temp[488], stim_temp[487], stim_temp[486], stim_temp[485], stim_temp[484], stim_temp[483], stim_temp[482], stim_temp[481], stim_temp[480], stim_temp[479], stim_temp[478], stim_temp[477], stim_temp[476], stim_temp[475], stim_temp[474], stim_temp[473], stim_temp[472], stim_temp[471], stim_temp[470], stim_temp[469], stim_temp[468], stim_temp[467], stim_temp[466], stim_temp[465], stim_temp[464], stim_temp[463], stim_temp[462], stim_temp[461], stim_temp[460], stim_temp[459], stim_temp[458], stim_temp[457], stim_temp[456], stim_temp[455], stim_temp[454], stim_temp[453], stim_temp[452], stim_temp[451], stim_temp[450], stim_temp[449], stim_temp[448], stim_temp[447], stim_temp[446], stim_temp[445], stim_temp[444], stim_temp[443], stim_temp[442], stim_temp[441], stim_temp[440], stim_temp[439], stim_temp[438], stim_temp[437], stim_temp[436], stim_temp[435], stim_temp[434], stim_temp[433], stim_temp[432], stim_temp[431], stim_temp[430], stim_temp[429], stim_temp[428], stim_temp[427], stim_temp[426], stim_temp[425], stim_temp[424], stim_temp[423], stim_temp[422], stim_temp[421], stim_temp[420], stim_temp[419], stim_temp[418], stim_temp[417], stim_temp[416], stim_temp[415], stim_temp[414], stim_temp[413], stim_temp[412], stim_temp[411], stim_temp[410], stim_temp[409], stim_temp[408], stim_temp[407], stim_temp[406], stim_temp[405], stim_temp[404], stim_temp[403], stim_temp[402], stim_temp[401], stim_temp[400], stim_temp[399], stim_temp[398], stim_temp[397], stim_temp[396], stim_temp[395], stim_temp[394], stim_temp[393], stim_temp[392], stim_temp[391], stim_temp[390], stim_temp[389], stim_temp[388], stim_temp[387], stim_temp[386], stim_temp[385], stim_temp[384], stim_temp[383], stim_temp[382], stim_temp[381], stim_temp[380], stim_temp[379], stim_temp[378], stim_temp[377], stim_temp[376], stim_temp[375], stim_temp[374], stim_temp[373], stim_temp[372], stim_temp[371], stim_temp[370], stim_temp[369], stim_temp[368], stim_temp[367], stim_temp[366], stim_temp[365], stim_temp[364], stim_temp[363], stim_temp[362], stim_temp[361], stim_temp[360], stim_temp[359], stim_temp[358], stim_temp[357], stim_temp[356], stim_temp[355], stim_temp[354], stim_temp[353], stim_temp[352], stim_temp[351], stim_temp[350], stim_temp[349], stim_temp[348], stim_temp[347], stim_temp[346], stim_temp[345], stim_temp[344], stim_temp[343], stim_temp[342], stim_temp[341], stim_temp[340], stim_temp[339], stim_temp[338], stim_temp[337], stim_temp[336], stim_temp[335], stim_temp[334], stim_temp[333], stim_temp[332], stim_temp[331], stim_temp[330], stim_temp[329], stim_temp[328], stim_temp[327], stim_temp[326], stim_temp[325], stim_temp[324], stim_temp[323], stim_temp[322], stim_temp[321], stim_temp[320], stim_temp[319], stim_temp[318], stim_temp[317], stim_temp[316], stim_temp[315], stim_temp[314], stim_temp[313], stim_temp[312], stim_temp[311], stim_temp[310], stim_temp[309], stim_temp[308], stim_temp[307], stim_temp[306], stim_temp[305], stim_temp[304], stim_temp[303], stim_temp[302], stim_temp[301], stim_temp[300], stim_temp[299], stim_temp[298], stim_temp[297], stim_temp[296], stim_temp[295], stim_temp[294], stim_temp[293], stim_temp[292], stim_temp[291], stim_temp[290], stim_temp[289], stim_temp[288], stim_temp[287], stim_temp[286], stim_temp[285], stim_temp[284], stim_temp[283], stim_temp[282], stim_temp[281], stim_temp[280], stim_temp[279], stim_temp[278], stim_temp[277], stim_temp[276], stim_temp[275], stim_temp[274], stim_temp[273], stim_temp[272], stim_temp[271], stim_temp[270], stim_temp[269], stim_temp[268], stim_temp[267], stim_temp[266], stim_temp[265], stim_temp[264], stim_temp[263], stim_temp[262], stim_temp[261], stim_temp[260], stim_temp[259], stim_temp[258], stim_temp[257], stim_temp[256], stim_temp[255], stim_temp[254], stim_temp[253], stim_temp[252], stim_temp[251], stim_temp[250], stim_temp[249], stim_temp[248], stim_temp[247], stim_temp[246], stim_temp[245], stim_temp[244], stim_temp[243], stim_temp[242], stim_temp[241], stim_temp[240], stim_temp[239], stim_temp[238], stim_temp[237], stim_temp[236], stim_temp[235], stim_temp[234], stim_temp[233], stim_temp[232], stim_temp[231], stim_temp[230], stim_temp[229], stim_temp[228], stim_temp[227], stim_temp[226], stim_temp[225], stim_temp[224], stim_temp[223], stim_temp[222], stim_temp[221], stim_temp[220], stim_temp[219], stim_temp[218], stim_temp[217], stim_temp[216], stim_temp[215], stim_temp[214], stim_temp[213], stim_temp[212], stim_temp[211], stim_temp[210], stim_temp[209], stim_temp[208], stim_temp[207], stim_temp[206], stim_temp[205], stim_temp[204], stim_temp[203], stim_temp[202], stim_temp[201], stim_temp[200], stim_temp[199], stim_temp[198], stim_temp[197], stim_temp[196], stim_temp[195], stim_temp[194], stim_temp[193], stim_temp[192], stim_temp[191], stim_temp[190], stim_temp[189], stim_temp[188], stim_temp[187], stim_temp[186], stim_temp[185], stim_temp[184], stim_temp[183], stim_temp[182], stim_temp[181], stim_temp[180], stim_temp[179], stim_temp[178], stim_temp[177], stim_temp[176], stim_temp[175], stim_temp[174], stim_temp[173], stim_temp[172], stim_temp[171], stim_temp[170], stim_temp[169], stim_temp[168], stim_temp[167], stim_temp[166], stim_temp[165], stim_temp[164], stim_temp[163], stim_temp[162], stim_temp[161], stim_temp[160], stim_temp[159], stim_temp[158], stim_temp[157], stim_temp[156], stim_temp[155], stim_temp[154], stim_temp[153], stim_temp[152], stim_temp[151], stim_temp[150], stim_temp[149], stim_temp[148], stim_temp[147], stim_temp[146], stim_temp[145], stim_temp[144], stim_temp[143], stim_temp[142], stim_temp[141], stim_temp[140], stim_temp[139], stim_temp[138], stim_temp[137], stim_temp[136], stim_temp[135], stim_temp[134], stim_temp[133], stim_temp[132], stim_temp[131], stim_temp[130], stim_temp[129], stim_temp[128], stim_temp[127], stim_temp[126], stim_temp[125], stim_temp[124], stim_temp[123], stim_temp[122], stim_temp[121], stim_temp[120], stim_temp[119], stim_temp[118], stim_temp[117], stim_temp[116], stim_temp[115], stim_temp[114], stim_temp[113], stim_temp[112], stim_temp[111], stim_temp[110], stim_temp[109], stim_temp[108], stim_temp[107], stim_temp[106], stim_temp[105], stim_temp[104], stim_temp[103], stim_temp[102], stim_temp[101], stim_temp[100], stim_temp[99], stim_temp[98], stim_temp[97], stim_temp[96], stim_temp[95], stim_temp[94], stim_temp[93], stim_temp[92], stim_temp[91], stim_temp[90], stim_temp[89], stim_temp[88], stim_temp[87], stim_temp[86], stim_temp[85], stim_temp[84], stim_temp[83], stim_temp[82], stim_temp[81], stim_temp[80], stim_temp[79], stim_temp[78], stim_temp[77], stim_temp[76], stim_temp[75], stim_temp[74], stim_temp[73], stim_temp[72], stim_temp[71], stim_temp[70], stim_temp[69], stim_temp[68], stim_temp[67], stim_temp[66], stim_temp[65], stim_temp[64], stim_temp[63], stim_temp[62], stim_temp[61], stim_temp[60], stim_temp[59], stim_temp[58], stim_temp[57], stim_temp[56], stim_temp[55], stim_temp[54], stim_temp[53], stim_temp[52], stim_temp[51], stim_temp[50], stim_temp[49], stim_temp[48], stim_temp[47], stim_temp[46], stim_temp[45], stim_temp[44], stim_temp[43], stim_temp[42], stim_temp[41], stim_temp[40], stim_temp[39], stim_temp[38], stim_temp[37], stim_temp[36], stim_temp[35], stim_temp[34], stim_temp[33], stim_temp[32], stim_temp[31], stim_temp[30], stim_temp[29], stim_temp[28], stim_temp[27], stim_temp[26], stim_temp[25], stim_temp[24], stim_temp[23], stim_temp[22], stim_temp[21], stim_temp[20], stim_temp[19], stim_temp[18], stim_temp[17], stim_temp[16], stim_temp[15], stim_temp[14], stim_temp[13], stim_temp[12], stim_temp[11], stim_temp[10], stim_temp[9], stim_temp[8], stim_temp[7], stim_temp[6], stim_temp[5], stim_temp[4], stim_temp[3], stim_temp[2], stim_temp[1], stim_temp[0]);   
      end 
      stim=stim_temp;                
      counter=counter+1;
      valid=1'b1;    
    end else begin
      if(ready == 1'b1 || next_stimuli == 1'b1) begin
        if(counter == 0)begin
          ret_code = $fscanf(stim_fd, "%9d,%15d,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b,%7b\n",K_i,E_i,stim_temp[511], stim_temp[510], stim_temp[509], stim_temp[508], stim_temp[507], stim_temp[506], stim_temp[505], stim_temp[504], stim_temp[503], stim_temp[502], stim_temp[501], stim_temp[500], stim_temp[499], stim_temp[498], stim_temp[497], stim_temp[496], stim_temp[495], stim_temp[494], stim_temp[493], stim_temp[492], stim_temp[491], stim_temp[490], stim_temp[489], stim_temp[488], stim_temp[487], stim_temp[486], stim_temp[485], stim_temp[484], stim_temp[483], stim_temp[482], stim_temp[481], stim_temp[480], stim_temp[479], stim_temp[478], stim_temp[477], stim_temp[476], stim_temp[475], stim_temp[474], stim_temp[473], stim_temp[472], stim_temp[471], stim_temp[470], stim_temp[469], stim_temp[468], stim_temp[467], stim_temp[466], stim_temp[465], stim_temp[464], stim_temp[463], stim_temp[462], stim_temp[461], stim_temp[460], stim_temp[459], stim_temp[458], stim_temp[457], stim_temp[456], stim_temp[455], stim_temp[454], stim_temp[453], stim_temp[452], stim_temp[451], stim_temp[450], stim_temp[449], stim_temp[448], stim_temp[447], stim_temp[446], stim_temp[445], stim_temp[444], stim_temp[443], stim_temp[442], stim_temp[441], stim_temp[440], stim_temp[439], stim_temp[438], stim_temp[437], stim_temp[436], stim_temp[435], stim_temp[434], stim_temp[433], stim_temp[432], stim_temp[431], stim_temp[430], stim_temp[429], stim_temp[428], stim_temp[427], stim_temp[426], stim_temp[425], stim_temp[424], stim_temp[423], stim_temp[422], stim_temp[421], stim_temp[420], stim_temp[419], stim_temp[418], stim_temp[417], stim_temp[416], stim_temp[415], stim_temp[414], stim_temp[413], stim_temp[412], stim_temp[411], stim_temp[410], stim_temp[409], stim_temp[408], stim_temp[407], stim_temp[406], stim_temp[405], stim_temp[404], stim_temp[403], stim_temp[402], stim_temp[401], stim_temp[400], stim_temp[399], stim_temp[398], stim_temp[397], stim_temp[396], stim_temp[395], stim_temp[394], stim_temp[393], stim_temp[392], stim_temp[391], stim_temp[390], stim_temp[389], stim_temp[388], stim_temp[387], stim_temp[386], stim_temp[385], stim_temp[384], stim_temp[383], stim_temp[382], stim_temp[381], stim_temp[380], stim_temp[379], stim_temp[378], stim_temp[377], stim_temp[376], stim_temp[375], stim_temp[374], stim_temp[373], stim_temp[372], stim_temp[371], stim_temp[370], stim_temp[369], stim_temp[368], stim_temp[367], stim_temp[366], stim_temp[365], stim_temp[364], stim_temp[363], stim_temp[362], stim_temp[361], stim_temp[360], stim_temp[359], stim_temp[358], stim_temp[357], stim_temp[356], stim_temp[355], stim_temp[354], stim_temp[353], stim_temp[352], stim_temp[351], stim_temp[350], stim_temp[349], stim_temp[348], stim_temp[347], stim_temp[346], stim_temp[345], stim_temp[344], stim_temp[343], stim_temp[342], stim_temp[341], stim_temp[340], stim_temp[339], stim_temp[338], stim_temp[337], stim_temp[336], stim_temp[335], stim_temp[334], stim_temp[333], stim_temp[332], stim_temp[331], stim_temp[330], stim_temp[329], stim_temp[328], stim_temp[327], stim_temp[326], stim_temp[325], stim_temp[324], stim_temp[323], stim_temp[322], stim_temp[321], stim_temp[320], stim_temp[319], stim_temp[318], stim_temp[317], stim_temp[316], stim_temp[315], stim_temp[314], stim_temp[313], stim_temp[312], stim_temp[311], stim_temp[310], stim_temp[309], stim_temp[308], stim_temp[307], stim_temp[306], stim_temp[305], stim_temp[304], stim_temp[303], stim_temp[302], stim_temp[301], stim_temp[300], stim_temp[299], stim_temp[298], stim_temp[297], stim_temp[296], stim_temp[295], stim_temp[294], stim_temp[293], stim_temp[292], stim_temp[291], stim_temp[290], stim_temp[289], stim_temp[288], stim_temp[287], stim_temp[286], stim_temp[285], stim_temp[284], stim_temp[283], stim_temp[282], stim_temp[281], stim_temp[280], stim_temp[279], stim_temp[278], stim_temp[277], stim_temp[276], stim_temp[275], stim_temp[274], stim_temp[273], stim_temp[272], stim_temp[271], stim_temp[270], stim_temp[269], stim_temp[268], stim_temp[267], stim_temp[266], stim_temp[265], stim_temp[264], stim_temp[263], stim_temp[262], stim_temp[261], stim_temp[260], stim_temp[259], stim_temp[258], stim_temp[257], stim_temp[256], stim_temp[255], stim_temp[254], stim_temp[253], stim_temp[252], stim_temp[251], stim_temp[250], stim_temp[249], stim_temp[248], stim_temp[247], stim_temp[246], stim_temp[245], stim_temp[244], stim_temp[243], stim_temp[242], stim_temp[241], stim_temp[240], stim_temp[239], stim_temp[238], stim_temp[237], stim_temp[236], stim_temp[235], stim_temp[234], stim_temp[233], stim_temp[232], stim_temp[231], stim_temp[230], stim_temp[229], stim_temp[228], stim_temp[227], stim_temp[226], stim_temp[225], stim_temp[224], stim_temp[223], stim_temp[222], stim_temp[221], stim_temp[220], stim_temp[219], stim_temp[218], stim_temp[217], stim_temp[216], stim_temp[215], stim_temp[214], stim_temp[213], stim_temp[212], stim_temp[211], stim_temp[210], stim_temp[209], stim_temp[208], stim_temp[207], stim_temp[206], stim_temp[205], stim_temp[204], stim_temp[203], stim_temp[202], stim_temp[201], stim_temp[200], stim_temp[199], stim_temp[198], stim_temp[197], stim_temp[196], stim_temp[195], stim_temp[194], stim_temp[193], stim_temp[192], stim_temp[191], stim_temp[190], stim_temp[189], stim_temp[188], stim_temp[187], stim_temp[186], stim_temp[185], stim_temp[184], stim_temp[183], stim_temp[182], stim_temp[181], stim_temp[180], stim_temp[179], stim_temp[178], stim_temp[177], stim_temp[176], stim_temp[175], stim_temp[174], stim_temp[173], stim_temp[172], stim_temp[171], stim_temp[170], stim_temp[169], stim_temp[168], stim_temp[167], stim_temp[166], stim_temp[165], stim_temp[164], stim_temp[163], stim_temp[162], stim_temp[161], stim_temp[160], stim_temp[159], stim_temp[158], stim_temp[157], stim_temp[156], stim_temp[155], stim_temp[154], stim_temp[153], stim_temp[152], stim_temp[151], stim_temp[150], stim_temp[149], stim_temp[148], stim_temp[147], stim_temp[146], stim_temp[145], stim_temp[144], stim_temp[143], stim_temp[142], stim_temp[141], stim_temp[140], stim_temp[139], stim_temp[138], stim_temp[137], stim_temp[136], stim_temp[135], stim_temp[134], stim_temp[133], stim_temp[132], stim_temp[131], stim_temp[130], stim_temp[129], stim_temp[128], stim_temp[127], stim_temp[126], stim_temp[125], stim_temp[124], stim_temp[123], stim_temp[122], stim_temp[121], stim_temp[120], stim_temp[119], stim_temp[118], stim_temp[117], stim_temp[116], stim_temp[115], stim_temp[114], stim_temp[113], stim_temp[112], stim_temp[111], stim_temp[110], stim_temp[109], stim_temp[108], stim_temp[107], stim_temp[106], stim_temp[105], stim_temp[104], stim_temp[103], stim_temp[102], stim_temp[101], stim_temp[100], stim_temp[99], stim_temp[98], stim_temp[97], stim_temp[96], stim_temp[95], stim_temp[94], stim_temp[93], stim_temp[92], stim_temp[91], stim_temp[90], stim_temp[89], stim_temp[88], stim_temp[87], stim_temp[86], stim_temp[85], stim_temp[84], stim_temp[83], stim_temp[82], stim_temp[81], stim_temp[80], stim_temp[79], stim_temp[78], stim_temp[77], stim_temp[76], stim_temp[75], stim_temp[74], stim_temp[73], stim_temp[72], stim_temp[71], stim_temp[70], stim_temp[69], stim_temp[68], stim_temp[67], stim_temp[66], stim_temp[65], stim_temp[64], stim_temp[63], stim_temp[62], stim_temp[61], stim_temp[60], stim_temp[59], stim_temp[58], stim_temp[57], stim_temp[56], stim_temp[55], stim_temp[54], stim_temp[53], stim_temp[52], stim_temp[51], stim_temp[50], stim_temp[49], stim_temp[48], stim_temp[47], stim_temp[46], stim_temp[45], stim_temp[44], stim_temp[43], stim_temp[42], stim_temp[41], stim_temp[40], stim_temp[39], stim_temp[38], stim_temp[37], stim_temp[36], stim_temp[35], stim_temp[34], stim_temp[33], stim_temp[32], stim_temp[31], stim_temp[30], stim_temp[29], stim_temp[28], stim_temp[27], stim_temp[26], stim_temp[25], stim_temp[24], stim_temp[23], stim_temp[22], stim_temp[21], stim_temp[20], stim_temp[19], stim_temp[18], stim_temp[17], stim_temp[16], stim_temp[15], stim_temp[14], stim_temp[13], stim_temp[12], stim_temp[11], stim_temp[10], stim_temp[9], stim_temp[8], stim_temp[7], stim_temp[6], stim_temp[5], stim_temp[4], stim_temp[3], stim_temp[2], stim_temp[1], stim_temp[0]); 
        end    
        stim=stim_temp;    
        counter=counter+1;
        next_stimuli = 1'b1;
        valid=1'b1;    
      end   
    end  
    #(ACQ_DELAY-APPL_DELAY);    

  end

    $fclose(stim_fd);
    @(posedge clk);
    #(APPL_DELAY);
    stim_applied = 1;
    end_of_stim = 1'b1;

end



//The received response from Device Under test is pushed to the queue for the comparison with the expected response
initial begin: acquisition_block
 
  integer ret_code;
  wait (rst_n);
  while (1) begin
    @(posedge clk);
     #(APPL_DELAY);
     #(ACQ_DELAY-APPL_DELAY);
     if(ready)begin
       queue_mon2chk.push_back(act_resp);
     end
  end
 
end


//This block compares the expected response to the aquired response from the Device Under Test
initial begin: checker_block
   
  integer exp_resp_fd;
  integer ret_code;
  exp_resp_fd = $fopen("../simvectors/Ultimate_Expected_Response_2.txt", "r"); // The file which represent the response of the golden model
  //exp_resp_fd = $fopen("../simvectors/Latest_Expected_Response_512_2.txt", "r"); // The file which represent the response of the golden model
  if (exp_resp_fd == 0) begin
      $fatal("Could not open expected file!");
  end
  n_checks = 0;
  n_errs   = 0;
  n_timeout = 0;
  wait (rst_n);
  while (!stim_applied || n_checks < n_stims) begin
      wait(queue_mon2chk.size() > 0);
      acq_resp = queue_mon2chk.pop_front();
      n_checks += 1;
      ret_code = $fscanf(exp_resp_fd, "%b\n",exp_resp);
      $display(acq_resp);
      $display("Compare!");
      if (acq_resp != exp_resp) begin
          n_errs += 1;
          $display("Mismatch occurred: actual %512b, expected %512b, stim nr: %d", acq_resp, exp_resp,n_stims);
          $display(clockcycle);
      end else begin
          $display("Testbench sucessfully PASSED at stim nr:%d",n_stims);
          $display(clockcycle);
      end
  end

  if (n_errs > 0) begin
      $display("Test ***FAILED*** with ", n_errs, " mismatches out of ",   n_checks, " checks after ", n_stims, " stimuli!");
  end else begin
      $display("Test ***PASSED*** with ", n_errs, " mismatches out of ", n_checks, " checks after ", n_stims, " stimuli.");
  end
  $fclose(exp_resp_fd);
  $stop();

end



//In case your time linmit that you assing at the beggining is up, than this block runs
initial begin: timeout_block
        
  if(n_stims>TOT_STIMS)begin
    end_of_stim = 1'b1;
  end
  while (n_timeout < TIMEOUT_LIM) begin
    @(posedge clk);
    #(ACQ_DELAY);
    n_timeout = n_timeout + 1;
   end
   $display("Test ***TIMED OUT*** with ", n_errs, " mismatches out of ", n_checks, " checks after ", n_stims, " stimuli!");
   $stop;

end

endmodule