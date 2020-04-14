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
    apply { }
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

    action set_broadcast() {
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


    apply {
        if  (!l2_unicast_table.apply().hit) {
            set_broadcast();
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
