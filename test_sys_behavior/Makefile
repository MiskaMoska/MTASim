# VCS
COMPILER = vcs -full64 -cc gcc-4.8 -cpp g++-4.8 -LDFLAGS -Wl,-no-as-needed
TOP_MODULE = -top top_tb
TIMESCALE = -timescale=100ps/1ps
INCDIR = +incdir+config
DEBUG = -debug_access

# Verdi
PLI_TAB = $(VERDI_HOME)/share/PLI/VCS/LINUXAMD64/novas.tab
PLI_A = $(VERDI_HOME)/share/PLI/VCS/LINUXAMD64/pli.a
FSDB = -fsdb -P $(PLI_TAB) $(PLI_A)

run:
	$(COMPILER) -sverilog -f filelist.f  \
	$(TOP_MODULE)   					 \
	$(TIMESCALE)						 \
	$(INCDIR)						     \
	$(FSDB)							     \
	$(DEBUG)			     
	./simv

verdi:
	verdi +v2k -sverilog $(INCDIR) -f filelist.f -ssf wave.fsdb -sswr cfg1.rc


.PHONY:clean
clean:
	rm -rf simv.daidir csrc verdiLog novas* simv ucli.key
	rm -rf receive_pool*
	rm -rf wave.*
	rm -rf *.fsdb
	rm -rf *.log
	rm -rf receive_pool*
