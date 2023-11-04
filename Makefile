TARGET_NAME = SQLime
DERIVED_DATA_PATH = ./DerivedData

.PHONY: docs clean

docs:
	xcodebuild docbuild -quiet \
		-scheme $(TARGET_NAME) \
		-derivedDataPath $(DERIVED_DATA_PATH) \
		-destination 'platform=macOS'
	xcrun docc process-archive transform-for-static-hosting \
		$(DERIVED_DATA_PATH)/Build/Products/Debug/$(TARGET_NAME).doccarchive \
		--hosting-base-path "/SQLime" \
		--output-path $@

clean:
	swift package clean
	rm -rf $(DERIVED_DATA_PATH)
	rm -rf docs
