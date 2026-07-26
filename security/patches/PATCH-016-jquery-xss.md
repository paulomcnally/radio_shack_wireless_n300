# PATCH-016: jQuery Cross-Site Scripting (XSS)

**Vulnerability:** VULN-016
**Complexity:** Medium
**Requires Recompilation:** Yes
**Risk Level:** Medium

## Recommended Fix

Update jQuery from 1.8.3 to 3.x and audit all JavaScript for deprecated API usage. jQuery 1.x contains multiple known XSS vulnerabilities including CVE-2015-9251, CVE-2019-11358, and CVE-2020-11022/11023.

## Changes Required

### /www/js/jquery.min.js
```
-/*! jQuery v1.8.3 | (c) 2005,2012 jQuery Foundation, Inc. | jquery.org/license */
+/*! jQuery v3.7.1 | (c) jQuery Foundation | jquery.org/license */
```

Full replacement required. Download from: https://code.jquery.com/jquery-3.7.1.min.js

### /www/js/common.js
```
-$("#msg").html(data);
+$("#msg").text(data);

-$(location).attr('href', url);
+window.location.href = url;

-$.eval(data);
+// Remove eval usage entirely, use JSON.parse()
+try { JSON.parse(data); } catch(e) { console.error(e); }
```

### /www/js/main.js
```
-$.get("/cgi-bin/api?" + param, function(resp) {
-    eval(resp);
+$.get("/cgi-bin/api?" + param, function(resp) {
+    try {
+        var data = JSON.parse(resp);
+        // handle data
+    } catch(e) {
+        console.error("Invalid response");
+    }
```

### /www/index.html
```
-<script src="/js/jquery-1.8.3.min.js"></script>
+<script src="/js/jquery-3.7.1.min.js"></script>
```

## Verification

```bash
# Check jQuery version in bundled files
grep -o "jQuery v[0-9.]*" /www/js/jquery.min.js

# Grep for deprecated API usage
grep -rn "\.html(" /www/js/*.js
grep -rn "eval(" /www/js/*.js
grep -rn "\.attr.*href" /www/js/*.js

# Test with curl - inject XSS payload in form fields
curl -X POST http://192.168.1.1/cgi-bin/api \
  -d "ssid=<script>alert(1)</script>"
```

## Notes

- jQuery 3.x drops IE6-8 support (not relevant for router web UI)
- Some plugins may rely on deprecated `.bind()` / `.unbind()` - replace with `.on()` / `.off()`
- Test all web UI pages after update for broken functionality
- Consider replacing jQuery entirely with vanilla JS for long-term maintenance
