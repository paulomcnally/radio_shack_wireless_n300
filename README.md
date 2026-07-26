# RadioShack Wireless N300M - Firmware Dump

Firmware extraction and documentation for the **RadioShack Wireless N300M** router (Realtek RTL8196E).

## Router Specifications

| Field | Value |
|-------|-------|
| Chipset | Realtek RTL8196E |
| Model | N300M (Wireless AP/Router) |
| Firmware Version | `RER4_A_v3411bN_2T2R_RAD_02_180301` |
| SDK | Realtek SDK v3.4.11-r38403 |
| Kernel | Linux 3.10.90 (MIPS) |
| Web Server | Boa 0.94.14rc21 |
| Flash | 8 MB |
| RAM | 24 MB |
| BusyBox | v1.13.4 |

## Firmware Files

| File | Size | Description |
|------|------|-------------|
| `firmware/mtd0.bin` | 2 MB | Bootloader + Kernel (MIPS binary) |
| `firmware/mtd1.bin` | 6 MB | Root filesystem (SquashFS 4.0, XZ compressed) |
| `firmware/firmware_RTL8196E_N300M.bin` | 8 MB | Complete firmware image (mtd0 + mtd1 concatenated) |

## Root Filesystem Contents

The extracted rootfs (`squashfs-root/`) contains 875 inodes with the following structure:

- `/bin/` - BusyBox and router utilities (boa, auth, iptables, etc.)
- `/web/` - Web interface (HTML/JS/CSS)
- `/etc/boa/` - Boa web server configuration
- `/etc/init.d/rcS` - Boot initialization script
- `/etc/passwd_orig` - Default password hashes
- `/lib/` - Shared libraries

## Documentation

See [docs/EXTRACTION_GUIDE.md](docs/EXTRACTION_GUIDE.md) for the complete firmware extraction procedure.

## License

This repository is for educational and research purposes only.
