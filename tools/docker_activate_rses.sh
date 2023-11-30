#!/bin/bash

# -*- coding: utf-8 -*-
# Author: Syed Hasan (minor modications to this code from CERN)
# Copyright European Organization for Nuclear Research (CERN) since 2012
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

echo "Creating RSEs"

# Create the following topology:
# +------+   1   +------+
# |      |<----->|      |
# | XRD1 |       | XRD2 |
# |      |   +-->|      |
# +------+   |   +------+
#    ^       |
#    | 1     | 1
#    v       |
# +------+   |   +------+
# |      |<--+   |      |
# | XRD3 |       | XRD4 |
# |      |<----->|      |
# +------+   2   +------+

# Step zero, get a compliant proxy. The key must NOT be group/other readable
(KEY=$(mktemp); cat /opt/rucio/etc/userkey.pem > "$KEY"; xrdgsiproxy init -valid 9999:00 -cert /opt/rucio/etc/usercert.pem -key "$KEY"; rm -f "$KEY")

#rucio-admin account add rucio_user
#rucio-admin account add-identity --account rucio_user --type USERPASS --username syed --password amai$499012

# First, create the RSEs
rucio-admin rse add XRD1
rucio-admin rse add XRD2
rucio-admin rse add XRD3
rucio-admin rse add XRD4
rucio-admin rse add SSH1

# Add the protocol definitions for the storage servers
rucio-admin rse add-protocol --hostname xrd1 --scheme root --prefix //rucio --port 1094 --impl rucio.rse.protocols.xrootd.Default --domain-json '{"wan": {"read": 1, "write": 1, "delete": 1, "third_party_copy_read": 1, "third_party_copy_write": 1}, "lan": {"read": 1, "write": 1, "delete": 1}}' XRD1
rucio-admin rse add-protocol --hostname xrd2 --scheme root --prefix //rucio --port 1095 --impl rucio.rse.protocols.xrootd.Default --domain-json '{"wan": {"read": 1, "write": 1, "delete": 1, "third_party_copy_read": 1, "third_party_copy_write": 1}, "lan": {"read": 1, "write": 1, "delete": 1}}' XRD2
rucio-admin rse add-protocol --hostname xrd3 --scheme root --prefix //rucio --port 1096 --impl rucio.rse.protocols.xrootd.Default --domain-json '{"wan": {"read": 1, "write": 1, "delete": 1, "third_party_copy_read": 1, "third_party_copy_write": 1}, "lan": {"read": 1, "write": 1, "delete": 1}}' XRD3
rucio-admin rse add-protocol --hostname xrd4 --scheme root --prefix //rucio --port 1097 --impl rucio.rse.protocols.xrootd.Default --domain-json '{"wan": {"read": 1, "write": 1, "delete": 1, "third_party_copy_read": 1, "third_party_copy_write": 1}, "lan": {"read": 1, "write": 1, "delete": 1}}' XRD4
rucio-admin rse add-protocol --hostname ssh1 --scheme scp --prefix /rucio --port 22 --impl rucio.rse.protocols.ssh.Default --domain-json '{"wan": {"read": 1, "write": 1, "delete": 1, "third_party_copy_read": 1, "third_party_copy_write": 1}, "lan": {"read": 1, "write": 1, "delete": 1}}' SSH1
rucio-admin rse add-protocol --hostname ssh1 --scheme rsync --prefix /rucio --port 22 --impl rucio.rse.protocols.ssh.Rsync --domain-json '{"wan": {"read": 2, "write": 2, "delete": 2, "third_party_copy_read": 2, "third_party_copy_write": 2}, "lan": {"read": 2, "write": 2, "delete": 2}}' SSH1
rucio-admin rse add-protocol --hostname ssh1 --scheme rclone --prefix /rucio --port 22 --impl rucio.rse.protocols.rclone.Default --domain-json '{"wan": {"read": 3, "write": 3, "delete": 3, "third_party_copy_read": 3, "third_party_copy_write": 3}, "lan": {"read": 3, "write": 3, "delete": 3}}' SSH1

# Set test_container_xrd attribute for xrd containers
rucio-admin rse set-attribute --rse XRD1 --key test_container_xrd --value True
rucio-admin rse set-attribute --rse XRD2 --key test_container_xrd --value True
rucio-admin rse set-attribute --rse XRD3 --key test_container_xrd --value True
rucio-admin rse set-attribute --rse XRD4 --key test_container_xrd --value True
rucio-admin rse set-attribute --rse SSH1 --key test_container_ssh --value True

