#include <core.p4>
#include <v1model.p4>

#include "include/define.p4"
#include "include/parser.p4"
#include "include/header.p4"


control EgressPipeImpl (inout parsed_headers_t hdr,
                         inout local_metadata_t local_metadata,
                         inout standard_metadata_t standard_metadata) {
    apply{
        if (local_metadata.is_multicast == true
             && standard_metadata.ingress_port == standard_metadata.egress_port) {
		mark_to_drop(standard_metadata);
        }
    }
}

control ComputeChecksumImpl(inout parsed_headers_t hdr,
                            inout local_metadata_t meta)
{
    apply {
            update_checksum(true, {
                            hdr.ipv4.raw_ipv4_1, hdr.ipv4.ttl, hdr.ipv4.protocol,
                            hdr.ipv4.src_addr, hdr.ipv4.dst_addr
                            }, hdr.ipv4.hdr_checksum, HashAlgorithm.csum16);
    }
}

control VerifyChecksumImpl(inout parsed_headers_t hdr,
                           inout local_metadata_t meta)
{
    apply {}
}

control IngressPipeImpl (inout parsed_headers_t hdr,
                        inout local_metadata_t local_metadata,
                        inout standard_metadata_t standard_metadata) {
    
 
    action set_output_port(port_num_t port_num) {
        standard_metadata.egress_spec = port_num;
    }

    action set_next_hop(mac_addr_t next_hop, bit<1> ttl_w) {
	hdr.ethernet.src_addr = hdr.ethernet.dst_addr;
	hdr.ethernet.dst_addr = next_hop;
	if ( ttl_w == 1) {
		hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
	}
    }

    action set_local_broadcast() {
        local_metadata.is_multicast = true;
        standard_metadata.mcast_grp = 0x1;
    }

    table l2_unicast_table {
            key = {
                hdr.ethernet.dst_addr: exact;
            }
            actions = {
              set_output_port;
              NoAction;
            }
	    size = 1024;
          default_action = NoAction();
      }

    table my_mac_addresses_table {
            key = {
                hdr.ethernet.dst_addr: exact;
            }
            actions = {
              NoAction;
            }
	    size = 128;
          default_action = NoAction();
      }

    table l3_forwarding_table {
            key = {
                hdr.ipv4.dst_addr: lpm;
            }
            actions = {
	      set_next_hop;
              NoAction;
            }
	    size = 1024;
          default_action = NoAction();
      }

    table arp_cache_table {
            key = {
                hdr.ipv4.dst_addr: exact;
            }
            actions = {
	      set_next_hop;
              NoAction;
            }
	    size = 1024;
          default_action = NoAction();
      }

    apply {
	if ( my_mac_addresses_table.apply().hit ) {
		l3_forwarding_table.apply();
		arp_cache_table.apply();
	}


        if  (!l2_unicast_table.apply().hit) {
            set_local_broadcast();
        }
    }
}

V1Switch(
    ParserImpl(),
    VerifyChecksumImpl(),
    IngressPipeImpl(),
    EgressPipeImpl(),
    ComputeChecksumImpl(),
    DeparserImpl()

) main;
