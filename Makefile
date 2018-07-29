.PHONY = clean update build bootstrap
cmdshelf ?= cmdshelf

clean:
	rm -rf .build
	rm Package.resolved

update:
	swift package update

build: sourcery
	swift build

# Needs toshi0383/scripts to be added to cmdshelf's remote
install:
	$(cmdshelf) run swiftpm/install.sh toshi0383/ghaw

release:
	rm -rf .build/release
	swift build -c release -Xswiftc -static-stdlib
	$(cmdshelf) run swiftpm/release.sh ghaw

sourcery:
	./scripts/run-sourcery

bootstrap:
	rm -rf Pods Podfile.lock *.xcodeproj # Cleaning up to avoid cocoapods failing to bootstrap from Podfile.lock
	swift package generate-xcodeproj # Creating one for CocoaPods to work.
	pod install # Installing sourcery for swifttemplate support.
	swift package generate-xcodeproj # Discarding cocoapods side effects, gracefully.
