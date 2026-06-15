SRCDIR := ./src/
BLUESPEC_GEN := ./blue_out/
BLUESIM_GEN := ./blue_sim/
VERILOG_DIR := ./verilog_out/
SIM_NAME := goSim
TOP_FILE := ${SRCDIR}/Example.bsv

FLAGS = -bdir ${BLUESPEC_GEN} -simdir ${BLUESIM_GEN}


.PHONY: sim 

sim ./${SIM_NAME} : ${TOP_FILE}
	bsc ${FLAGS} -sim -g mkExample ${TOP_FILE}
	bsc ${FLAGS} -o ${SIM_NAME} -sim -e mkExample

clean :
	rm -f ${BLUESPEC_GEN}* ${BLUESIM_GEN}* ${VERILOG_DIR}* ${SIM_NAME}*
