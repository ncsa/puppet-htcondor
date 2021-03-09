# A description of what this class does
#
# @summary Manage a local condor user and group.
#     The condor rpm installs a local condor user/group if
#     'getent passwd/group condor' returns nothing. It is
#     desirable to manage this user/group even if using
#     a uid/gid pair from LDAP (see the config class).
#
# @example
#   include htcondor::user
#
# @param condor_group_gid
#   Integer
#   GID for the condor group.
# @param condor_group_name
#   String
#   Name of the condor group.
# @param condor_user_gid
#   Integer
#   GID for the condor user.
# @param condor_user_home
#   String
#   Home directory path for the condor user.
# @param condor_user_name
#   String
#   Name of the condor user.
# @param condor_user_uid
#   Integer
#   UID for the condor user.
class htcondor::user (

    Integer $condor_group_gid,
    String $condor_group_name,
    Integer $condor_user_gid,
    String $condor_user_home,
    String $condor_user_name,
    Integer $condor_user_uid,

) {

    # Create group
    group { $condor_group_name:
        ensure => 'present',
        gid    => $condor_group_gid,
    }

    # Create user
    user { $condor_user_name:
        ensure         => 'present',
        uid            => $condor_user_uid,
        gid            => $condor_user_gid,
        forcelocal     => true,
        home           => $condor_user_home,
        managehome     => true,
        password       => '!!',
        purge_ssh_keys => true,
        shell          => '/sbin/nologin',
        comment        => 'Owner of HTCondor Daemons',
    }

}
