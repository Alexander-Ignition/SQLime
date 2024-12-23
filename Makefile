TARGET_NAME = SQLime
OUTPUD_DIR = ./Build
DERIVED_DATA_PATH = $(OUTPUD_DIR)/DerivedData

.PHONY: clean test test-macos test-ios

clean:
	swift package clean
	rm -rf $(OUTPUD_DIR)

# MARK: - format

lint:
	xcrun swift-format lint --recursive --strict ./

format:
	xcrun swift-format --recursive --in-place  ./

# MARK: - Tests

test:
	swift test

XCODEBUILD_TEST = xcodebuild test -quiet -scheme $(TARGET_NAME)

test-macos:
	$(XCODEBUILD_TEST) -destination 'platform=macOS'

test-ios:
	$(XCODEBUILD_TEST) -destination 'platform=iOS Simulator,name=iPhone 16'

# MARK: - DocC

DOCC_ARCHIVE = $(DERIVED_DATA_PATH)/Build/Products/Debug/$(TARGET_NAME).doccarchive

$(DOCC_ARCHIVE):
	xcodebuild docbuild \
		-quiet \
		-scheme $(TARGET_NAME) \
		-destination "generic/platform=macOS" \
		-derivedDataPath $(DERIVED_DATA_PATH)

$(OUTPUD_DIR)/Docs: $(DOCC_ARCHIVE)
	xcrun docc process-archive transform-for-static-hosting $^ \
		--hosting-base-path $(TARGET_NAME) \
		--output-path $@
