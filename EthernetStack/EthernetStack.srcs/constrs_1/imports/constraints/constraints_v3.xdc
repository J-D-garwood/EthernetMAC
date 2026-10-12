## Bank-0 / configuration voltage ----------------------------------------
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
## Boot from the on-board QSPI flash in x4 mode at 50 MHz -----------------
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]

create_clock -period 5.000 [get_ports sys_clk_p]
set_property IOSTANDARD DIFF_SSTL15 [get_ports sys_clk_p]
set_property PACKAGE_PIN R4 [get_ports sys_clk_p]
set_property PACKAGE_PIN T4 [get_ports sys_clk_n]
set_property IOSTANDARD DIFF_SSTL15 [get_ports sys_clk_n]

set_property PACKAGE_PIN N13 [get_ports MDC]
set_property IOSTANDARD LVCMOS33 [get_ports MDC]
set_property PACKAGE_PIN P14 [get_ports MDIO]
set_property IOSTANDARD LVCMOS33 [get_ports MDIO]
set_property PACKAGE_PIN R14 [get_ports PHY_rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports PHY_rst_n]
set_property PACKAGE_PIN F15 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]

## RGMII receive ----------------------------------------------------------
set_property PACKAGE_PIN V18 [get_ports RXC]
set_property PACKAGE_PIN R19 [get_ports RX_CTL]
set_property PACKAGE_PIN P19 [get_ports {RXD[0]}]
set_property PACKAGE_PIN U18 [get_ports {RXD[1]}]
set_property PACKAGE_PIN U17 [get_ports {RXD[2]}]
set_property PACKAGE_PIN P17 [get_ports {RXD[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RXC RX_CTL {RXD[*]}}]

set_property PACKAGE_PIN P15 [get_ports TXC]
set_property PACKAGE_PIN N17 [get_ports TX_CTL]
set_property PACKAGE_PIN N14 [get_ports {TXD[0]}]
set_property PACKAGE_PIN P16 [get_ports {TXD[1]}]
set_property PACKAGE_PIN R17 [get_ports {TXD[2]}]
set_property PACKAGE_PIN R16 [get_ports {TXD[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {TXC TX_CTL {TXD[*]}}]

create_clock -period 40.000 -name rxc [get_ports RXC]

set_clock_groups -asynchronous -group [get_clocks rxc] -group [get_clocks -include_generated_clocks sys_clk_p]


create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list clk_wiz/inst/clk_out1]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 16 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {MDIO_master/mdio/received[0]} {MDIO_master/mdio/received[1]} {MDIO_master/mdio/received[2]} {MDIO_master/mdio/received[3]} {MDIO_master/mdio/received[4]} {MDIO_master/mdio/received[5]} {MDIO_master/mdio/received[6]} {MDIO_master/mdio/received[7]} {MDIO_master/mdio/received[8]} {MDIO_master/mdio/received[9]} {MDIO_master/mdio/received[10]} {MDIO_master/mdio/received[11]} {MDIO_master/mdio/received[12]} {MDIO_master/mdio/received[13]} {MDIO_master/mdio/received[14]} {MDIO_master/mdio/received[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 6 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {MDIO_master/mdio/state[0]} {MDIO_master/mdio/state[1]} {MDIO_master/mdio/state[2]} {MDIO_master/mdio/state[3]} {MDIO_master/mdio/state[4]} {MDIO_master/mdio/state[5]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 8 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {data[0]} {data[1]} {data[2]} {data[3]} {data[4]} {data[5]} {data[6]} {data[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 576 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {data_out/frame[0]} {data_out/frame[1]} {data_out/frame[2]} {data_out/frame[3]} {data_out/frame[4]} {data_out/frame[5]} {data_out/frame[6]} {data_out/frame[7]} {data_out/frame[8]} {data_out/frame[9]} {data_out/frame[10]} {data_out/frame[11]} {data_out/frame[12]} {data_out/frame[13]} {data_out/frame[14]} {data_out/frame[15]} {data_out/frame[16]} {data_out/frame[17]} {data_out/frame[18]} {data_out/frame[19]} {data_out/frame[20]} {data_out/frame[21]} {data_out/frame[22]} {data_out/frame[23]} {data_out/frame[24]} {data_out/frame[25]} {data_out/frame[26]} {data_out/frame[27]} {data_out/frame[28]} {data_out/frame[29]} {data_out/frame[30]} {data_out/frame[31]} {data_out/frame[32]} {data_out/frame[33]} {data_out/frame[34]} {data_out/frame[35]} {data_out/frame[36]} {data_out/frame[37]} {data_out/frame[38]} {data_out/frame[39]} {data_out/frame[40]} {data_out/frame[41]} {data_out/frame[42]} {data_out/frame[43]} {data_out/frame[44]} {data_out/frame[45]} {data_out/frame[46]} {data_out/frame[47]} {data_out/frame[48]} {data_out/frame[49]} {data_out/frame[50]} {data_out/frame[51]} {data_out/frame[52]} {data_out/frame[53]} {data_out/frame[54]} {data_out/frame[55]} {data_out/frame[56]} {data_out/frame[57]} {data_out/frame[58]} {data_out/frame[59]} {data_out/frame[60]} {data_out/frame[61]} {data_out/frame[62]} {data_out/frame[63]} {data_out/frame[64]} {data_out/frame[65]} {data_out/frame[66]} {data_out/frame[67]} {data_out/frame[68]} {data_out/frame[69]} {data_out/frame[70]} {data_out/frame[71]} {data_out/frame[72]} {data_out/frame[73]} {data_out/frame[74]} {data_out/frame[75]} {data_out/frame[76]} {data_out/frame[77]} {data_out/frame[78]} {data_out/frame[79]} {data_out/frame[80]} {data_out/frame[81]} {data_out/frame[82]} {data_out/frame[83]} {data_out/frame[84]} {data_out/frame[85]} {data_out/frame[86]} {data_out/frame[87]} {data_out/frame[88]} {data_out/frame[89]} {data_out/frame[90]} {data_out/frame[91]} {data_out/frame[92]} {data_out/frame[93]} {data_out/frame[94]} {data_out/frame[95]} {data_out/frame[96]} {data_out/frame[97]} {data_out/frame[98]} {data_out/frame[99]} {data_out/frame[100]} {data_out/frame[101]} {data_out/frame[102]} {data_out/frame[103]} {data_out/frame[104]} {data_out/frame[105]} {data_out/frame[106]} {data_out/frame[107]} {data_out/frame[108]} {data_out/frame[109]} {data_out/frame[110]} {data_out/frame[111]} {data_out/frame[112]} {data_out/frame[113]} {data_out/frame[114]} {data_out/frame[115]} {data_out/frame[116]} {data_out/frame[117]} {data_out/frame[118]} {data_out/frame[119]} {data_out/frame[120]} {data_out/frame[121]} {data_out/frame[122]} {data_out/frame[123]} {data_out/frame[124]} {data_out/frame[125]} {data_out/frame[126]} {data_out/frame[127]} {data_out/frame[128]} {data_out/frame[129]} {data_out/frame[130]} {data_out/frame[131]} {data_out/frame[132]} {data_out/frame[133]} {data_out/frame[134]} {data_out/frame[135]} {data_out/frame[136]} {data_out/frame[137]} {data_out/frame[138]} {data_out/frame[139]} {data_out/frame[140]} {data_out/frame[141]} {data_out/frame[142]} {data_out/frame[143]} {data_out/frame[144]} {data_out/frame[145]} {data_out/frame[146]} {data_out/frame[147]} {data_out/frame[148]} {data_out/frame[149]} {data_out/frame[150]} {data_out/frame[151]} {data_out/frame[152]} {data_out/frame[153]} {data_out/frame[154]} {data_out/frame[155]} {data_out/frame[156]} {data_out/frame[157]} {data_out/frame[158]} {data_out/frame[159]} {data_out/frame[160]} {data_out/frame[161]} {data_out/frame[162]} {data_out/frame[163]} {data_out/frame[164]} {data_out/frame[165]} {data_out/frame[166]} {data_out/frame[167]} {data_out/frame[168]} {data_out/frame[169]} {data_out/frame[170]} {data_out/frame[171]} {data_out/frame[172]} {data_out/frame[173]} {data_out/frame[174]} {data_out/frame[175]} {data_out/frame[176]} {data_out/frame[177]} {data_out/frame[178]} {data_out/frame[179]} {data_out/frame[180]} {data_out/frame[181]} {data_out/frame[182]} {data_out/frame[183]} {data_out/frame[184]} {data_out/frame[185]} {data_out/frame[186]} {data_out/frame[187]} {data_out/frame[188]} {data_out/frame[189]} {data_out/frame[190]} {data_out/frame[191]} {data_out/frame[192]} {data_out/frame[193]} {data_out/frame[194]} {data_out/frame[195]} {data_out/frame[196]} {data_out/frame[197]} {data_out/frame[198]} {data_out/frame[199]} {data_out/frame[200]} {data_out/frame[201]} {data_out/frame[202]} {data_out/frame[203]} {data_out/frame[204]} {data_out/frame[205]} {data_out/frame[206]} {data_out/frame[207]} {data_out/frame[208]} {data_out/frame[209]} {data_out/frame[210]} {data_out/frame[211]} {data_out/frame[212]} {data_out/frame[213]} {data_out/frame[214]} {data_out/frame[215]} {data_out/frame[216]} {data_out/frame[217]} {data_out/frame[218]} {data_out/frame[219]} {data_out/frame[220]} {data_out/frame[221]} {data_out/frame[222]} {data_out/frame[223]} {data_out/frame[224]} {data_out/frame[225]} {data_out/frame[226]} {data_out/frame[227]} {data_out/frame[228]} {data_out/frame[229]} {data_out/frame[230]} {data_out/frame[231]} {data_out/frame[232]} {data_out/frame[233]} {data_out/frame[234]} {data_out/frame[235]} {data_out/frame[236]} {data_out/frame[237]} {data_out/frame[238]} {data_out/frame[239]} {data_out/frame[240]} {data_out/frame[241]} {data_out/frame[242]} {data_out/frame[243]} {data_out/frame[244]} {data_out/frame[245]} {data_out/frame[246]} {data_out/frame[247]} {data_out/frame[248]} {data_out/frame[249]} {data_out/frame[250]} {data_out/frame[251]} {data_out/frame[252]} {data_out/frame[253]} {data_out/frame[254]} {data_out/frame[255]} {data_out/frame[256]} {data_out/frame[257]} {data_out/frame[258]} {data_out/frame[259]} {data_out/frame[260]} {data_out/frame[261]} {data_out/frame[262]} {data_out/frame[263]} {data_out/frame[264]} {data_out/frame[265]} {data_out/frame[266]} {data_out/frame[267]} {data_out/frame[268]} {data_out/frame[269]} {data_out/frame[270]} {data_out/frame[271]} {data_out/frame[272]} {data_out/frame[273]} {data_out/frame[274]} {data_out/frame[275]} {data_out/frame[276]} {data_out/frame[277]} {data_out/frame[278]} {data_out/frame[279]} {data_out/frame[280]} {data_out/frame[281]} {data_out/frame[282]} {data_out/frame[283]} {data_out/frame[284]} {data_out/frame[285]} {data_out/frame[286]} {data_out/frame[287]} {data_out/frame[288]} {data_out/frame[289]} {data_out/frame[290]} {data_out/frame[291]} {data_out/frame[292]} {data_out/frame[293]} {data_out/frame[294]} {data_out/frame[295]} {data_out/frame[296]} {data_out/frame[297]} {data_out/frame[298]} {data_out/frame[299]} {data_out/frame[300]} {data_out/frame[301]} {data_out/frame[302]} {data_out/frame[303]} {data_out/frame[304]} {data_out/frame[305]} {data_out/frame[306]} {data_out/frame[307]} {data_out/frame[308]} {data_out/frame[309]} {data_out/frame[310]} {data_out/frame[311]} {data_out/frame[312]} {data_out/frame[313]} {data_out/frame[314]} {data_out/frame[315]} {data_out/frame[316]} {data_out/frame[317]} {data_out/frame[318]} {data_out/frame[319]} {data_out/frame[320]} {data_out/frame[321]} {data_out/frame[322]} {data_out/frame[323]} {data_out/frame[324]} {data_out/frame[325]} {data_out/frame[326]} {data_out/frame[327]} {data_out/frame[328]} {data_out/frame[329]} {data_out/frame[330]} {data_out/frame[331]} {data_out/frame[332]} {data_out/frame[333]} {data_out/frame[334]} {data_out/frame[335]} {data_out/frame[336]} {data_out/frame[337]} {data_out/frame[338]} {data_out/frame[339]} {data_out/frame[340]} {data_out/frame[341]} {data_out/frame[342]} {data_out/frame[343]} {data_out/frame[344]} {data_out/frame[345]} {data_out/frame[346]} {data_out/frame[347]} {data_out/frame[348]} {data_out/frame[349]} {data_out/frame[350]} {data_out/frame[351]} {data_out/frame[352]} {data_out/frame[353]} {data_out/frame[354]} {data_out/frame[355]} {data_out/frame[356]} {data_out/frame[357]} {data_out/frame[358]} {data_out/frame[359]} {data_out/frame[360]} {data_out/frame[361]} {data_out/frame[362]} {data_out/frame[363]} {data_out/frame[364]} {data_out/frame[365]} {data_out/frame[366]} {data_out/frame[367]} {data_out/frame[368]} {data_out/frame[369]} {data_out/frame[370]} {data_out/frame[371]} {data_out/frame[372]} {data_out/frame[373]} {data_out/frame[374]} {data_out/frame[375]} {data_out/frame[376]} {data_out/frame[377]} {data_out/frame[378]} {data_out/frame[379]} {data_out/frame[380]} {data_out/frame[381]} {data_out/frame[382]} {data_out/frame[383]} {data_out/frame[384]} {data_out/frame[385]} {data_out/frame[386]} {data_out/frame[387]} {data_out/frame[388]} {data_out/frame[389]} {data_out/frame[390]} {data_out/frame[391]} {data_out/frame[392]} {data_out/frame[393]} {data_out/frame[394]} {data_out/frame[395]} {data_out/frame[396]} {data_out/frame[397]} {data_out/frame[398]} {data_out/frame[399]} {data_out/frame[400]} {data_out/frame[401]} {data_out/frame[402]} {data_out/frame[403]} {data_out/frame[404]} {data_out/frame[405]} {data_out/frame[406]} {data_out/frame[407]} {data_out/frame[408]} {data_out/frame[409]} {data_out/frame[410]} {data_out/frame[411]} {data_out/frame[412]} {data_out/frame[413]} {data_out/frame[414]} {data_out/frame[415]} {data_out/frame[416]} {data_out/frame[417]} {data_out/frame[418]} {data_out/frame[419]} {data_out/frame[420]} {data_out/frame[421]} {data_out/frame[422]} {data_out/frame[423]} {data_out/frame[424]} {data_out/frame[425]} {data_out/frame[426]} {data_out/frame[427]} {data_out/frame[428]} {data_out/frame[429]} {data_out/frame[430]} {data_out/frame[431]} {data_out/frame[432]} {data_out/frame[433]} {data_out/frame[434]} {data_out/frame[435]} {data_out/frame[436]} {data_out/frame[437]} {data_out/frame[438]} {data_out/frame[439]} {data_out/frame[440]} {data_out/frame[441]} {data_out/frame[442]} {data_out/frame[443]} {data_out/frame[444]} {data_out/frame[445]} {data_out/frame[446]} {data_out/frame[447]} {data_out/frame[448]} {data_out/frame[449]} {data_out/frame[450]} {data_out/frame[451]} {data_out/frame[452]} {data_out/frame[453]} {data_out/frame[454]} {data_out/frame[455]} {data_out/frame[456]} {data_out/frame[457]} {data_out/frame[458]} {data_out/frame[459]} {data_out/frame[460]} {data_out/frame[461]} {data_out/frame[462]} {data_out/frame[463]} {data_out/frame[464]} {data_out/frame[465]} {data_out/frame[466]} {data_out/frame[467]} {data_out/frame[468]} {data_out/frame[469]} {data_out/frame[470]} {data_out/frame[471]} {data_out/frame[472]} {data_out/frame[473]} {data_out/frame[474]} {data_out/frame[475]} {data_out/frame[476]} {data_out/frame[477]} {data_out/frame[478]} {data_out/frame[479]} {data_out/frame[480]} {data_out/frame[481]} {data_out/frame[482]} {data_out/frame[483]} {data_out/frame[484]} {data_out/frame[485]} {data_out/frame[486]} {data_out/frame[487]} {data_out/frame[488]} {data_out/frame[489]} {data_out/frame[490]} {data_out/frame[491]} {data_out/frame[492]} {data_out/frame[493]} {data_out/frame[494]} {data_out/frame[495]} {data_out/frame[496]} {data_out/frame[497]} {data_out/frame[498]} {data_out/frame[499]} {data_out/frame[500]} {data_out/frame[501]} {data_out/frame[502]} {data_out/frame[503]} {data_out/frame[504]} {data_out/frame[505]} {data_out/frame[506]} {data_out/frame[507]} {data_out/frame[508]} {data_out/frame[509]} {data_out/frame[510]} {data_out/frame[511]} {data_out/frame[512]} {data_out/frame[513]} {data_out/frame[514]} {data_out/frame[515]} {data_out/frame[516]} {data_out/frame[517]} {data_out/frame[518]} {data_out/frame[519]} {data_out/frame[520]} {data_out/frame[521]} {data_out/frame[522]} {data_out/frame[523]} {data_out/frame[524]} {data_out/frame[525]} {data_out/frame[526]} {data_out/frame[527]} {data_out/frame[528]} {data_out/frame[529]} {data_out/frame[530]} {data_out/frame[531]} {data_out/frame[532]} {data_out/frame[533]} {data_out/frame[534]} {data_out/frame[535]} {data_out/frame[536]} {data_out/frame[537]} {data_out/frame[538]} {data_out/frame[539]} {data_out/frame[540]} {data_out/frame[541]} {data_out/frame[542]} {data_out/frame[543]} {data_out/frame[544]} {data_out/frame[545]} {data_out/frame[546]} {data_out/frame[547]} {data_out/frame[548]} {data_out/frame[549]} {data_out/frame[550]} {data_out/frame[551]} {data_out/frame[552]} {data_out/frame[553]} {data_out/frame[554]} {data_out/frame[555]} {data_out/frame[556]} {data_out/frame[557]} {data_out/frame[558]} {data_out/frame[559]} {data_out/frame[560]} {data_out/frame[561]} {data_out/frame[562]} {data_out/frame[563]} {data_out/frame[564]} {data_out/frame[565]} {data_out/frame[566]} {data_out/frame[567]} {data_out/frame[568]} {data_out/frame[569]} {data_out/frame[570]} {data_out/frame[571]} {data_out/frame[572]} {data_out/frame[573]} {data_out/frame[574]} {data_out/frame[575]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 1 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list MDIO_master/mdio/done]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 1 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list good_frame]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 1 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list MDIO_master/mdio/receive]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 1 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list MDIO_master/mdio/receive_async]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 1 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list MDIO_master/mdio/transmit]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets TXC_OBUF]
