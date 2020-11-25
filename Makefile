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
	./panelize.py $(PCB) $@ 2

panel_2x3.kicad_pcb: $(PCB)
	./panelize.py $(PCB) $@ 3

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
