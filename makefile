all: com sim
.PHONY:com sim clean

OUTPUT = PISO

UVM_TESTNAME = PISO

ALL_DEFINE = +define+DUMP_VPD

#code coverage command
CM = -cm line+cond+fsm+branch+tgl
CM_NAME = -cm_name ${OUTPUT}
CM_DIR = -cm_dir ./${OUTPUT}.vdb
# CM_HIER = -cm_hier cov.cfg

VPD_NAME = +vpdfile+${OUTPUT}.vpd

VCS = vcs -sverilog +v2k -timescale=1ns/1ns                             \
	  -debug_all			\
	  -o ${OUTPUT}			\
	  -l compile.log		\
	  ${VPD_NAME}			\
	  ${ALL_DEFINE}			\
	  ${CM}					\
	  ${CM_NAME}			\
	  ${CM_DIR}				\
	  ${CM_HIER}			\
	  -debug_pp 			\
	  -Mupdate

VCS += -ntb_opts uvm-1.2 -CC -DVCS
VCS += -full64 -fsdb

SIM = ./${OUTPUT} -l run.log \
	  ${CM}					\
	  ${CM_NAME}				\
	  ${CM_DIR}				\
	  -l ${OUTPUT}.log

SIM += +UVM_TESTNAME=${UVM_TESTNAME}

com: 
	${VCS} -f filelist.f

sim:
	${SIM}

verdi:
	verdi -sv -f filelist.f

#show the coverage
cov:
	dve -covdir *.vdb &

debug:
	dve -vpd ${OUTPUT}.vpd &

clean:
	rm -rf ./csrc *.daidir *.log simv* *.key *.vpd ./DVEfiles ${OUTPUT} vc_hdrs.h *.vdb *.fsdb .fsm.sch.verilog.xml novas.conf novas.rc