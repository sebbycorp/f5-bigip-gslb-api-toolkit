#!/bin/bash

# F5 BIG-IP GSLB Configuration Collection Script
# Collects complete GSLB configuration from F5 BIG-IP devices
# Author: Sebastian Maniak (@sebbycorp)
# Version: 1.0

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default configuration
DEFAULT_F5_HOST="172.16.10.10"
DEFAULT_F5_USER="admin"
DEFAULT_OUTPUT_DIR="./f5-config-export"

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    cat << EOF
F5 BIG-IP GSLB Configuration Collection Script

Usage: $0 [OPTIONS]

OPTIONS:
    -h, --help              Show this help message
    -H, --host HOST         F5 BIG-IP hostname or IP address (default: $DEFAULT_F5_HOST)
    -u, --user USER         F5 username (default: $DEFAULT_F5_USER)
    -p, --password PASS     F5 password (will prompt if not provided)
    -o, --output DIR        Output directory (default: $DEFAULT_OUTPUT_DIR)
    -w, --wideip WIDEIP     Specific Wide IP to analyze
    -f, --format FORMAT     Output format: json, yaml, or both (default: json)
    -v, --verbose           Enable verbose output
    -s, --stats             Include statistics and health status
    -t, --timeout SECONDS   Connection timeout (default: 30)
    --no-verify-ssl         Skip SSL certificate verification (default)
    --verify-ssl            Verify SSL certificates

EXAMPLES:
    # Basic collection with prompts
    $0

    # Collect specific Wide IP
    $0 -H 192.168.1.100 -u admin -w example.gslb.com

    # Collect with statistics and verbose output
    $0 -H 192.168.1.100 -u admin -p mypassword -s -v

    # Export to custom directory with YAML format
    $0 -o /tmp/f5-backup -f yaml

EOF
}

# Function to validate F5 connectivity
validate_connectivity() {
    local host=$1
    local user=$2
    local pass=$3
    local verify_ssl=$4
    
    local ssl_opt="-k"
    if [[ "$verify_ssl" == "true" ]]; then
        ssl_opt=""
    fi
    
    print_info "Testing connectivity to F5 device: $host"
    
    local response=$(curl $ssl_opt -u "$user:$pass" -X GET "https://$host/mgmt/tm/sys/version" \
        --connect-timeout $TIMEOUT \
        --silent \
        --write-out "HTTPSTATUS:%{http_code}")
    
    local http_code=$(echo "$response" | grep -o "HTTPSTATUS:[0-9]*" | cut -d: -f2)
    
    if [[ "$http_code" == "200" ]]; then
        print_success "Successfully connected to F5 device"
        return 0
    else
        print_error "Failed to connect to F5 device (HTTP: $http_code)"
        return 1
    fi
}

# Function to make API call
make_api_call() {
    local endpoint=$1
    local output_file=$2
    local description=$3
    
    local ssl_opt="-k"
    if [[ "$VERIFY_SSL" == "true" ]]; then
        ssl_opt=""
    fi
    
    if [[ "$VERBOSE" == "true" ]]; then
        print_info "Calling API: $endpoint"
        print_info "Output file: $output_file"
    fi
    
    local response=$(curl $ssl_opt -u "$F5_USER:$F5_PASS" -X GET "https://$F5_HOST$endpoint" \
        --connect-timeout $TIMEOUT \
        --silent \
        --write-out "HTTPSTATUS:%{http_code}")
    
    local http_code=$(echo "$response" | grep -o "HTTPSTATUS:[0-9]*" | cut -d: -f2)
    local body=$(echo "$response" | sed 's/HTTPSTATUS:[0-9]*$//')
    
    if [[ "$http_code" == "200" ]]; then
        echo "$body" | jq '.' > "$output_file" 2>/dev/null
        if [[ $? -eq 0 ]]; then
            print_success "$description collected successfully"
            return 0
        else
            print_warning "$description collected but JSON formatting failed"
            echo "$body" > "$output_file"
            return 0
        fi
    else
        print_error "$description failed (HTTP: $http_code)"
        echo "{\"error\": \"HTTP $http_code\", \"endpoint\": \"$endpoint\"}" > "$output_file"
        return 1
    fi
}

