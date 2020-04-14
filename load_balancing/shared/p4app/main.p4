#include <core.p4>
#include <v1model.p4>

#include "include/define.p4"
#include "include/parser.p4"
#include "include/header.p4"


control EgressPipeImpl (inout parsed_headers_t hdr,
                         inout local_metadata_t local_metadata,
                         inout standard_metadata_t standard_metadata) {

    action rewrite_mac(bit<48> smac) {
        hdr.ethernet.src_addr = smac;
    }
    action drop() {
        mark_to_drop(standard_metadata);
    }

    table correct_out_mac {
        key = {
            standard_metadata.egress_port: exact;
        }
        actions = {
            rewrite_mac;
            drop;
        }
        size = 256;
    }

    apply {
        correct_out_mac.apply();
    }

}

control ComputeChecksumImpl(inout parsed_headers_t hdr,
                            inout local_metadata_t meta)
{
    apply {
            update_checksum(true, {
                            hdr.ipv4.raw_ipv4_1, hdr.ipv4.ttl, hdr.ipv4.proto,
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
    
 
	action drop() {
		mark_to_drop(standard_metadata);
	}

    action set_ecmp_value(bit<16> ecmp_base, bit<32> ecmp_count) {
        /* TODO: hash on 5-tuple and save the hash result in meta.ecmp_select 
           so that the ecmp_nhop table can use it to make a forwarding decision accordingly */
	/* extern void hash<O, T, D, M>(out O result, in HashAlgorithm algo, in T base, in D data, in M max); */
        hash(local_metadata.ecmp_select,
	    HashAlgorithm.crc16,
	    ecmp_base,
	    { hdr.ipv4.src_addr,
	      hdr.ipv4.dst_addr,
              hdr.ipv4.proto,
              hdr.tcp.srcPort,
              hdr.tcp.dstPort },
	    ecmp_count);
    }

    action set_next_hop(bit<48> nhop_dmac, bit<32> nhop_ipv4, bit<9> port) {
        hdr.ethernet.dst_addr = nhop_dmac;
        hdr.ipv4.dst_addr = nhop_ipv4;
        standard_metadata.egress_spec = port;
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
    }

    table lb_init_table {
            key = {
                hdr.ipv4.dst_addr: lpm;
            }
            actions = {
	      set_ecmp_value;
              NoAction;
            }
	    size = 128;
          default_action = NoAction();
      }

    table lb_selection_table {
            key = {
                 local_metadata.ecmp_select: exact;
            }
            actions = {
	      set_next_hop;
              drop;
            }
	    size = 128;
          default_action = drop();
      }

    apply {
    	if (hdr.ipv4.isValid() && hdr.ipv4.ttl > 0) {
		if(lb_init_table.apply().hit) {
			lb_selection_table.apply();
		}
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
