# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include htcondor::firewall
# @param allow_range
#   String
#   CIDR range from which HTCondor connections should be allowed.
class htcondor::firewall (

    String $allow_range,

) {

    # QUICK AND DIRTY FOR NOW

    firewall { '400 HTCondor allow TCP for shared port for NCSA Public-FW':
        action => accept,
        dport  => 9618,
        proto  => tcp,
        source => $allow_range,
    }

}
