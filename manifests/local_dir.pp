# A description of what this class does
#
# @summary A short summary of the purpose of this class
#   Create LVM for LOCAL_DIR
#
#   Based on qserv::docker_cache
#
# @example
#   include htcondor::local_dir
# @param fs_type
#   String
#   File system type for local_dir (default = xfs; for lvm::logical_volume resource).
# @param mountpoint
#   String
#   Path where local_dir should mount.
# @param size
#   String
#   Size for LVM (format as required for lvm::logical_volume resource).
# @param vg_name
#   String
#   Name of LVM (e.g., VGsystem; format as required for lvm::logical_volume resource).
class htcondor::local_dir (

    String $fs_type,
    String $mountpoint, # does not currently influence HTCondor config; it'd be nice if it did
    String $size,
    String $vg_name

) {

    # May eventually need the ability to create a separate
    # Volume Group on separate disk. Perhaps add a flag that
    # says, create_vg TRUE/FALSE.

    include ::lvm

    lvm::logical_volume { 'LVcondor':
        ensure       => present,
        size         => $size,
        fs_type      => $fs_type,
        volume_group => $vg_name,
        mountpath    => $mountpoint,
    }

    # TO DO:
    ## Suggest replace declaration format of defaults (ie: "File { ... }"),
    ## with a hash variable, then use hash merging to pull in defaults, ie:
    ##   $base_defaults = { ... }
    ## then
    ##   $root_dir_defaults = $base_defaults + { overrides_here }
    ## Problem with declared syntax is local scope only,
    ## plus not sure ensure_resources() will pull in those declared 
    ## resource defaults (again, due to scoping of declarative syntax).

    # Resource file defaults
    File {
        ensure => 'directory',
        mode   => '0644',
    }
    $config_owner = lookup('htcondor::config::config_owner')
    $config_group = lookup('htcondor::config::config_group')
    $root_dir_defaults = {
        owner => $config_owner,
        group => $config_group,
    }
    $condor_dir_owner = lookup('htcondor::config::daemon_user')
    $condor_dir_group = lookup('htcondor::config::daemon_group')
    $condor_dir_defaults = {
        owner   => $condor_dir_owner,
        group   => $condor_dir_group,
        require => User['condor'], # if using LDAP IDs this is not really required...
    }

    $cluster_name = lookup('htcondor::config::cluster_name')

    # File declarations (there's gotta be a better way to do this...)
    ensure_resources( 'file', {
            "${mountpoint}/lib"  => {},
            "${mountpoint}/lock" => {},
            "${mountpoint}/log"  => {},
            "${mountpoint}/run"  => {}
        }, $root_dir_defaults )
    ensure_resources( 'file', {
            "${mountpoint}/lib/condor"         => {},
#            "${mountpoint}/lib/condor/execute" => { mode => '1777'},
#            "${mountpoint}/lib/condor/execute" => {},
            "${mountpoint}/lib/condor/spool"   => {},
        }, $condor_dir_defaults )
    ensure_resources( 'file', {"${mountpoint}/lock/condor" => { mode => '0775' }}, $condor_dir_defaults )
    ensure_resources( 'file', {"${mountpoint}/log/condor" => {}}, $condor_dir_defaults )
    ensure_resources( 'file', {"${mountpoint}/run/condor" => { mode => '0775' }}, $condor_dir_defaults )

    # And this is uglier...but need to see what all goes in GPFS, whether it varies by
    #     machine/cluster, and think a bit on how to specify.
    ## ASSUMES THAT THE PARENT DIRECTORIES ALREADY EXIST (MANUALLY CREATED) IN THE SHARED
    ##     FILESYSTEM
    ## FOR NOW I WILL CREATE NO DEPENDENCY; HTCONDOR WILL NOT BE STARTED BY PUPPET SO IF
    ##     THERE IS A FAILURE TO CREATE THE EXECUTE DIRECTORY (BECAUSE GPFS IS NOT MOUNTED)
    ##     THAT IS OK; IF A DEPENDENCY IS NEEDED LATER WE MIGHT BE ABLE TO DO SOMETHING IN
    ##     A PROFILE LIKE:
    ##         Class['::gpfs::bindmounts'] -> Class['::htcondor::local_dir']
    ensure_resources( 'file', {"/scratch/${cluster_name}/lib/condor/execute/${hostname}" => {}}, $condor_dir_defaults )
}
