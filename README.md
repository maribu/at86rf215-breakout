AT86RF215 Breakout Board
========================

![AT86RF215 Breakout Boards Bottom Side](at86rf215-breakout-bottom.png)
![AT86RF215 Breakout Boards Top Side](at86rf215-breakout-top.png)

This Repository contains an minimal AT86RF215 breakout board. The pin header
is compatible to the openlabs.co Raspberry Pi 802.15.4 radio. However, this
will not be a drop-in replacement as the software needs adjustment.

WARNING
=======

1. The PCB contains no shielding for the RF filter, which will result in lower
   sensitivity and higher noise in the transmitted signal compared to e.g. the
   AT86RF215-XPRO reference design.
2. It is highly recommended to not order PCBs based on this design as of now.
   This design has never been tested.
3. There is absolutely no warranty.