# Function to collect system information
collect_system_info() {
    print_info "Collecting system information..."
    
    make_api_call "/mgmt/tm/sys/version" "$OUTPUT_DIR/system-version.json" "System version"
    make_api_call "/mgmt/tm/sys/global-settings" "$OUTPUT_DIR/system-global-settings.json" "Global settings"
    make_api_call "/mgmt/tm/sys/provision" "$OUTPUT_DIR/system-provision.json" "Module provisioning"
    
    if [[ "$INCLUDE_STATS" == "true" ]]; then
        make_api_call "/mgmt/tm/sys/performance" "$OUTPUT_DIR/system-performance.json" "System performance"
        make_api_call "/mgmt/tm/sys/cpu/stats" "$OUTPUT_DIR/system-cpu-stats.json" "CPU statistics"
        make_api_call "/mgmt/tm/sys/memory/stats" "$OUTPUT_DIR/system-memory-stats.json" "Memory statistics"
    fi
}

# Function to collect GTM configuration
collect_gtm_config() {
    print_info "Collecting GTM configuration..."
    
    # Wide IPs
    make_api_call "/mgmt/tm/gtm/wideip" "$OUTPUT_DIR/gtm-wideip-types.json" "Wide IP types"
    make_api_call "/mgmt/tm/gtm/wideip/a" "$OUTPUT_DIR/gtm-wideip-a.json" "A record Wide IPs"
    make_api_call "/mgmt/tm/gtm/wideip/aaaa" "$OUTPUT_DIR/gtm-wideip-aaaa.json" "AAAA record Wide IPs"
    make_api_call "/mgmt/tm/gtm/wideip/cname" "$OUTPUT_DIR/gtm-wideip-cname.json" "CNAME record Wide IPs"
    
    # GTM Pools
    make_api_call "/mgmt/tm/gtm/pool/a" "$OUTPUT_DIR/gtm-pool-a.json" "A record GTM pools"
    make_api_call "/mgmt/tm/gtm/pool/aaaa" "$OUTPUT_DIR/gtm-pool-aaaa.json" "AAAA record GTM pools"
    
    # GTM Servers
    make_api_call "/mgmt/tm/gtm/server" "$OUTPUT_DIR/gtm-servers.json" "GTM servers"
    make_api_call "/mgmt/tm/gtm/datacenter" "$OUTPUT_DIR/gtm-datacenters.json" "GTM datacenters"
    
    # GTM Global Settings
    make_api_call "/mgmt/tm/gtm/global-settings" "$OUTPUT_DIR/gtm-global-settings.json" "GTM global settings"
    make_api_call "/mgmt/tm/gtm/listener" "$OUTPUT_DIR/gtm-listeners.json" "GTM listeners"
}

# Function to collect LTM configuration
collect_ltm_config() {
    print_info "Collecting LTM configuration..."
    
    # Virtual Servers
    make_api_call "/mgmt/tm/ltm/virtual" "$OUTPUT_DIR/ltm-virtual-servers.json" "LTM virtual servers"
    
    # Pools
    make_api_call "/mgmt/tm/ltm/pool" "$OUTPUT_DIR/ltm-pools.json" "LTM pools"
    
    # Nodes
    make_api_call "/mgmt/tm/ltm/node" "$OUTPUT_DIR/ltm-nodes.json" "LTM nodes"
    
    # Monitors
    make_api_call "/mgmt/tm/ltm/monitor" "$OUTPUT_DIR/ltm-monitor-types.json" "Monitor types"
    make_api_call "/mgmt/tm/ltm/monitor/http" "$OUTPUT_DIR/ltm-monitor-http.json" "HTTP monitors"
    make_api_call "/mgmt/tm/ltm/monitor/https" "$OUTPUT_DIR/ltm-monitor-https.json" "HTTPS monitors"
    make_api_call "/mgmt/tm/ltm/monitor/tcp" "$OUTPUT_DIR/ltm-monitor-tcp.json" "TCP monitors"
    
    # Profiles
    make_api_call "/mgmt/tm/ltm/profile" "$OUTPUT_DIR/ltm-profile-types.json" "Profile types"
    
    # SSL
    make_api_call "/mgmt/tm/ltm/profile/client-ssl" "$OUTPUT_DIR/ltm-profile-client-ssl.json" "Client SSL profiles"
    make_api_call "/mgmt/tm/ltm/profile/server-ssl" "$OUTPUT_DIR/ltm-profile-server-ssl.json" "Server SSL profiles"
}

