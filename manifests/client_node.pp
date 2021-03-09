# @summary Code that applies to nodes other than Central Managers.
#
# Allow SSH from Central Manager nodes.
#
# @param cm_ips
#   Type: Array[ String, 1 ]
#   Desc: list of IPs for Central Manager node(s)
#
# @param root_sshkey_public
#   Type: String
#   Desc: authorized public key for root
#
# @example
#   include htcondor::client_node
class htcondor::client_node (
    Array[ String, 1 ] $cm_ips,
    String             $root_sshkey_public,
) {

    # CONFIGURE SSH ACCESS FROM CENTRAL MANAGER(S)
    # below borrowed from xcat::client::ssh

    # Configure sshd_config and other required items
    $params = {
        'PubkeyAuthentication'  => 'yes',
        'PermitRootLogin'       => 'without-password',
        'AuthenticationMethods' => 'publickey',
        'Banner'                => 'none',
    }
    ::ssh::allow_from{ 'htcondor-client_node':
        hostlist              => $cm_ips,
        pam_access_users      => [root],
        sshd_cfg_match_params => $params,
    }

    # Authorize root's public key (from Central Manager node(s))
    $pubkey_parts = split( $root_sshkey_public, ' ' )
    $key_type = $pubkey_parts[0]
    $key_data = Sensitive( $pubkey_parts[1] )
    $key_name = $pubkey_parts[2]

    ssh_authorized_key { $key_name :
        ensure => present,
        user   => 'root',
        type   => $key_type,
        key    => $key_data,
    }

}
