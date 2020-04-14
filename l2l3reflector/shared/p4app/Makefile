OUT_DIR=./build
P4C_BM_EXE=/home/valerio/p4c/build/p4c-bm2-ss
BMV2_PP_FLAGS=-DTARGET_BMV2

all: build

build: main.p4
	$(info ************ COMPILING P4 PROGRAM ************)
	mkdir -p $(OUT_DIR)
	$(P4C_BM_EXE) --arch v1model -o $(OUT_DIR)/bmv2.json \
		$(BMV2_PP_FLAGS) $(OTHER_PP_FLAGS) \
		main.p4

clean:
	rm -rf ./build