# Function to analyze specific Wide IP
analyze_wideip() {
    local wideip=$1
    print_info "Analyzing specific Wide IP: $wideip"
    
    # Encode the Wide IP name for URL
    local encoded_wideip=$(echo "$wideip" | sed 's/\./%2E/g')
    
    # Get Wide IP details
    make_api_call "/mgmt/tm/gtm/wideip/a/~Common~$encoded_wideip" "$OUTPUT_DIR/wideip-${wideip}-details.json" "Wide IP details"
    
    # Get associated pool details
    local pool_name=$(cat "$OUTPUT_DIR/wideip-${wideip}-details.json" 2>/dev/null | jq -r '.pools[0].name // empty')
    if [[ -n "$pool_name" && "$pool_name" != "null" ]]; then
        local encoded_pool=$(echo "$pool_name" | sed 's/\./%2E/g')
        make_api_call "/mgmt/tm/gtm/pool/a/~Common~$encoded_pool" "$OUTPUT_DIR/wideip-${wideip}-pool.json" "Associated GTM pool"
        make_api_call "/mgmt/tm/gtm/pool/a/~Common~$encoded_pool/members" "$OUTPUT_DIR/wideip-${wideip}-pool-members.json" "GTM pool members"
        
        if [[ "$INCLUDE_STATS" == "true" ]]; then
            make_api_call "/mgmt/tm/gtm/pool/a/~Common~$encoded_pool/stats" "$OUTPUT_DIR/wideip-${wideip}-pool-stats.json" "GTM pool statistics"
            make_api_call "/mgmt/tm/gtm/wideip/a/~Common~$encoded_wideip/stats" "$OUTPUT_DIR/wideip-${wideip}-stats.json" "Wide IP statistics"
        fi
    fi
}

# Function to collect detailed member information
collect_detailed_members() {
    print_info "Collecting detailed member information..."
    
    # Create subdirectory for detailed member info
    mkdir -p "$OUTPUT_DIR/detailed-members"
    
    # Get all pool members from LTM pools
    local pools_file="$OUTPUT_DIR/ltm-pools.json"
    if [[ -f "$pools_file" ]]; then
        local pool_names=$(cat "$pools_file" | jq -r '.items[]?.fullPath // empty' 2>/dev/null)
        
        while IFS= read -r pool_path; do
            if [[ -n "$pool_path" && "$pool_path" != "null" ]]; then
                local encoded_pool=$(echo "$pool_path" | sed 's|/|~|g' | sed 's/\./%2E/g')
                local pool_name=$(basename "$pool_path")
                
                make_api_call "/mgmt/tm/ltm/pool/$encoded_pool/members" "$OUTPUT_DIR/detailed-members/${pool_name}-members.json" "Pool members for $pool_name"
                
                if [[ "$INCLUDE_STATS" == "true" ]]; then
                    make_api_call "/mgmt/tm/ltm/pool/$encoded_pool/members/stats" "$OUTPUT_DIR/detailed-members/${pool_name}-members-stats.json" "Pool member statistics for $pool_name"
                fi
            fi
        done <<< "$pool_names"
    fi
}

