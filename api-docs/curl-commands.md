# F5 BIG-IP GSLB API - Complete curl Commands Reference

This document contains all the curl commands used to extract the complete GSLB configuration from F5 BIG-IP devices.

## ? Table of Contents

- [Authentication](#authentication)
- [Discovery Commands](#discovery-commands)
- [Wide IP Analysis](#wide-ip-analysis)
- [GTM Configuration](#gtm-configuration)
- [LTM Configuration](#ltm-configuration)
- [Health Monitoring](#health-monitoring)
- [Complete Example](#complete-example)

## ? Authentication

All commands use basic authentication with the `-k` flag to ignore SSL certificate warnings:

```bash
# Basic format
curl -k -u admin:password -X GET https://F5_IP/mgmt/tm/ENDPOINT

# Example with our test device
curl -k -u admin:W3lcome098! -X GET https://172.16.10.10/mgmt/tm/sys/version
```

## ? Discovery Commands

### 1. System Information

```bash
# Get F5 system version and information
curl -k -u admin:W3lcome098! -X GET https://172.16.10.10/mgmt/tm/sys/version

# Get system global settings
curl -k -u admin:W3lcome098! -X GET https://172.16.10.10/mgmt/tm/sys/global-settings
```

### 2. GTM Module Status

```bash
# Check GTM module status
curl -k -u admin:W3lcome098! -X GET https://172.16.10.10/mgmt/tm/sys/provision

# Get GTM global settings
curl -k -u admin:W3lcome098! -X GET https://172.16.10.10/mgmt/tm/gtm/global-settings
```

## ? Wide IP Analysis

### 1. List All Wide IP Types

```bash
# Get all Wide IP categories
curl -k -u admin:W3lcome098! -X GET https://172.16.10.10/mgmt/tm/gtm/wideip
```

**Response:**
```json
{
  "kind": "tm:gtm:wideip:wideipcollectionstate",
  "selfLink": "https://localhost/mgmt/tm/gtm/wideip?ver=17.5.0",
  "items": [
    {"reference": {"link": "https://localhost/mgmt/tm/gtm/wideip/a?ver=17.5.0"}},
    {"reference": {"link": "https://localhost/mgmt/tm/gtm/wideip/aaaa?ver=17.5.0"}},
    {"reference": {"link": "https://localhost/mgmt/tm/gtm/wideip/cname?ver=17.5.0"}},
    {"reference": {"link": "https://localhost/mgmt/tm/gtm/wideip/https?ver=17.5.0"}},
    {"reference": {"link": "https://localhost/mgmt/tm/gtm/wideip/mx?ver=17.5.0"}},
    {"reference": {"link": "https://localhost/mgmt/tm/gtm/wideip/naptr?ver=17.5.0"}},
    {"reference": {"link": "https://localhost/mgmt/tm/gtm/wideip/srv?ver=17.5.0"}},
    {"reference": {"link": "https://localhost/mgmt/tm/gtm/wideip/svcb?ver=17.5.0"}}
  ]
}
```

### 2. Get A Record Wide IPs

```bash
# List all A record Wide IPs
curl -k -u admin:W3lcome098! -X GET https://172.16.10.10/mgmt/tm/gtm/wideip/a
```

### 3. Get Specific Wide IP Details

```bash
# Get detailed information for specific Wide IP
curl -k -u admin:W3lcome098! -X GET https://172.16.10.10/mgmt/tm/gtm/wideip/a/~Common~juice.gslb.maniak.lab
```

## ? GTM Configuration

### 1. Get GTM Pool Details

```bash
# Get specific GTM pool configuration
curl -k -u admin:W3lcome098! -X GET https://172.16.10.10/mgmt/tm/gtm/pool/a/~Common~juice.gslb.maniak.lab
```

### 2. Get GTM Pool Members

```bash
# Get GTM pool members
curl -k -u admin:W3lcome098! -X GET https://172.16.10.10/mgmt/tm/gtm/pool/a/~Common~juice.gslb.maniak.lab/members
```

### 3. Get GTM Servers

```bash
# Get all GTM servers
curl -k -u admin:W3lcome098! -X GET https://172.16.10.10/mgmt/tm/gtm/server
```

### 4. Get GTM Virtual Servers

```bash
# Get GTM virtual servers for a specific server
curl -k -u admin:W3lcome098! -X GET https://172.16.10.10/mgmt/tm/gtm/server/~Common~bigip/virtual-servers
```

## ? LTM Configuration

### 1. Get All Virtual Servers

```bash
# Get all LTM virtual servers
curl -k -u admin:W3lcome098! -X GET https://172.16.10.10/mgmt/tm/ltm/virtual
```

### 2. Get Specific Virtual Server

```bash
# Get specific virtual server details
curl -k -u admin:W3lcome098! -X GET https://172.16.10.10/mgmt/tm/ltm/virtual/~Common~juiceshop
```

### 3. Get LTM Pool Configuration

```bash
# Get LTM pool details
curl -k -u admin:W3lcome098! -X GET https://172.16.10.10/mgmt/tm/ltm/pool/~Common~juiceshop_pool
```

### 4. Get LTM Pool Members

```bash
# Get LTM pool members
curl -k -u admin:W3lcome098! -X GET https://172.16.10.10/mgmt/tm/ltm/pool/~Common~juiceshop_pool/members
```

## ? Health Monitoring

### 1. Get Monitor Details

```bash
# Get HTTP monitor configuration
curl -k -u admin:W3lcome098! -X GET https://172.16.10.10/mgmt/tm/ltm/monitor/http/~Common~juiceshop_http_monitor
```

### 2. Get All Monitor Types

```bash
# Get all available monitor types
curl -k -u admin:W3lcome098! -X GET https://172.16.10.10/mgmt/tm/ltm/monitor

# Get specific monitor type
curl -k -u admin:W3lcome098! -X GET https://172.16.10.10/mgmt/tm/ltm/monitor/http
```

## ? Complete Example: juice.gslb.maniak.lab Analysis

Here's the complete sequence of commands used to analyze the `juice.gslb.maniak.lab` configuration:

```bash
#!/bin/bash

# Configuration
F5_HOST="172.16.10.10"
F5_USER="admin"
F5_PASS="W3lcome098!"
WIDE_IP="juice.gslb.maniak.lab"

echo "=== F5 BIG-IP GSLB Configuration Analysis ==="
echo "Device: $F5_HOST"
echo "Wide IP: $WIDE_IP"
echo "================================================"

# Step 1: Discover Wide IP types
echo "Step 1: Discovering Wide IP types..."
curl -k -u $F5_USER:$F5_PASS -X GET https://$F5_HOST/mgmt/tm/gtm/wideip

# Step 2: Get A record Wide IPs
echo "Step 2: Getting A record Wide IPs..."
curl -k -u $F5_USER:$F5_PASS -X GET https://$F5_HOST/mgmt/tm/gtm/wideip/a

# Step 3: Get specific Wide IP details
echo "Step 3: Getting specific Wide IP details..."
curl -k -u $F5_USER:$F5_PASS -X GET https://$F5_HOST/mgmt/tm/gtm/wideip/a/~Common~$WIDE_IP

# Step 4: Get GTM pool details
echo "Step 4: Getting GTM pool details..."
curl -k -u $F5_USER:$F5_PASS -X GET https://$F5_HOST/mgmt/tm/gtm/pool/a/~Common~$WIDE_IP

# Step 5: Get GTM pool members
echo "Step 5: Getting GTM pool members..."
curl -k -u $F5_USER:$F5_PASS -X GET https://$F5_HOST/mgmt/tm/gtm/pool/a/~Common~$WIDE_IP/members

# Step 6: Get GTM servers
echo "Step 6: Getting GTM servers..."
curl -k -u $F5_USER:$F5_PASS -X GET https://$F5_HOST/mgmt/tm/gtm/server

# Step 7: Get GTM virtual servers
echo "Step 7: Getting GTM virtual servers..."
curl -k -u $F5_USER:$F5_PASS -X GET https://$F5_HOST/mgmt/tm/gtm/server/~Common~bigip/virtual-servers

# Step 8: Get all LTM virtual servers
echo "Step 8: Getting all LTM virtual servers..."
curl -k -u $F5_USER:$F5_PASS -X GET https://$F5_HOST/mgmt/tm/ltm/virtual

# Step 9: Get specific LTM virtual server
echo "Step 9: Getting specific LTM virtual server..."
curl -k -u $F5_USER:$F5_PASS -X GET https://$F5_HOST/mgmt/tm/ltm/virtual/~Common~juiceshop

# Step 10: Get LTM pool configuration
echo "Step 10: Getting LTM pool configuration..."
curl -k -u $F5_USER:$F5_PASS -X GET https://$F5_HOST/mgmt/tm/ltm/pool/~Common~juiceshop_pool

# Step 11: Get LTM pool members
echo "Step 11: Getting LTM pool members..."
curl -k -u $F5_USER:$F5_PASS -X GET https://$F5_HOST/mgmt/tm/ltm/pool/~Common~juiceshop_pool/members

# Step 12: Get monitor details
echo "Step 12: Getting monitor details..."
curl -k -u $F5_USER:$F5_PASS -X GET https://$F5_HOST/mgmt/tm/ltm/monitor/http/~Common~juiceshop_http_monitor

echo "=== Analysis Complete ==="
```

## ? Advanced Commands

### 1. Bulk Data Collection

```bash
# Get all configurations in parallel
#!/bin/bash
F5_HOST="172.16.10.10"
F5_USER="admin"
F5_PASS="W3lcome098!"

# Create output directory
mkdir -p f5-config-export

# Export all Wide IPs
curl -k -u $F5_USER:$F5_PASS -X GET https://$F5_HOST/mgmt/tm/gtm/wideip/a > f5-config-export/wideips.json

# Export all GTM pools
curl -k -u $F5_USER:$F5_PASS -X GET https://$F5_HOST/mgmt/tm/gtm/pool/a > f5-config-export/gtm-pools.json

# Export all GTM servers
curl -k -u $F5_USER:$F5_PASS -X GET https://$F5_HOST/mgmt/tm/gtm/server > f5-config-export/gtm-servers.json

# Export all LTM virtual servers
curl -k -u $F5_USER:$F5_PASS -X GET https://$F5_HOST/mgmt/tm/ltm/virtual > f5-config-export/ltm-virtual.json

# Export all LTM pools
curl -k -u $F5_USER:$F5_PASS -X GET https://$F5_HOST/mgmt/tm/ltm/pool > f5-config-export/ltm-pools.json

# Export all monitors
curl -k -u $F5_USER:$F5_PASS -X GET https://$F5_HOST/mgmt/tm/ltm/monitor > f5-config-export/monitors.json
```

### 2. Health Status Monitoring

```bash
# Get pool member status
curl -k -u $F5_USER:$F5_PASS -X GET https://$F5_HOST/mgmt/tm/ltm/pool/~Common~juiceshop_pool/members/stats

# Get virtual server statistics
curl -k -u $F5_USER:$F5_PASS -X GET https://$F5_HOST/mgmt/tm/ltm/virtual/~Common~juiceshop/stats

# Get GTM Wide IP statistics
curl -k -u $F5_USER:$F5_PASS -X GET https://$F5_HOST/mgmt/tm/gtm/wideip/a/~Common~juice.gslb.maniak.lab/stats
```

### 3. Configuration Modification

```bash
# Enable/Disable Wide IP
curl -k -u $F5_USER:$F5_PASS -X PATCH https://$F5_HOST/mgmt/tm/gtm/wideip/a/~Common~juice.gslb.maniak.lab \
  -H "Content-Type: application/json" \
  -d '{"enabled": false}'

# Add pool member
curl -k -u $F5_USER:$F5_PASS -X POST https://$F5_HOST/mgmt/tm/ltm/pool/~Common~juiceshop_pool/members \
  -H "Content-Type: application/json" \
  -d '{"name": "192.168.1.100:80", "address": "192.168.1.100", "port": 80}'

# Remove pool member
curl -k -u $F5_USER:$F5_PASS -X DELETE https://$F5_HOST/mgmt/tm/ltm/pool/~Common~juiceshop_pool/members/~Common~192.168.1.100:80
```

## ?? Troubleshooting Commands

### 1. DNS Resolution Testing

```bash
# Test DNS resolution from F5
curl -k -u $F5_USER:$F5_PASS -X POST https://$F5_HOST/mgmt/tm/gtm/wideip/a/~Common~juice.gslb.maniak.lab/resolve \
  -H "Content-Type: application/json" \
  -d '{"clientIp": "8.8.8.8"}'
```

### 2. Pool Member Health Check

```bash
# Force pool member health check
curl -k -u $F5_USER:$F5_PASS -X POST https://$F5_HOST/mgmt/tm/ltm/pool/~Common~juiceshop_pool/members/~Common~172.100.100.11:1521 \
  -H "Content-Type: application/json" \
  -d '{"session": "monitor-enabled", "state": "unchecked"}'
```

### 3. Configuration Validation

```bash
# Validate configuration
curl -k -u $F5_USER:$F5_PASS -X GET https://$F5_HOST/mgmt/tm/sys/config

# Check for configuration errors
curl -k -u $F5_USER:$F5_PASS -X GET https://$F5_HOST/mgmt/tm/sys/log-config
```

## ? Response Format Examples

### Wide IP Response
```json
{
  "kind": "tm:gtm:wideip:a:astate",
  "name": "juice.gslb.maniak.lab",
  "partition": "Common",
  "fullPath": "/Common/juice.gslb.maniak.lab",
  "generation": 1735,
  "selfLink": "https://localhost/mgmt/tm/gtm/wideip/a/~Common~juice.gslb.maniak.lab?ver=17.5.0",
  "enabled": true,
  "failureRcode": "noerror",
  "failureRcodeResponse": "disabled",
  "failureRcodeTtl": 0,
  "lastResortPool": "",
  "minimalResponse": "enabled",
  "persistCidrIpv4": 32,
  "persistCidrIpv6": 128,
  "persistence": "disabled",
  "poolLbMode": "round-robin",
  "topologyPreferEdns0ClientSubnet": "disabled",
  "ttlPersistence": 3600,
  "pools": [
    {
      "name": "juice.gslb.maniak.lab",
      "partition": "Common",
      "order": 0,
      "ratio": 1,
      "nameReference": {
        "link": "https://localhost/mgmt/tm/gtm/pool/a/~Common~juice.gslb.maniak.lab?ver=17.5.0"
      }
    }
  ]
}
```

### GTM Pool Member Response
```json
{
  "kind": "tm:gtm:pool:a:members:membersstate",
  "name": "juiceshop_vs",
  "partition": "Common",
  "subPath": "bigip:/Common",
  "fullPath": "/Common/bigip:/Common/juiceshop_vs",
  "generation": 1733,
  "selfLink": "https://localhost/mgmt/tm/gtm/pool/a/~Common~juice.gslb.maniak.lab/members/~Common~bigip:~Common~juiceshop_vs?ver=17.5.0",
  "enabled": true,
  "limitMaxBps": 0,
  "limitMaxBpsStatus": "disabled",
  "limitMaxConnections": 0,
  "limitMaxConnectionsStatus": "disabled",
  "limitMaxPps": 0,
  "limitMaxPpsStatus": "disabled",
  "memberOrder": 0,
  "monitor": "default",
  "ratio": 1
}
```

### LTM Pool Member Response
```json
{
  "kind": "tm:ltm:pool:members:membersstate",
  "name": "172.100.100.11:1521",
  "partition": "Common",
  "fullPath": "/Common/172.100.100.11:1521",
  "generation": 14443,
  "selfLink": "https://localhost/mgmt/tm/ltm/pool/~Common~juiceshop_pool/members/~Common~172.100.100.11:1521?ver=17.5.0",
  "address": "172.100.100.11",
  "connectionLimit": 0,
  "dynamicRatio": 1,
  "ephemeral": "false",
  "fqdn": {
    "autopopulate": "disabled"
  },
  "inheritProfile": "enabled",
  "logging": "disabled",
  "monitor": "default",
  "priorityGroup": 0,
  "rateLimit": "disabled",
  "ratio": 1,
  "session": "monitor-enabled",
  "state": "up"
}
```

## ? Best Practices

### 1. Error Handling

```bash
# Check HTTP status codes
curl -k -u $F5_USER:$F5_PASS -X GET https://$F5_HOST/mgmt/tm/gtm/wideip/a -w "HTTP Status: %{http_code}\n"

# Handle errors gracefully
response=$(curl -k -u $F5_USER:$F5_PASS -X GET https://$F5_HOST/mgmt/tm/gtm/wideip/a -w "%{http_code}" -s)
if [[ "${response: -3}" == "200" ]]; then
  echo "Success: ${response%???}"
else
  echo "Error: HTTP ${response: -3}"
fi
```

### 2. Rate Limiting

```bash
# Add delays between requests
sleep 1
curl -k -u $F5_USER:$F5_PASS -X GET https://$F5_HOST/mgmt/tm/gtm/wideip/a
```

### 3. Secure Credential Handling

```bash
# Use environment variables
export F5_HOST="172.16.10.10"
export F5_USER="admin"
export F5_PASS="W3lcome098!"

# Use .netrc file
echo "machine $F5_HOST login $F5_USER password $F5_PASS" > ~/.netrc
chmod 600 ~/.netrc
curl -k -n -X GET https://$F5_HOST/mgmt/tm/gtm/wideip/a
```

## ? Notes

- Always use `-k` flag for self-signed certificates
- F5 REST API is case-sensitive
- URL encoding is required for special characters in names
- Some endpoints require specific Content-Type headers
- Use `~Common~` prefix for Common partition objects
- API responses include generation numbers for change tracking

## ? Related Documentation

- [F5 BIG-IP REST API Reference](https://clouddocs.f5.com/api/bigip-tm/)
- [GTM Configuration Guide](https://techdocs.f5.com/kb/en-us/products/big-ip-gtm/)
- [LTM Configuration Guide](https://techdocs.f5.com/kb/en-us/products/big-ip-ltm/)
