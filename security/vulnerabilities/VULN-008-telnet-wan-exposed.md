# VULN-008: Telnet Service Exposed on WAN Interface

**Severity:** CRITICAL
**CWE:** CWE-284 (Improper Access Control)
**CVSS Estimation:** 9.8
**Component:** WAN TCP/IP Configuration (`web/internet.html`, firmware telnet daemon)

## Description

The router firmware includes a web UI toggle that allows enabling the Telnet service directly on the WAN (Internet-facing) interface. When enabled, an attacker on the public Internet can connect to the router's Telnet port without authentication beyond the default root credentials (see VULN-001). Combined with the hardcoded weak root password, this results in unauthenticated remote code execution on the device.

The JavaScript function `update_wan_telnet_port_state()` controls a checkbox named `WanTelnetEnable`. When checked, the `WanTelnetPort` field is enabled, allowing the user to specify which port Telnet listens on for WAN access. The `Load_Setting()` function initializes this from the NVRAM setting `WanTelnetEnable`. The port defaults to 23 if left at value "0".

## Evidence

**File:** `/squashfs-root/web/internet.html`

JavaScript handler (lines 198-207):
```javascript
//Start.Lance_wan_telnet_20170307
function update_wan_telnet_port_state()
{
    if (document.tcpip.WanTelnetEnable.checked){
        enableTextField(document.tcpip.WanTelnetPort);
    }
    else{
        disableTextField(document.tcpip.WanTelnetPort);		
    }
}
//End.Lance_wan_telnet_20170307
```

Loading state from NVRAM (lines 1107-1111):
```javascript
// Start. Lance_wan_telnet_20170307
if ( <% getIndex("WanTelnetEnable"); %> )
    document.tcpip.WanTelnetEnable.checked = true;
update_wan_telnet_port_state(); 
// End. Lance_wan_telnet_20170307
```

Default port assignment (lines 1024-1026):
```javascript
//Boomer_Telnet access from WAN_start
if (document.tcpip.WanTelnetPort.value == "0")
    document.tcpip.WanTelnetPort.value = 23;
//Boomer_Telnet access from WAN_start
```

Form validation for WAN Telnet port (lines 251-271):
```javascript
// Boomer_check_telnet_access_port_valid_start
if (document.tcpip.WanTelnetEnable.checked)
{
    if (document.tcpip.WanTelnetPort.value=="") {
        alert("Port cannot be empty! You should set a value between 1-65535.");
        document.tcpip.WanTelnetPort.focus();
        return false;
    }
    ...
}
// Boomer_check_telnet_access_port_valid_end
```

## Impact

- **Remote Code Execution:** An attacker on the Internet can Telnet into the router using the default weak root password and execute arbitrary commands as root.
- **Full Device Takeover:** With root shell access, the attacker can modify firmware, install persistent backdoors, sniff all network traffic, or pivot to other devices on the LAN.
- **Network Surveillance:** All traffic passing through the router can be intercepted and modified.

## References

- CWE-284: Improper Access Control
- RFC 854 - Telnet Protocol
- Realtek SDK telnet daemon implementation

## Status

- [ ] Not patched (default firmware)
