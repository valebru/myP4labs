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
    
    apply {
        if  (standard_metadata.ingress_port == 0) {
             standard_metadata.egress_spec = 1;
        }
        else if  (standard_metadata.ingress_port == 1) {
             standard_metadata.egress_spec = 0;
        }
        else {
           mark_to_drop(standard_metadata); 
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
