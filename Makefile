.PHONY = clean update build bootstrap
cmdshelf ?= cmdshelf

clean:
	rm -rf .build
	rm Package.resolved

update:
	swift package update

build:
	swift build

bootstrap: build
	swift package generate-xcodeproj

# Needs toshi0383/scripts to be added to cmdshelf's remote
install:
	$(cmdshelf) run swiftpm/install.sh toshi0383/ghaw

release:
	rm -rf .build/release
	swift build -c release -Xswiftc -static-stdlib
	$(cmdshelf) run swiftpm/release.sh ghaw
