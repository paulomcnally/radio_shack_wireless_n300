# VULN-001: Hardcoded Root Password with Weak MD5 Hash

**Severity:** CRITICAL
**CWE:** CWE-798 (Use of Hard-coded Credentials)
**CVSS Estimation:** 9.8
**Component:** `/etc/passwd_orig`, `/etc/shadow.sample`

## Description

The firmware contains a hardcoded root password using an MD5-based hash (`$1$`). The MD5 hashing algorithm is cryptographically weak and fast to brute-force using modern GPU-based cracking tools (e.g., Hashcat, John the Ripper). The same password hash is shipped on every device, meaning a single successful crack yields root access to all units of this model. Additionally, the `/etc/passwd_orig` file exposes the hash in the world-readable passwd format, and `/etc/shadow.sample` provides a secondary reference hash, both trivially extractable from the firmware image.

## Evidence

**`/etc/passwd_orig`:**
```
root:$1$HG1TCmqu$gm4kfn6PczH8dA.yfUN2F/:0:0:root:/:/bin/sh
nobody:x:0:0:nobody:/:/dev/null
```

**`/etc/shadow.sample`:**
```
root:$1$KEKJV2R0$TFJ4jy7waGKrjdNHwPGzV.:14587:0:99999:7:::
nobody:*:14495:0:99999:7:::
```

The `$1$` prefix identifies the hash as MD5-crypt. Both files use different salts but are derived from the same factory default password.

## Impact

- An attacker who extracts the firmware image can crack the root password offline in seconds to minutes.
- Once cracked, the attacker gains full root access to the device via telnet (VULN-002), the web interface (VULN-003), or serial console (VULN-007).
- Because the hash is identical across all devices, a single crack compromises every unit of this model worldwide.
- Root access allows complete device takeover: traffic interception, DNS hijacking, firmware modification, and pivot into the local network.

## References

- CWE-798: https://cwe.mitre.org/data/definitions/798.html
- NIST SP 800-63B: Deprecated password hashing guidance
- Similar: CVE-2023-1389 (TP-Link hardcoded credentials)

## Status
- [ ] Not patched (default firmware)
