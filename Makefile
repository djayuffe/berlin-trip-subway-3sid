ACME ?= acme
VICE ?= x64sc

PROGRAM := build/berlin-trip-subway-3sid-v6.0.0.prg
SOURCE := src/subway.s
ASSETS := src/wire_cube_chars.bin src/wire_cube_mask.bin
CHECKSUMS := CHECKSUMS.sha256
VICE_3SID_FLAGS := -sidextra 2 -sid2address 0xd420 -sid3address 0xd440

.PHONY: all build run check checksums clean

all: build

build: $(PROGRAM)

$(PROGRAM): $(SOURCE) $(ASSETS)
	@mkdir -p build
	cd src && $(ACME) -f cbm -o ../$@ subway.s

run: build
	$(VICE) $(VICE_3SID_FLAGS) -autostartprgmode 1 -autostart $(PROGRAM)

check: build
	@test "$$(wc -c < src/wire_cube_chars.bin)" -eq 3840
	@test "$$(wc -c < src/wire_cube_mask.bin)" -eq 3840
	@shasum -a 256 -c $(CHECKSUMS)

checksums:
	@shasum -a 256 AUDIT.md README.md V6_0_0_MUSIC_AUDIT.json V6_0_0_NOTES.md build_release.sh Makefile $(SOURCE) $(ASSETS) > $(CHECKSUMS)

clean:
	@rm -rf build dist
