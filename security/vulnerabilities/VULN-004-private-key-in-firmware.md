# VULN-004: RSA Private Key Embedded in Firmware

**Severity:** CRITICAL
**CWE:** CWE-321 (Use of Hard-coded Cryptographic Key)
**CVSS Estimation:** 9.1
**Component:** `/etc/privateKey.key`

## Description

The firmware contains an RSA 2048-bit private key embedded in plaintext at `/etc/privateKey.key`. This key is present on every device shipped. If the device uses TLS/HTTPS, this key allows an attacker to decrypt all encrypted traffic, impersonate the device, or perform man-in-the-middle attacks. Because the same key is on every unit, a single key extraction from one device compromises TLS for the entire product line.

## Evidence

**`/etc/privateKey.key`:**
```
-----BEGIN PRIVATE KEY-----
MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDJg8JSYlseydd0
9BA/BSBConkAwAbGCsR7YzgQJi4yuWFlgEhIV+RMKQrIlV3EMhA4JGrPEggoAcQ2
zqeU1tdCKk8j4wT0ROoFs/n7fcp8szfRW4hcz0P0F16QLCPR/qWDLg4CnT0SlFGn
IxZye4eMLyTU+94J7tPk9noGgn0k5njyvbm6hWQQTCrQ28DsnOZSGdBtSWaO3y+W
Ljyx4TODc8GQC73pJJEft3h2WE4dKR1Rbs7YFHBnidq5C0AjZIQ96epBOL7xIrDt
nsyiJwstVK+/wAb5MkJGu1J0u7zwQ78rFlzDu3RsF+pAeucPtLf3eRKA4cwt81Yz
ofbt1jQfAgMBAAECggEAeiW4q1FdJEt6ozSxiFGmHV34dMDxGig6swQQXpGWHT8L
T4gzyE4mXxfdpnoLjTo/ZJiGeZ/Xe9CeTA51vB2B+2RD9l/Mh/gh1nUiiRPVokLM
CcYu4PrtmM51jnSC/e4aC2rmKSWAeHuZBvOYzqocHpgQ/lzxWRoALOBOVRXRn4RU
DMcDQfDYVZz01m9N7SNRdCxzRvohFdnNRXyIa8sd9Zm3fY+bPADDmPaojSJIkHox
sWOEfYmQ4AZWekDz4Y6Wri56KmOaSfGbfAjyqZrKBabxbFA/PgM/5+fjE/Kdguo2
Ga9C38o+FOtwB+E3avCzklin+Xc+sL9jdvOBcGceEQKBgQD1Z1h62zDPOAO358YV
eC3EEm4KnFYEbAmTSUS238wnPalSbMPU863n2cnJEbh0pWmnUzmIrQIA5mcNqJB5
4E8ER6MdcTG/QIRt5gcwSwk7hUPkuk+JP3COq+E62St4UI/JyoCwYU/yn5cHAmtJ
sAXIfKQEUquZnMNJ7FhzpVgbVwKBgQDSN0VpFt3jcW4WT0v+LxeBuxYjtqLQ9Xrp
oVcdfDil2uhZFw4wjr3G1b6N+w4MjaWuvoYtOnrgMTMM4oxaiSgE7cguHA1jHZXr
jpWxN15v4oWo98eVElfkoC7FPnvmroofOi5Ds+1ARAJ+7021y/Jnbwzzg2DTWkMq
tnVCvNP4eQKBgC977MHw8bPW6dlG7qwu0eQzkLla4MYARaYLMlGUYkNhigbZ5tao
xAitun6+gAuKCjSHRQWuPEoCSwR4jmQWxBNW7TgANBkGmdlN/iwZCNNMiQOUDVnI
PbZNicpCRUgFhp0MIvR+D+MpgCaqECp09dmCTJZNjMivbZY7Ni5CWxcHAoGAduo/
QIhn8q6K2OH4mgxnnsKHbqJ1DgGfiyPylMJdhS0FPMh3BW7p2d210rlPJDjIncY3
PsSTF9mdCE/rl5d45PjhwXuq8wOceEkLUtmAeYhJleC8rQ5YXANlEb0b982KYsnV
vAS/VBhk1QtoCUwajvpZ+DK8hjLMRhA62wrYWfkCgYAz1thEA+psEwt4uNl8YChw
p4sUhhucIkU3+8+TjZqt3I64pYzkowsjTdGLXFr5+1WadGDPk405OACfQGrKnx9A
rMeb33x0m3zGFucziWIlo3UH6mD4jNVanFSK/OTOVMNmQ7R+UcALOQfLQnlC05Mr
YKlQ0kxMhBAp6G7HPCWFtA==
-----END PRIVATE KEY-----
```

The key is a standard PKCS#8 RSA 2048-bit private key stored in plaintext with no file permission restrictions.

## Impact

- An attacker extracting the firmware (via JTAG, SPI flash dump, or firmware update interception) obtains the private key.
- If the device uses TLS, all encrypted communications can be decrypted.
- The attacker can impersonate the device in TLS handshakes.
- The same key across all devices means one extraction compromises the entire fleet.
- If used for SSH or other protocols, the device cannot establish secure connections.

## References

- CWE-321: https://cwe.mitre.org/data/definitions/321.html
- CWE-798: https://cwe.mitre.org/data/definitions/798.html
- Similar: CVE-2019-5591 (FortiGate hardcoded key), CVE-2021-33054 (Ruckus private key in firmware)

## Status
- [ ] Not patched (default firmware)
