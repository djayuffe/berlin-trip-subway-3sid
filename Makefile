ACME ?= acme
VICE ?= x64sc

PROGRAM := build/berlin-trip-subway-3sid-v6.0.0.prg
SOURCE := src/subway.s
CHECKSUMS := CHECKSUMS.sha256
VICE_3SID_FLAGS := -sidextra 2 -sid2address 0xd420 -sid3address 0xd440

.PHONY: all build run check checksums clean

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
	@shasum -a 256 AUDIT.md README.md V6_0_0_MUSIC_AUDIT.json V6_0_0_NOTES.md build_release.sh Makefile docs/ARCHITECTURE.md $(SOURCE) > $(CHECKSUMS)

clean:
	@rm -rf build dist
