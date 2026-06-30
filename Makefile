# TerminalScreenSaver — Makefile
# Builds and installs the .saver bundle for macOS

PRODUCT_NAME  = TerminalScreenSaver
BUNDLE_NAME   = $(PRODUCT_NAME).saver
BUILD_DIR     = build
BUNDLE_DIR    = $(BUILD_DIR)/$(BUNDLE_NAME)
MACOS_DIR     = $(BUNDLE_DIR)/Contents/MacOS
RES_DIR       = $(BUNDLE_DIR)/Contents/Resources

SWIFT_FILES   = $(wildcard Sources/$(PRODUCT_NAME)/*.swift)
SWIFTC        = swiftc

# SDK & deployment
SDK           = $(shell xcrun --show-sdk-path --sdk macosx)
MIN_MACOS     = 12.0

# Frameworks
FRAMEWORKS    = -framework ScreenSaver -framework AppKit -framework Foundation

# Module name must match NSPrincipalClass prefix in Info.plist
MODULE_NAME   = TerminalScreenSaver

# Color output
RED    = \033[0;31m
GREEN  = \033[0;32m
YELLOW = \033[0;33m
BLUE   = \033[0;34m
NC     = \033[0m

.PHONY: all build bundle install install-user install-system clean help

# ─────────────────────────────────────────────
all: bundle

# ─────────────────────────────────────────────
build:
	@echo "$(BLUE)▶ Compiling Swift sources (universal: arm64 + x86_64)...$(NC)"
	@mkdir -p $(BUILD_DIR)
	@$(SWIFTC) \
		-module-name $(MODULE_NAME) \
		-target arm64-apple-macosx$(MIN_MACOS) \
		-sdk $(SDK) \
		$(FRAMEWORKS) \
		-O \
		-emit-library \
		-o $(BUILD_DIR)/$(PRODUCT_NAME)-arm64 \
		$(SWIFT_FILES)
	@$(SWIFTC) \
		-module-name $(MODULE_NAME) \
		-target x86_64-apple-macosx$(MIN_MACOS) \
		-sdk $(SDK) \
		$(FRAMEWORKS) \
		-O \
		-emit-library \
		-o $(BUILD_DIR)/$(PRODUCT_NAME)-x86_64 \
		$(SWIFT_FILES)
	@lipo -create \
		-output $(BUILD_DIR)/$(PRODUCT_NAME) \
		$(BUILD_DIR)/$(PRODUCT_NAME)-arm64 \
		$(BUILD_DIR)/$(PRODUCT_NAME)-x86_64
	@echo "$(GREEN)✓ Compilation successful (universal binary)$(NC)"

# ─────────────────────────────────────────────
bundle: build
	@echo "$(BLUE)▶ Assembling .saver bundle...$(NC)"
	@mkdir -p $(MACOS_DIR) $(RES_DIR)
	@cp $(BUILD_DIR)/$(PRODUCT_NAME) $(MACOS_DIR)/$(PRODUCT_NAME)
	@cp Resources/Info.plist $(BUNDLE_DIR)/Contents/Info.plist
	@echo "$(BLUE)▶ Ad-hoc signing bundle...$(NC)"
	@codesign --force --deep --sign - $(BUNDLE_DIR)
	@echo "$(GREEN)✓ Bundle created at: $(BUNDLE_DIR)$(NC)"

# ─────────────────────────────────────────────
install-user: bundle
	@echo "$(BLUE)▶ Installing for current user...$(NC)"
	@mkdir -p "$(HOME)/Library/Screen Savers"
	@rm -rf "$(HOME)/Library/Screen Savers/$(BUNDLE_NAME)"
	@cp -r $(BUNDLE_DIR) "$(HOME)/Library/Screen Savers/$(BUNDLE_NAME)"
	@echo "$(GREEN)✓ Installed to ~/Library/Screen Savers/$(BUNDLE_NAME)$(NC)"
	@echo "$(YELLOW)➜ Open System Settings → Screen Saver to activate$(NC)"

install-system: bundle
	@echo "$(BLUE)▶ Installing system-wide (requires sudo)...$(NC)"
	@sudo rm -rf "/Library/Screen Savers/$(BUNDLE_NAME)"
	@sudo cp -r $(BUNDLE_DIR) "/Library/Screen Savers/$(BUNDLE_NAME)"
	@echo "$(GREEN)✓ Installed to /Library/Screen Savers/$(BUNDLE_NAME)$(NC)"

# Default install target = user install
install: install-user

# ─────────────────────────────────────────────
clean:
	@echo "$(RED)▶ Cleaning build directory...$(NC)"
	@rm -rf $(BUILD_DIR)
	@echo "$(GREEN)✓ Clean complete$(NC)"

uninstall:
	@rm -rf "$(HOME)/Library/Screen Savers/$(BUNDLE_NAME)"
	@echo "$(GREEN)✓ Uninstalled$(NC)"

# ─────────────────────────────────────────────
help:
	@echo ""
	@echo "$(BLUE)Terminal Screen Saver — Build Targets$(NC)"
	@echo "────────────────────────────────────────────"
	@echo "  make             → build .saver bundle"
	@echo "  make build       → compile Swift sources only"
	@echo "  make bundle      → compile + assemble .saver"
	@echo "  make install     → install for current user"
	@echo "  make install-system → install system-wide (sudo)"
	@echo "  make clean       → remove build artifacts"
	@echo "  make uninstall   → remove from user Library"
	@echo ""
