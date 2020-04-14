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

#ifndef __PARSER__
#define __PARSER__

#include "define.p4"
#include "header.p4"

parser ParserImpl (packet_in packet,
                   out parsed_headers_t hdr,
                   inout local_metadata_t local_metadata,
                   inout standard_metadata_t standard_metadata)
{
    state start {
        transition parse_ethernet;
    }

    state parse_ethernet {
        packet.extract(hdr.ethernet);
	transition select(hdr.ethernet.ethtype) {
	    ETHERTYPE_SRCR: parsing_srcr;
            ETHERTYPE_IPV4: parsing_ipv4;
            default: accept;
	}
    }

    state parsing_srcr {
	packet.extract(hdr.source_r.next);
	transition select(hdr.source_r.last.bos) {
		0: parsing_srcr;
		1: parsing_ipv4;
		default: accept;
	}
    }

    state parsing_ipv4 {
        packet.extract(hdr.ipv4);
        transition accept;
    }

}


control DeparserImpl(packet_out packet, in parsed_headers_t hdr) {
    apply { 
        packet.emit(hdr.ethernet);
        packet.emit(hdr.source_r);
        packet.emit(hdr.ipv4);
    }
}

#endif
