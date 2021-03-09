# @summary Code that applies to HTCondor Central Manager nodes only.
#
# Manages SSH client config for root so it can SSH to other nodes in the pool.
#
# @example
#   include htcondor::central_manager
#
# @param root_sshkey_hosts
#        String
#        E.g., "lsst-verify-worker* lsst-condordev-*"
#
# @param root_sshkey_name
#        String
#        E.g., id_ed25519_condorroot
#
# @param root_sshkey_priv
#        String
#        Contents of root private key.
#
class htcondor::central_manager (
    String $root_sshkey_hosts,
    String $root_sshkey_name,
    String $root_sshkey_priv,
) {

    # SET UP ROOT SSH KEY PAIR
    # Below borrowed from xcat::master::root
    # may be able to generalize into an ssh::configure_to class
    # see ssh::allow_from as an example

    # Local variables

    $root_sshkey_priv_sensitive = Sensitive( $root_sshkey_priv )
    $sshdir = '/root/.ssh'

    $file_defaults = {
        ensure  => file,
        owner   => root,
        group   => root,
        mode    => '0600',
        require =>  File[ $sshdir ],
    }

    # Define unique parameters of each resource
    $data = {
        $sshdir => {
            ensure => directory,
            mode   => '0700',
            require => [],
        },
        "${sshdir}/${root_sshkey_name}" => {
            content => $root_sshkey_priv_sensitive,
        },
    }

    # Ensure the resources
    ensure_resources( 'file', $data, $file_defaults )

    ssh_config { 'htcondor-central_manager-root_ssh_config':
        ensure => present,
        host   => $root_sshkey_hosts,
        key    => 'IdentityFile',
        target => '/root/.ssh/config',
        value  => "~/.ssh/${root_sshkey_name}",
    }

}