# Function to generate summary report
generate_summary() {
    print_info "Generating configuration summary..."
    
    local summary_file="$OUTPUT_DIR/configuration-summary.json"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    cat > "$summary_file" << EOF
{
  "collectionSummary": {
    "timestamp": "$timestamp",
    "f5Device": "$F5_HOST",
    "collectedBy": "$F5_USER",
    "outputDirectory": "$OUTPUT_DIR",
    "includeStats": $INCLUDE_STATS,
    "format": "$OUTPUT_FORMAT"
  },
  "componentCounts": {
EOF

    # Count components
    local wideip_count=0
    local gtm_pool_count=0
    local ltm_vs_count=0
    local ltm_pool_count=0
    local monitor_count=0
    
    # Count Wide IPs
    if [[ -f "$OUTPUT_DIR/gtm-wideip-a.json" ]]; then
        wideip_count=$(cat "$OUTPUT_DIR/gtm-wideip-a.json" | jq '.items | length' 2>/dev/null || echo 0)
    fi
    
    # Count GTM pools
    if [[ -f "$OUTPUT_DIR/gtm-pool-a.json" ]]; then
        gtm_pool_count=$(cat "$OUTPUT_DIR/gtm-pool-a.json" | jq '.items | length' 2>/dev/null || echo 0)
    fi
    
    # Count LTM virtual servers
    if [[ -f "$OUTPUT_DIR/ltm-virtual-servers.json" ]]; then
        ltm_vs_count=$(cat "$OUTPUT_DIR/ltm-virtual-servers.json" | jq '.items | length' 2>/dev/null || echo 0)
    fi
    
    # Count LTM pools
    if [[ -f "$OUTPUT_DIR/ltm-pools.json" ]]; then
        ltm_pool_count=$(cat "$OUTPUT_DIR/ltm-pools.json" | jq '.items | length' 2>/dev/null || echo 0)
    fi
    
    # Count HTTP monitors
    if [[ -f "$OUTPUT_DIR/ltm-monitor-http.json" ]]; then
        monitor_count=$(cat "$OUTPUT_DIR/ltm-monitor-http.json" | jq '.items | length' 2>/dev/null || echo 0)
    fi
    
    cat >> "$summary_file" << EOF
    "wideIPs": $wideip_count,
    "gtmPools": $gtm_pool_count,
    "ltmVirtualServers": $ltm_vs_count,
    "ltmPools": $ltm_pool_count,
    "httpMonitors": $monitor_count
  },
  "files": [
EOF

    # List all collected files
    local files=$(find "$OUTPUT_DIR" -name "*.json" -type f | sed "s|$OUTPUT_DIR/||" | sort)
    local file_list=""
    
    while IFS= read -r file; do
        if [[ -n "$file_list" ]]; then
            file_list+=",\n"
        fi
        file_list+="    \"$file\""
    done <<< "$files"
    
    echo -e "$file_list" >> "$summary_file"
    
    cat >> "$summary_file" << EOF
  ]
}
EOF

    print_success "Configuration summary generated: $summary_file"
}

# Function to convert JSON to YAML
convert_to_yaml() {
    if command -v yq >/dev/null 2>&1; then
        print_info "Converting JSON files to YAML..."
        
        find "$OUTPUT_DIR" -name "*.json" -type f | while read -r json_file; do
            local yaml_file="${json_file%.json}.yaml"
            yq eval -P "$json_file" > "$yaml_file"
            if [[ $? -eq 0 ]]; then
                if [[ "$VERBOSE" == "true" ]]; then
                    print_success "Converted: $(basename "$json_file") -> $(basename "$yaml_file")"
                fi
            else
                print_warning "Failed to convert: $(basename "$json_file")"
            fi
        done
        
        print_success "YAML conversion completed"
    else
        print_warning "yq not found - skipping YAML conversion"
        print_info "Install yq with: sudo apt-get install yq  # or brew install yq"
    fi
}

# Function to create archive
create_archive() {
    local archive_name="f5-config-$(date +%Y%m%d-%H%M%S).tar.gz"
    local archive_path="$OUTPUT_DIR/../$archive_name"
    
    print_info "Creating archive: $archive_name"
    
    tar -czf "$archive_path" -C "$(dirname "$OUTPUT_DIR")" "$(basename "$OUTPUT_DIR")"
    
    if [[ $? -eq 0 ]]; then
        print_success "Archive created: $archive_path"
        local size=$(du -h "$archive_path" | cut -f1)
        print_info "Archive size: $size"
    else
        print_error "Failed to create archive"
    fi
}

