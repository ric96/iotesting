module iotesting (
	input clk,
	input wire LS_GPIOA,
	input wire LS_GPIOB,
	input wire LS_GPIOC,
	input wire LS_GPIOD,
	input wire LS_GPIOE,
	input wire LS_GPIOF,
	input wire LS_GPIOG,
	input wire LS_GPIOH,
	input wire LS_GPIOI,
	input wire LS_GPIOJ,
	input wire LS_GPIOK,
	input wire LS_GPIOL,
	output D8,
	output D9,
	output D10,
	output D11,
	input LS_U1_TX,
	output LS_U1_RX,
	input LS_U0_TX,
	output LS_U0_RX,
	output ARDUINO_TX,
	input ARDUINO_RX,
	output RESULT_TX,
	input RESULT_RX
);

reg [24:0] slow_clk;
reg [14:0] slow_clk2;
reg [0:2] led_reg_debug = 0;
reg led_reg_status = 0, tx_en, tx_test_en,rx_test_en;
reg [0:11] testing;
reg [14*8:1] result [14];
wire tx_enable, tx_active, tx_done, rx_test_byte;
reg [7:0] tx_data;
wire tx_test_enable, tx_test_active, tx_test_done, rx_test_enable;
reg [7:0] tx_test_data, test_data;
reg [7:0] i = 112, j = 0, k; 

assign tx_enable = tx_en;
assign tx_test_enable = tx_test_en;
assign rx_test_enable = rx_test_en;

uart_tx #(.CLKS_PER_BIT(5208)) result_transmit
(
	.i_Clock(clk),
   .i_Tx_DV(tx_enable),
   .i_Tx_Byte(tx_data), 
   .o_Tx_Active(tx_active),
   .o_Tx_Serial(RESULT_TX),
   .o_Tx_Done(tx_done)
);

uart_tx #(.CLKS_PER_BIT(5208)) uart_test_tx
(
	.i_Clock(clk),
   .i_Tx_DV(tx_test_enable),
   .i_Tx_Byte(tx_test_data), 
   .o_Tx_Active(tx_test_active),
   .o_Tx_Serial(LS_U0_RX),
	.o_Tx_Done(tx_test_done)
);

uart_rx #(.CLKS_PER_BIT(5208)) uart_test_rx
(
	.i_Clock(clk),
	.i_Rx_Serial(LS_U0_TX),
	.o_Rx_DV(rx_test_enable),
	.o_Rx_Byte(rx_test_byte)
);

initial begin
	result[0] <= "\n\rGPIO Test: ";
	result[1] <= "\n\rGPIOA    :0";
	result[2] <= "\n\rGPIOB    :0";
	result[3] <= "\n\rGPIOC    :0";
	result[4] <= "\n\rGPIOD    :0";
	result[5] <= "\n\rGPIOE    :0";
	result[6] <= "\n\rGPIOF    :0";
	result[7] <= "\n\rGPIOG    :0";
	result[8] <= "\n\rGPIOH    :0";
	result[9] <= "\n\rGPIOI    :0";
	result[10] <= "\n\rGPIOJ    :0";
	result[11] <= "\n\rGPIOK    :0";
	result[12] <= "\n\rGPIOL    :0";
	result[13] <= "\n\rUART     :0";
end


always @(posedge clk) begin
	slow_clk <= slow_clk + 1;
	slow_clk2 <= slow_clk2 + 1;
	testing[0:11] <= {LS_GPIOA,LS_GPIOB,LS_GPIOC,LS_GPIOD,LS_GPIOE,LS_GPIOF,LS_GPIOG,LS_GPIOH,LS_GPIOI,LS_GPIOJ,LS_GPIOK,LS_GPIOL};
 	result[1][1] <= testing[0];
	result[2][1] <= testing[1];
	result[3][1] <= testing[2];
	result[4][1] <= testing[3];
	result[5][1] <= testing[4];
	result[6][1] <= testing[5];
	result[7][1] <= testing[6];
	result[8][1] <= testing[7];
	result[9][1] <= testing[8];
	result[10][1] <= testing[9];
	result[11][1] <= testing[10];
	result[12][1] <= testing[11];
	
	if(test_data == "T") result[13][1] <= 1;
	else result[13][1] <= 0;
end

always @(posedge !tx_active) begin
	tx_en <= 1;
	tx_data <= result[j][i -: 8];
	if(i == 8) begin
		i <= 112;
		if(j == 13) j <= 0;
		else j <= j + 1;
	end else i <= i - 8;

end

always @(posedge !tx_test_active) begin
	tx_test_en <= 1;
	tx_test_data <= "T";
end

always @(posedge rx_test_en) begin
	test_data <= rx_test_byte;
end

always @(posedge slow_clk[24:24]) begin
	led_reg_status <= ~led_reg_status;
end

always @(posedge LS_GPIOA) begin
	led_reg_debug <= led_reg_debug + 1;
end

assign {D11, D9, D8} = led_reg_debug[0:2];
assign {D10} = led_reg_status;

assign ARDUINO_TX = LS_U1_TX;
assign LS_U1_RX = ARDUINO_RX;

//assign result[1] [9*8:8*8] = testing[1];

//assign testing[0:11] = {LS_GPIOA,LS_GPIOB,LS_GPIOC,LS_GPIOD,LS_GPIOE,LS_GPIOF,LS_GPIOG,LS_GPIOH,LS_GPIOI,LS_GPIOJ,LS_GPIOK,LS_GPIOL};


endmodule