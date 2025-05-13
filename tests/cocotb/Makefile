SIM=icarus

PWD=$(shell pwd)
SOURCE_FOLDER = $(PWD)/../../rtl

VERILOG_SOURCES = $(SOURCE_FOLDER)/fifo.sv $(SOURCE_FOLDER)/fifo_controller.sv  

TOPLEVEL 	:= fifo
MODULE		:= test_fifo

include $(shell cocotb-config --makefiles)/Makefile.sim

