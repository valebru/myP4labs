#include <core.p4>
#include <v1model.p4>

#include "include/header.p4"
#include "include/define.p4"
#include "include/parser.p4"


control EgressPipeImpl (inout parsed_headers_t hdr,
                         inout local_metadata_t local_metadata,
                         inout standard_metadata_t standard_metadata) {
    apply{}
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

	action drop() {
		mark_to_drop(standard_metadata);
	}

	action srcRoute_nhop() {
		standard_metadata.egress_spec = hdr.source_r[0].port;
		/* hdr.srcRoutes.pop_front(1); */
		hdr.source_r[0].setInvalid();
	}

	action srcRoute_finish() {
		hdr.ethernet.ethtype = ETHERTYPE_IPV4;
	}

	action update_ttl(){
		hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
	}

	apply {
		if (hdr.source_r[0].isValid()){
			if (hdr.source_r[0].bos == 1){
				srcRoute_finish();
			}

			srcRoute_nhop();	

			if (hdr.ipv4.isValid()){
				update_ttl();
			}
		}else{
			drop();
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
