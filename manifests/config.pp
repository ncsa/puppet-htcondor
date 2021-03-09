# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include htcondor::config
#
# @param cluster_name
#   String
#   Name of the cluster (e.g., for use in config file paths).
# @param config_owner
#   String
#   User account that should own the config files (defined in data-in-module for supported OS).
# @param config_group
#   String
#   Group that should own the config files (defined in data-in-module for supported OS).
# @param config_000_global
#   String
#   Raw config that should be applied to all nodes in the cluster.
# @param config_100_cluster
#   String
#   Raw config that should be applied to nodes based on their HTCondor cluster.
# @param config_200_role
#   String
#   Raw config that should be applied to nodes based on their HTCondor role (or unique for the node).
# @param config_kmap
#   String
#   Contents of HTCondor KERBEROS_MAP_FILE.
# @param condor_daemon_group
#   String
#   The group name or gid for the daemon that will run the condor processes.
#   Defaults to 'condor'. (May be replaced with a gid from LDAP, for example.)
# @param condor_daemon_user
#   String
#   The user name or uid for the daemon that will run the condor processes.
#   Defaults to 'condor'. (May be replaced with a uid from LDAP, for example.)
class htcondor::config (

    String $cluster_name,
    String $config_owner,
    String $config_group,
    ## kind of ugly for now: just takes two big blob configs from Hiera
    ## might want to templatize it later at the very least; but first need to assess direction
    String $config_000_global,
    String $config_100_cluster,
    String $config_200_role,
    String $config_kmap,
    String $daemon_group, # NOTE: this SHOULD be used here, e.g., injected into config template
    String $daemon_user, # NOTE: this SHOULD be used here, e.g., injected into config template

) {

    # Resource file defaults
    File {
        ensure => 'file',
        owner  => $config_owner,
        group  => $config_group,
        mode   => '0644',
    }

    file { '/etc/condor/config.d/000_global':
        content => $config_000_global,
    }
    file { '/etc/condor/config.d/100_cluster':
        content => $config_100_cluster,
    }
    file { '/etc/condor/config.d/200_role':
        content => $config_200_role,
    }
    file { '/etc/condor/condor.kmap':
        content => $config_kmap,
    }
}
