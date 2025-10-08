
# Flags #####

SRC_DIR=src
BIN_DIR=bin
RSC_DIR=src/resources
GEN_DIR=src/generated

EXE=minesweeper.gb
MAP=minesweeper.map

ASM_FLAGS=-Wall -I src/include -i src/generated
L_FLAGS=-Wall --linkerscript linker.ld -n bin/minesweeper.sym --dmg --wramx --tiny
F_FLAGS=-Wall -c --mbc-type 0x00 --ram-size 0x00 --title 'Minesweeper' -j -v -p 0xFF
GFX_FLAGS=-c "\#1b2a09,\#0d450b,\#496b22,\#9a9e3f;" -u 

recursive_wildcard=$(foreach d,\
		$(wildcard $(1:=/*)), \
		$(call recursive_wildcard, $d, $2) $(filter $(subst *, %, $2), $d) \
)
SOURCE_FILE_LIST=$(call recursive_wildcard,$(SRC_DIR),*.s)
RESOURCE_FILE_LIST=$(call recursive_wildcard,$(RSC_DIR),*.png)


# Options #####

compile: clean generate-images
	for ASM_FILE in $(SOURCE_FILE_LIST) ; do \
		OBJ_FILE=`basename $$ASM_FILE | cut -d. -f1`.o ;\
		rgbasm $$ASM_FILE $(ASM_FLAGS) -o $(BIN_DIR)/$$OBJ_FILE ; \
	done
	rgblink $(BIN_DIR)/*.o $(L_FLAGS) -o $(BIN_DIR)/$(EXE)
	rgbfix $(BIN_DIR)/$(EXE) $(F_FLAGS)

clean:
	rm bin/* 2> /dev/null || true 
	rm src/generated/* 2> /dev/null || true

generate-images:
	for IMAGE_FILE in $(RESOURCE_FILE_LIST) ; do \
		GEN_FILE=`basename $$IMAGE_FILE | cut -d. -f1`.2bpp ;\
		TILEMAP_FILE=`basename $$IMAGE_FILE | cut -d. -f1`.tilemap ;\
		echo $$GEN_FILE ;\
		rgbgfx $$IMAGE_FILE $(GFX_FLAGS) -o $(GEN_DIR)/$$GEN_FILE -t $(GEN_DIR)/$$TILEMAP_FILE ; \
	done

run: compile
	emulicious $(BIN_DIR)/$(EXE)

run-sameboy: compile
	sameboy $(BIN_DIR)/$(EXE)

map: compile
	rgblink $(BIN_DIR)/*.o $(L_FLAGS) -m $(BIN_DIR)/$(MAP)
	cat $(BIN_DIR)/$(MAP)

