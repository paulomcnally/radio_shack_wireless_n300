# VULN-007: Unauthenticated Root Shell on Serial Console

**Severity:** CRITICAL
**CWE:** CWE-306 (Missing Authentication for Critical Function)
**CVSS Estimation:** 6.8
**Component:** `/etc/inittab`

## Description

The `inittab` configuration spawns a root shell (`/bin/sh`) directly on the serial console without any authentication prompt. The `respawn` action ensures the shell is automatically restarted if terminated, and the `-` prefix before `/bin/sh` disables login entirely (no `getty` or password prompt). An attacker with physical access to the serial console (UART pads on the PCB) gains an immediate root shell with no credentials required.

## Evidence

**`/etc/inittab`:**
```
# Boot-time system configuration/initialization script.
::sysinit:/etc/init.d/rcS

# Start an "askfirst" shell on the console (whatever that may be)
#::askfirst:-/bin/sh
::respawn:-/bin/sh

# Start an "askfirst" shell on /dev/tty2-4
#tty2::askfirst:-/bin/sh
#tty3::askfirst:-/bin/sh
#tty4::askfirst:-/bin/sh
```

Line 6 (`::respawn:-/bin/sh`) is the active configuration. The commented-out `::askfirst:-/bin/sh` on line 5 shows that authentication was considered but deliberately disabled. The `respawn` action means the shell restarts automatically, and the `-` prefix suppresses the login process entirely.

Additionally, the boot script copies the shadow file for console login (line 54 of `rcS_32M`):
```bash
# for console login
cp /etc/shadow.sample /var/shadow
```

This suggests console login was intended but the `inittab` bypasses it entirely.

## Impact

- An attacker with physical access to the UART serial pads on the PCB gets immediate root access.
- No password, no authentication, no prompt—just a root shell.
- Physical access allows firmware extraction, modification, and persistent implant installation.
- The serial console is accessible via inexpensive USB-to-serial adapters ($5-10).
- Combined with VULN-001 (hardcoded password), even the intended login mechanism offers no real security.

## References

- CWE-306: https://cwe.mitre.org/data/definitions/306.html
- CWE-1188: https://cwe.mitre.org/data/definitions/1188.html (Initialization with Hard-Coded Network Configuration)
- Similar: CVE-2021-25370 (Axis camera serial console bypass)

## Status
- [ ] Not patched (default firmware)
