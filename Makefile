
# Flags #####

SRC_DIR=src
INC_DIR=src/include
RSC_DIR=rsc
BIN_DIR=bin
GEN_DIR=bin/generated
BEAT_DIR=src/main/audio/beats

LIB_SRC_DIR=lib/hUGEDriver_src
LIB_INC_DIR=lib/hUGEDriver_inc

EXE=beatmap.gb
MAP=beatmap.map

ASM_FLAGS=-Wall -I $(INC_DIR) -I $(INC_DIR)/structs -I $(LIB_INC_DIR) -i $(GEN_DIR)
L_FLAGS=-Wall --linkerscript linker.ld -n $(BIN_DIR)/minesweeper.sym --dmg --wramx --tiny
F_FLAGS=-Wall --mbc-type 0x00 --ram-size 0x00 --title 'Minesweeper' -j -v -p 0xFF
GFX_FLAGS=-u 


# Make Functions #####

recursive_wildcard=$(foreach d,\
		$(wildcard $(1:=/*)), \
		$(call recursive_wildcard, $d, $2) $(filter $(subst *, %, $2), $d) \
)
SOURCE_FILE_LIST=$(call recursive_wildcard,$(SRC_DIR),*.s)
LIB_SOURCE_FILE_LIST=$(call recursive_wildcard,$(LIB_SRC_DIR),*.s)


# Compilation #####

compile: clean copy-tilemaps copy-2bpp beats
	for ASM_FILE in $(SOURCE_FILE_LIST) ; do \
		OBJ_FILE=`basename $$ASM_FILE | cut -d. -f1`.o ;\
		rgbasm $$ASM_FILE $(ASM_FLAGS) -o $(BIN_DIR)/$$OBJ_FILE ; \
	done
	for ASM_FILE in $(LIB_SOURCE_FILE_LIST) ; do \
		OBJ_FILE=`basename $$ASM_FILE | cut -d. -f1`.o ;\
		rgbasm $$ASM_FILE $(ASM_FLAGS) -o $(BIN_DIR)/$$OBJ_FILE ; \
	done
	rgblink $(BIN_DIR)/*.o $(L_FLAGS) -o $(BIN_DIR)/$(EXE)
	rgbfix $(BIN_DIR)/$(EXE) $(F_FLAGS)

run: compile
	emulicious $(BIN_DIR)/$(EXE)

sameboy: compile
	sameboy $(BIN_DIR)/$(EXE)

map: compile
	rgblink $(BIN_DIR)/*.o $(L_FLAGS) -m $(BIN_DIR)/$(MAP)
	cat $(BIN_DIR)/$(MAP)

clean:
	rm $(BIN_DIR)/* 2> /dev/null || true 
	rm $(GEN_DIR)/* 2> /dev/null || true
	

# Utility #####

copy-2bpp:
	cp $(RSC_DIR)/bitmaps/* $(GEN_DIR)

copy-tilemaps:
	cp $(RSC_DIR)/tilemaps/* $(GEN_DIR)

beats:
	for BEAT in $(BEAT_DIR)/*.beat; do \
		BIN_FILE=`basename $$BEAT | cut -d. -f1 `.bin ; \
		python scripts/export-beatmap.py $$BEAT $(GEN_DIR)/$$BIN_FILE > /dev/null ; \
	done

