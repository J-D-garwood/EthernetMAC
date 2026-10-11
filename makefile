# Compiles and runs the frame parser testbench
TB     = frame_parser_tb
TB_DIR = testbenches
SRC    = src/RGMII_frame_parser.v \
         src/RGMII_byte_packager.v \
         src/RGMII_receiver.v \
         src/synchroniser.v \
         $(wildcard src/async_FIFO/*.v)
OUT    = sim.out

# Xilinx simulation models (BUFG, IDDR)
XILINX  = C:/AMDDesignTools/2025.2/data/verilog/src
UNISIMS = $(XILINX)/unisims

all: run

$(OUT): $(TB_DIR)/$(TB).v $(SRC)
	iverilog -g2005 -Wall -o $(OUT) -y $(UNISIMS) $(TB_DIR)/$(TB).v $(SRC) $(XILINX)/glbl.v

run: $(OUT)
	vvp $(OUT) -fst

wave:
	gtkwave dump.fst

clean:
	rm -f $(OUT) *.vcd *.fst

# ---- Questa ----
qlib:
	-vlib work

qbuild: qlib
	vlog $(TB_DIR)/$(TB).v $(SRC)

qrun: qbuild
	vsim -c $(TB) -do "run -all; quit"

qwave: qbuild
	vsim -voptargs=+acc $(TB) -do "add wave -r /*; run -all"

qclean:
	-rmdir /S /Q work
	-del /Q transcript vsim.wlf modelsim.ini