# Workaround, xrootd.py#connect returns with Auth Failed due to execution of the command in subprocess
XrdSecPROTOCOL=gsi XRD_REQUESTTIMEOUT=10 XrdSecGSISRVNAMES=xrd1 xrdfs xrd1:1094 query config xrd1:1094
XrdSecPROTOCOL=gsi XRD_REQUESTTIMEOUT=10 XrdSecGSISRVNAMES=xrd2 xrdfs xrd2:1095 query config xrd2:1095
XrdSecPROTOCOL=gsi XRD_REQUESTTIMEOUT=10 XrdSecGSISRVNAMES=xrd3 xrdfs xrd3:1096 query config xrd3:1096
XrdSecPROTOCOL=gsi XRD_REQUESTTIMEOUT=10 XrdSecGSISRVNAMES=xrd4 xrdfs xrd4:1097 query config xrd4:1097

# Enable FTS
rucio-admin rse set-attribute --rse XRD1 --key fts --value https://fts:8446
rucio-admin rse set-attribute --rse XRD2 --key fts --value https://fts:8446
rucio-admin rse set-attribute --rse XRD3 --key fts --value https://fts:8446
rucio-admin rse set-attribute --rse XRD4 --key fts --value https://fts:8446
rucio-admin rse set-attribute --rse SSH1 --key fts --value https://fts:8446

# Enable multihop transfers via XRD3
rucio-admin rse set-attribute --rse XRD3 --key available_for_multihop --value True

# Connect the RSEs
rucio-admin rse add-distance --distance 1 --ranking 1 XRD1 XRD2
rucio-admin rse add-distance --distance 1 --ranking 1 XRD1 XRD3
rucio-admin rse add-distance --distance 1 --ranking 1 XRD2 XRD1
rucio-admin rse add-distance --distance 2 --ranking 2 XRD2 XRD3
rucio-admin rse add-distance --distance 1 --ranking 1 XRD3 XRD1
rucio-admin rse add-distance --distance 2 --ranking 2 XRD3 XRD2
rucio-admin rse add-distance --distance 3 --ranking 3 XRD3 XRD4
rucio-admin rse add-distance --distance 3 --ranking 3 XRD4 XRD3

# Indefinite limits for root
rucio-admin account set-limits root XRD1 -1
rucio-admin account set-limits root XRD2 -1
rucio-admin account set-limits root XRD3 -1
rucio-admin account set-limits root XRD4 -1
rucio-admin account set-limits root SSH1 -1

# Create a default scope for testing
rucio-admin scope add --account root --scope test

# Create initial transfer testing data
dd if=/dev/urandom of=/home/rucio_user/swiss-prototypes/data/file1 bs=10M count=1
dd if=/dev/urandom of=/home/rucio_user/swiss-prototypes/data/file2 bs=10M count=1
dd if=/dev/urandom of=/home/rucio_user/swiss-prototypes/data/file3 bs=10M count=1
dd if=/dev/urandom of=/home/rucio_user/swiss-prototypes/data/file4 bs=10M count=1

#XrdSecGSISRVNAMES=xrd1 
rucio upload --rse XRD1 --scope test /home/rucio_user/swiss-prototypes/data/file1
#XrdSecGSISRVNAMES=xrd1 
rucio upload --rse XRD1 --scope test /home/rucio_user/swiss-prototypes/data/file2
#XrdSecGSISRVNAMES=xrd2 
rucio upload --rse XRD2 --scope test /home/rucio_user/swiss-prototypes/data/file3
#XrdSecGSISRVNAMES=xrd2 
rucio upload --rse XRD2 --scope test /home/rucio_user/swiss-prototypes/data/file4

# FTS Check
fts-rest-whoami -v -s https://fts:8446

# Delegate credentials to FTS
fts-rest-delegate -vf -s https://fts:8446 -H 9999

rucio add-dataset test:dataset1
rucio attach test:dataset1 test:file1 test:file2 test:file3

rule_id1=$(rucio add-rule test:dataset1 1 XRD3)


# Check if the command was successful and the variable is not empty
if [[ $? -eq 0 && -n "$rule_id1" ]]; then
    echo "Rule ID: $rule_id1"

else
    echo "Failed to create rule or capture rule ID"
fi


rucio rule-info $rule_id1

#running conveyor commands for replication to happen
rucio-conveyor-submitter --run-once
rucio-conveyor-poller --run-once --older-than 0
rucio-conveyor-finisher --run-once

rucio rule-info $rule_id1

# FTS Check
fts-rest-whoami -v -s https://fts:8446

# Delegate credentials to FTS
fts-rest-delegate -vf -s https://fts:8446 -H 9999
