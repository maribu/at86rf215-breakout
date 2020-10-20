.PHONY: jlcpcb% panel%.kicad_pcb all

PROJECT := at86rf215-breakout
PCB := $(PROJECT).kicad_pcb
SCHEMATIC := $(PROJECT).sch
KIKIT ?= kikit

all: jlcpcb_panel_2x2 jlcpcb_panel_2x3 pcbway_panel_2x2 pcbway_panel_2x3

IGNORES_JLCPCB :=
IGNORES_JLCPCB += J1
IGNORES_JLCPCB += R4
IGNORES_JLCPCB += R5
IGNORES_JLCPCB += RF24
IGNORES_JLCPCB += RF9
IGNORES_JLCPCB += U1

IGNORES_PCBWAY :=

null  :=
space := $(null) #
comma := ,

ifneq (,$(strip $(IGNORES_JLCPCB)))
  IGNORES_JLCPCB := --ignore $(subst $(space),$(comma),$(IGNORES_JLCPCB))
endif
ifneq (,$(strip $(IGNORES_PCBWAY)))
  IGNORES_PCBWAY := --ignore $(subst $(space),$(comma),$(IGNORES_PCBWAY))
endif

panel_2x2.kicad_pcb: $(PCB)
	$(KIKIT) panelize grid \
			--space 3 \
			--htabs 1 --vtabs 2 \
			--tabwidth 3 --tabheight 3 \
			--gridsize 2 2 \
			--mousebites 0.5 1 -0.25 \
			--radius 1 \
			--panelsize 80 90 \
			--tooling 5 2.5 1.5 \
			$(PCB) \
			$@

panel_2x3.kicad_pcb: $(PCB)
	$(KIKIT) panelize grid \
			--space 1 \
			--htabs 1 --vtabs 2 \
			--tabwidth 3 --tabheight 3 \
			--gridsize 2 3 \
			--mousebites 0.5 1.0 -0.2 \
			--radius 0.2 \
			--panelsize 100 90 \
			--tooling 13.5 1.5 1.5 \
			$(PCB) \
			$@

jlcpcb_panel_2x2: panel_2x2.kicad_pcb
	$(KIKIT) fab \
			jlcpcb \
			--schematic $(SCHEMATIC) \
			--assembly \
			$(IGNORES_JLCPCB) \
			$< \
			$@

jlcpcb_panel_2x3: panel_2x3.kicad_pcb
	$(KIKIT) fab \
			jlcpcb \
			--schematic $(SCHEMATIC) \
			--assembly \
			$(IGNORES_JLCPCB) \
			$< \
			$@

pcbway_panel_2x2: panel_2x2.kicad_pcb
	$(KIKIT) fab \
			pcbway \
			--schematic $(SCHEMATIC) \
			--assembly \
			$(IGNORES_PCBWAY) \
			--nBoards 4 \
			$< \
			$@

pcbway_panel_2x3: panel_2x3.kicad_pcb
	$(KIKIT) fab \
			pcbway \
			--schematic $(SCHEMATIC) \
			--assembly \
			$(IGNORES_PCBWAY) \
			--nBoards 6 \
			$< \
			$@

clean:
	rm -f panel_2x2.kicad_pcb panel_2x3.kicad_pcb
	rm -rf jlcpcb_panel_2x2 jlcpcb_panel_2x3 pcbway_panel_2x2 pcbway_panel_2x3