# Parse command line arguments
F5_HOST="$DEFAULT_F5_HOST"
F5_USER="$DEFAULT_F5_USER"
F5_PASS=""
OUTPUT_DIR="$DEFAULT_OUTPUT_DIR"
SPECIFIC_WIDEIP=""
OUTPUT_FORMAT="json"
VERBOSE="false"
INCLUDE_STATS="false"
TIMEOUT=30
VERIFY_SSL="false"

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -H|--host)
            F5_HOST="$2"
            shift 2
            ;;
        -u|--user)
            F5_USER="$2"
            shift 2
            ;;
        -p|--password)
            F5_PASS="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -w|--wideip)
            SPECIFIC_WIDEIP="$2"
            shift 2
            ;;
        -f|--format)
            OUTPUT_FORMAT="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE="true"
            shift
            ;;
        -s|--stats)
            INCLUDE_STATS="true"
            shift
            ;;
        -t|--timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        --verify-ssl)
            VERIFY_SSL="true"
            shift
            ;;
        --no-verify-ssl)
            VERIFY_SSL="false"
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate required tools
if ! command -v curl >/dev/null 2>&1; then
    print_error "curl is required but not installed"
    exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
    print_error "jq is required but not installed"
    print_info "Install with: sudo apt-get install jq  # or brew install jq"
    exit 1
fi

# Prompt for password if not provided
if [[ -z "$F5_PASS" ]]; then
    echo -n "Enter F5 password for user '$F5_USER': "
    read -s F5_PASS
    echo
fi

# Validate inputs
if [[ -z "$F5_HOST" || -z "$F5_USER" || -z "$F5_PASS" ]]; then
    print_error "Host, username, and password are required"
    exit 1
fi

# Validate output format
if [[ "$OUTPUT_FORMAT" != "json" && "$OUTPUT_FORMAT" != "yaml" && "$OUTPUT_FORMAT" != "both" ]]; then
    print_error "Invalid output format: $OUTPUT_FORMAT (must be json, yaml, or both)"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"
if [[ $? -ne 0 ]]; then
    print_error "Failed to create output directory: $OUTPUT_DIR"
    exit 1
fi

print_info "Starting F5 BIG-IP GSLB configuration collection"
print_info "Device: $F5_HOST"
print_info "User: $F5_USER"
print_info "Output: $OUTPUT_DIR"
print_info "Format: $OUTPUT_FORMAT"
if [[ "$INCLUDE_STATS" == "true" ]]; then
    print_info "Including statistics and health status"
fi
echo

# Validate connectivity
if ! validate_connectivity "$F5_HOST" "$F5_USER" "$F5_PASS" "$VERIFY_SSL"; then
    exit 1
fi

echo

# Collect configurations
collect_system_info
echo

collect_gtm_config
echo

collect_ltm_config
echo

collect_detailed_members
echo

# Analyze specific Wide IP if provided
if [[ -n "$SPECIFIC_WIDEIP" ]]; then
    analyze_wideip "$SPECIFIC_WIDEIP"
    echo
fi

# Generate summary
generate_summary
echo

# Convert to YAML if requested
if [[ "$OUTPUT_FORMAT" == "yaml" || "$OUTPUT_FORMAT" == "both" ]]; then
    convert_to_yaml
    echo
fi

# Remove JSON files if only YAML was requested
if [[ "$OUTPUT_FORMAT" == "yaml" ]]; then
    print_info "Removing JSON files (YAML only mode)"
    find "$OUTPUT_DIR" -name "*.json" -type f -delete
fi

# Create archive
create_archive
echo

print_success "F5 BIG-IP configuration collection completed!"
print_info "Results saved to: $OUTPUT_DIR"

# Show summary
if [[ -f "$OUTPUT_DIR/configuration-summary.json" ]]; then
    echo
    print_info "Configuration Summary:"
    cat "$OUTPUT_DIR/configuration-summary.json" | jq '.componentCounts' 2>/dev/null || cat "$OUTPUT_DIR/configuration-summary.json"
fi
