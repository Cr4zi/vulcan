AS = nasm
LD = ld
ASFLAGS = -f elf64 -g

SRC_DIR	= src
BUILD_DIR = build

SRCS = $(wildcard $(SRC_DIR)/*.asm)
OBJS = $(patsubst $(SRC_DIR)/%.asm, $(BUILD_DIR)/%.o, $(SRCS))
TARGET = vulcan

$(BUILD_DIR)/$(TARGET): $(OBJS)
	$(LD) $^ -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.asm
	@mkdir -p $(BUILD_DIR)
	$(AS) $(ASFLAGS) -o $@ $<

clean:
	rm -rf $(BUILD_DIR)
