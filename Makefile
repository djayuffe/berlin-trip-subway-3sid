ACME ?= acme
VICE ?= x64sc
VERSION ?= 6.0.1

PROGRAM := build/berlin-trip-subway-3sid.prg
SOURCE := src/subway.s
CHECKSUMS := CHECKSUMS.sha256
RELEASE_ARCHIVE := dist/berlin-trip-subway-3sid-v$(VERSION).zip
RELEASE_FILES := $(PROGRAM) README.md RELEASE_NOTES.md AUDIT.md CHECKSUMS.sha256 \
	V6_0_0_MUSIC_AUDIT.json V6_0_0_NOTES.md build_release.sh Makefile \
	docs/ARCHITECTURE.md docs/EFFECTS.md assets/3sid-pulse-field-magenta.png \
	assets/3sid-pulse-field-blue.png assets/boot-path-effect.png $(SOURCE)
VICE_3SID_FLAGS := -sidextra 2 -sid2address 0xd420 -sid3address 0xd440

.PHONY: all build run check checksums release clean

all: build

build: $(PROGRAM)

$(PROGRAM): $(SOURCE)
	@mkdir -p build
	cd src && $(ACME) -f cbm -o ../$@ subway.s

run: build
	$(VICE) $(VICE_3SID_FLAGS) -autostartprgmode 1 -autostart $(PROGRAM)

check: build
	@shasum -a 256 -c $(CHECKSUMS)

checksums:
	@shasum -a 256 AUDIT.md README.md RELEASE_NOTES.md V6_0_0_MUSIC_AUDIT.json V6_0_0_NOTES.md build_release.sh Makefile docs/ARCHITECTURE.md docs/EFFECTS.md assets/3sid-pulse-field-magenta.png assets/3sid-pulse-field-blue.png assets/boot-path-effect.png $(SOURCE) > $(CHECKSUMS)

release: check
	@mkdir -p dist
	zip -FS $(RELEASE_ARCHIVE) $(RELEASE_FILES)

clean:
	@rm -rf build dist
