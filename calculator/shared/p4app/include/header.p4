/*
 * Copyright 2019-present Open Networking Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef __HEADER__
#define __HEADER__

#include "define.p4"

#define MAX_HOP 9
const bit<16> ETHERTYPE_SRCR = 0x1234;

header ethernet_t {
    mac_addr_t dst_addr;
    mac_addr_t src_addr;
    bit<16> ethtype;
}

header ipv4_t {
    bit<64> raw_ipv4_1;
    bit<8> ttl;
    bit<8> protocol;
    bit<16> hdr_checksum;
    bit<32> src_addr;
    bit<32> dst_addr;
}

header source_r_t {
    bit<1> bos;
    port_num_t port;
    bit<6> reserved;
}


//Custom metadata definition
struct local_metadata_t {
}

struct parsed_headers_t {
	ethernet_t   ethernet;
	source_r_t[MAX_HOP] source_r;
	ipv4_t       ipv4;
}

#endif
