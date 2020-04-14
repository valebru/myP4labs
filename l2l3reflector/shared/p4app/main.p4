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
    

    bit<48> tmp_swap;

    apply {
	
	tmp_swap = hdr.ethernet.dst_addr;
	hdr.ethernet.dst_addr = hdr.ethernet.src_addr;
	hdr.ethernet.src_addr = tmp_swap;
	standard_metadata.egress_spec = standard_metadata.ingress_port;

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
