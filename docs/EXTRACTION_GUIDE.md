# Firmware Extraction Guide - RadioShack Wireless N300M

Complete guide for extracting firmware from the RadioShack Wireless N300M router (Realtek RTL8196E).

## Prerequisites

- Network access to the router (default IP: `192.168.1.153`)
- Python 3 installed on your machine
- curl installed

## Step 1: Access the Web Interface

The router uses HTTP Basic Authentication.

```bash
curl -k -s -u admin:<password> http://192.168.1.153/index.htm
```

The firmware version can be found at `http://192.168.1.153/upgrade.html`:

```
RER4_A_v3411bN_2T2R_RAD_02_180301
Built: Thu Mar 1 14:57:44 CST 2018
```

## Step 2: Telnet Access (Root Shell)

The router has **telnet enabled by default** on port 23.

```bash
nmap -sV -p 22,23,80,443 192.168.1.153
```

Output:
```
PORT   STATE SERVICE VERSION
22/tcp closed ssh
23/tcp open  telnet  NASLite-SMB/Sveasoft Alchemy firmware telnetd
80/tcp open  http    Boa HTTPd 0.94.14rc21
Service Info: Host: rlx-linux
```

### Login Credentials

| Service | Username | Password |
|---------|----------|----------|
| Web UI | admin | admin (default) |
| Telnet | root | password (default) |

```bash
telnet 192.168.1.153
# Login: root
# Password: password
```

You will see:
```
RLX Linux version 2.0
         _           _  _
        | |         | ||_|
   _  _ | | _  _    | | _ ____  _   _  _  _
  | |/ || |\ \/ /   | || |  _ \| | | |\ \/ /
  | |_/ | |/    \   | || | | | | |_| |/    \
  |_|   |_|\_/\_/   |_||_|_| |_|\____|\_/\_/
```

## Step 3: Identify MTD Partitions

```bash
cat /proc/mtd
```

Output:
```
dev:    size   erasesize  name
mtd0: 00200000 00001000 "boot+cfg+linux"
mtd1: 00600000 00001000 "rootfs"
```

| Partition | Size | Name | Description |
|-----------|------|------|-------------|
| mtd0 | 2 MB (0x200000) | boot+cfg+linux | Bootloader + Kernel |
| mtd1 | 6 MB (0x600000) | rootfs | SquashFS root filesystem |

### Additional Info

```bash
cat /etc/version
```

```
RTL8196E v1.0 --  Thu Mar 1 14:57:28 CST 2018
The SDK version is: Realtek SDK v3.4.11-r38403
Ethernet driver version is: 35416-35420
Wireless driver version is: 38400-38400
```

```bash
cat /proc/cpuinfo
```

```
system type             : RTL8196E
processor               : 0
cpu model               : 52481
BogoMIPS                : 398.13
```

## Step 4: Extract Firmware via HTTP

**Important:** The router has only 24 MB of RAM. Do NOT write large files to `/tmp` or `/var` simultaneously, as this will crash the router.

### Method: Overwrite config.dat and Download

The file `/var/config.dat` is served via HTTP at `http://192.168.1.153/config.dat`. We can overwrite it with firmware data and download it.

#### Extract mtd0 (2 MB)

```python
import socket
import time

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.settimeout(10)
s.connect(('192.168.1.153', 23))
time.sleep(1)
s.recv(4096)
s.sendall(b'root\r\n')
time.sleep(1)
s.recv(4096)
s.sendall(b'password\r\n')
time.sleep(2)
s.recv(4096)

# Dump mtd0 to /var/config.dat
s.sendall(b'cat /dev/mtdblock0 > /var/config.dat\r\n')
time.sleep(5)
s.recv(65536)
s.close()
```

```bash
curl -k -s -u admin:<password> "http://192.168.1.153/config.dat" -o mtd0.bin
```

Verify size: `mtd0.bin` should be exactly **2,097,152 bytes**.

#### Extract mtd1 (6 MB)

**First, delete the previous file to free RAM:**

