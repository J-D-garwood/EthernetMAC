# EthernetMAC

Ethernet MAC written in Verilog for the ALINX AX7A035B board (Artix-7 XC7A35T) with a JL2121 PHY over RGMII.

## What it does
- Resets the PHY and reads link speed, duplex and link status over MDIO
- RX: RGMII -> async FIFO -> frame parser (CRC check) -> filter (my MAC + broadcast)
- TX: frame FSM adds preamble, SFD, source MAC, padding and CRC -> RGMII
- Works at 10 / 100 / 1000 Mbps

## Folders
- `src/` - Verilog
- `constraints/` - XDC files (`constraints_basic.xdc` is the current one)
- `testbenches/` - simulation testbenches
- `data/iladata/` - ila captures
- `archive/`, `src/archived_verilog/` - old versions

## Build
- Vivado 2025.2, part `xc7a35tfgg484-2`
- Top module: `top`
- Clocking wizard `clk_wiz_0`: 200 MHz in -> 125, 25 and 200 MHz out

## Testing
- Laptop on a direct cable, eth adapter set to static IP 192.168.1.1
- Board MAC: 2E:FC:32:BA:7C:99, IP: 192.168.1.10
- Checked with Wireshark (TX) and the Vivado ila (RX)

## Progress
See `projectlogs.md`.
