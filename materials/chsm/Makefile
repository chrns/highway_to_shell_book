# Directories
SRC_DIR := src
BUILD_DIR := build
TARGET := $(BUILD_DIR)/chsm

# Compiler and flags
CC := gcc
CFLAGS := -Wall -Wextra -O2 -std=gnu11

# Source files and object files
SRCS := $(wildcard $(SRC_DIR)/*.c)
OBJS := $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(SRCS))

# Default target
.PHONY: all
all: clean build

# Build the target
.PHONY: build
build: $(TARGET)

$(TARGET): $(OBJS)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) -o $@ $^

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

# Clean up build artifacts
.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)

# Force rebuild
.PHONY: rebuild
rebuild: clean all

# Run the program with test input
.PHONY: run
run: build
	@echo "Running the program with pipe as an input..."
	@echo "\xAA\xBB\xCC\xDD\xAA\x00" | $(TARGET)

# Run with file
.PHONY: run_with_file
run_with_file: build
	@echo "Running the program with file as an input..."
	@echo "\xAA\xBB\xCC\xDD\xAA\x00" > build/file.bin ; $(TARGET) build/file.bin