```python
s.sendall(b'rm /var/config.dat\r\n')
time.sleep(2)
s.recv(65536)

# Dump mtd1 to /var/config.dat
s.sendall(b'cat /dev/mtdblock1 > /var/config.dat\r\n')
time.sleep(10)
s.recv(65536)
s.close()
```

```bash
curl -k -s -u admin:<password> "http://192.168.1.153/config.dat" -o mtd1.bin
```

Verify size: `mtd1.bin` should be exactly **6,291,456 bytes**.

#### Create Complete Firmware Image

```bash
cat mtd0.bin mtd1.bin > firmware_RTL8196E_N300M.bin
```

Total size: **8,388,608 bytes** (8 MB).

## Step 5: Extract Root Filesystem

The rootfs is a **SquashFS 4.0** filesystem with **XZ compression**.

```bash
file mtd1.bin
```

```
Squashfs filesystem, little endian, version 4.0, xz compressed,
4007118 bytes, 875 inodes, blocksize: 131072 bytes
```

Extract with `unsquashfs`:

```bash
unsquashfs -d squashfs-root mtd1.bin
```

This creates the `squashfs-root/` directory with the full filesystem.

## Step 6: Analyze the Filesystem

### Boot Script

```bash
cat squashfs-root/etc/init.d/rcS
```

Key findings:
- The router runs **BusyBox v1.13.4** (ash shell)
- **Boa web server** starts at boot
- **Telnet daemon** is started at boot (`telnetd&`)
- `/var` is mounted as **ramfs** (writable)
- `/web` is part of the **SquashFS** root (read-only)

### Default Credentials

```bash
cat squashfs-root/etc/passwd_orig
```

```
root:$1$HG1TCmqu$gm4kfn6PczH8dA.yfUN2F/:0:0:root:/:/bin/sh
nobody:x:0:0:nobody:/:/dev/null
```

### Web Server Configuration

```bash
cat squashfs-root/etc/boa/boa.conf
```

Key settings:
- `Port 80`
- `DocumentRoot /web`
- `CGIPath /bin:/usr/bin:/web/cgi-bin/`
- `SinglePostLimit 0x800000` (8 MB max upload)

### Firmware Upgrade Endpoint

The firmware upload form is at `http://192.168.1.153/upgrade.html` and posts to `/boafrm/formUpload`. It accepts `.bin` files only.

## Modifying the Firmware

### Recompress the RootFS

```bash
mksquashfs squashfs-root/ mtd1_new.bin -comp xz -b 131072
```

### Flash via HTTP Upload

1. Replace `mtd1.bin` in the web interface upgrade page
2. Or use telnet to write directly to flash:

```bash
# From telnet (root shell)
cat /tmp/mtd1_new.bin > /dev/mtdblock1
reboot
```

## Troubleshooting

### Router Becomes Unresponsive

If the router stops responding to HTTP/telnet (usually due to RAM exhaustion):

1. **Power cycle**: Unplug the router, wait 10 seconds, plug it back in
2. The firmware files in `/tmp` or `/var` are stored in RAM and will be lost on reboot
3. Always delete temporary files before creating new ones

### Telnet Connection Drops

The BusyBox telnetd has a limited number of connections. If the connection drops:

```bash
# Wait 30 seconds, then reconnect
sleep 30 && telnet 192.168.1.153
```

### Memory Constraints

The router has only 24 MB RAM. Key limits:
- Do not store more than ~6 MB in `/tmp` or `/var` at once
- The Boa web server needs ~1-2 MB for operation
- Download one partition at a time using the config.dat method

## MTD Partition Map

```
Flash Layout (8 MB total):
┌─────────────────────────────────┐ 0x00000000
│  mtd0: boot+cfg+linux (2 MB)   │
│  - Bootloader (Realtek)         │
│  - Kernel (Linux 3.10.90)       │
│  - Configuration data           │
├─────────────────────────────────┤ 0x00200000
│  mtd1: rootfs (6 MB)           │
│  - SquashFS 4.0 (XZ)           │
│  - /bin, /web, /etc, /lib...    │
│  - 875 inodes, 73 fragments    │
└─────────────────────────────────┘ 0x00800000
```
