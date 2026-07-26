# VULN-015: Expired TLS Certificate Hardcoded in Firmware

**Severity:** HIGH
**CWE:** CWE-295 (Improper Certificate Validation)
**CVSS Estimation:** 7.5
**Component:** `/etc/certificate.crt`

## Description

The firmware contains a self-signed TLS certificate that expired on December 19, 2014. The certificate is issued to `CN=192.168.1.254` with an embedded developer email address `patrick_cai_rs@163.com`. This certificate is identical across all devices of this model, creating a shared trust anchor vulnerability. The certificate uses SHA-1 with RSA encryption, which is cryptographically deprecated. The expiration and self-signed nature means HTTPS connections to the device will always show security warnings, training users to ignore certificate errors.

## Evidence

**`/etc/certificate.crt`:**
```
-----BEGIN CERTIFICATE-----
MIID1TCCAr2gAwIBAgIJAJgfmJDpHfDvMA0GCSqGSIb3DQEBBQUAMIGAMQswCQYD
VQQGEwJDTjELMAkGA1UECAwCSlMxCzAJBgNVBAcMAlNaMQswCQYDVQQKDAJSUzEL
MAkGA1UECwwCV04xFjAUBgNVBAMMDTE5Mi4xNjguMS4yNTQxJTAjBgkqhkiG9w0B
CQEWFnBhdHJpY2tfY2FpX3JzQDE2My5jb20wHhcNMTMxMjE5MTAyMTAxWhcNMTQx
MjE5MTAyMTAxWjCBgDELMAkGA1UEBhMCQ04xCzAJBgNVBAgMAkpTMQswCQYDVQQH
DAJTWjELMAkGA1UECgwCUlMxCzAJBgNVBAsMAldOMRYwFAYDVQQDDA0xOTIuMTY4
LjEuMjU0MSUwIwYJKoZIhvcNAQkBFhZwYXRyaWNrX2NhaV9yc0AxNjMuY29tMIIB
IjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyYPCUmJbHsnXdPQQPwUgQqJ5
AMAGxgrEe2M4ECYuMrlhZYBISFfkTCkKyJVdxDIQOCRqzxIIKAHENs6nlNbXQipP
```

**Certificate Details (from openssl output):**
```
Issuer: C = CN, ST = JS, L = SZ, O = RS, OU = WN, CN = 192.168.1.254, emailAddress = patrick_cai_rs@163.com
Validity
    Not Before: Dec 19 10:21:01 2013 GMT
    Not After : Dec 19 10:21:01 2014 GMT
Subject: C = CN, ST = JS, L = SZ, O = RS, OU = WN, CN = 192.168.1.254, emailAddress = patrick_cai_rs@163.com
Signature Algorithm: sha1WithRSAEncryption
```

## Impact

- **Certificate Warning Training**: Users are conditioned to ignore HTTPS warnings, making them vulnerable to real MITM attacks.
- **Developer Information Leakage**: The embedded email `patrick_cai_rs@163.com` exposes internal developer information.
- **Shared Private Key**: Same certificate on every device means compromise of one device's private key compromises all devices.
- **SHA-1 Weakness**: SHA-1 is cryptographically broken; collision attacks are practical.
- **MITM Vulnerability**: Expired certificate prevents proper TLS validation, enabling man-in-the-middle attacks on management interfaces.

## References

- CWE-295: https://cwe.mitre.org/data/definitions/295.html
- NIST SP 800-57: Deprecated SHA-1 usage
- Similar: CVE-2014-0160 (Heartbleed - TLS validation issues)

## Status
- [ ] Not patched (default firmware)
