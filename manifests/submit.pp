# @summary Code that applies to HTCondor Submit nodes only.
#
# Manage condor.acctmap (for user accounting/job authorization).
#
# @example
#   include htcondor::submit
#
# @param allowed_groups
#        Array[ String ]
#        LDAP groups that are allowed to submit to HTCondor (each one
#        is effectly an AccountingGroups).
# @param enable_cron
#        Boolean
#        True/false - enable acctmap sync or not.
# @param ldapsearch_cmd
#        String
#        Binary for ldapsearch command (defined by data-in-module for
#        support OS versions).
# @param ldapsearch_dnbase
#        String
#        E.g., 'dc=mycompany,dc=domain,dc=com'
# @param ldapsearch_field
#        String
#        Defaults to 'uniqueMember'
# @param ldapsearch_host
#        String
#        E.g., 'ldaps://ldap.mycompany.domain.com'
# @param ldapsearch_opts
#        String
#        Defaults to '-xLLL'
# @param ldapsearch_query
#        String
#        Defaults to '(&(objectclass=groupOfUniqueNames)(cn=$1))' where
#        $1 is a group specified during script execution.
# @param required_pkgs
#        List of required pkgs. Defaults provided by the module 
#        should be sufficient for supported OS versions.

class htcondor::submit (
    Array[ String, 1 ] $allowed_groups,
    Boolean            $enable_cron,
    String[1]          $ldapsearch_cmd,
    String[1]          $ldapsearch_dnbase,
    String[1]          $ldapsearch_field,
    String[1]          $ldapsearch_host,
    String[1]          $ldapsearch_opts,
    String[1]          $ldapsearch_query,
    Array[ String, 1]  $required_pkgs,
) {

    ### MANAGE condor.acctmap.groups.src FILE TO CONTROL WHO CAN SUBMIT JOBS
    # NOTE: this is just a quick first pass for our rather small-scale
    # setup; managing this file in a more scaled environment with
    # thousands of users (and possibly thousands of accounting groups)
    # should probably be very different; among other things, it makes
    # no attempt to control which AccountingGroup is listed first
    # (is default) for a user (it simply sorts to make sure output
    # is consistent and that condor is not reconfigured unnecessarily)

    # Resource defaults
    File {
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
        ensure => 'file',
    }

    Cron {
        ensure   => absent,
        user     => root,
        minute   => [4, 19, 34, 49],
        hour     => '*',
        month    => '*',
        monthday => '*',
        weekday  => '*',
    }

    # Packages
    ensure_packages( $required_pkgs )

    # acctmap group input file
    file { '/etc/condor/condor.acctmap.groups.src' :
        content => join($allowed_groups, "\n"),
    }

    # Script
    $template_data = {
        'ldapsearch_cmd'    => $ldapsearch_cmd,
        'ldapsearch_opts'   => $ldapsearch_opts,
        'ldapsearch_host'   => $ldapsearch_host,
        'ldapsearch_dnbase' => $ldapsearch_dnbase,
        'ldapsearch_query'  => $ldapsearch_query,
        'ldapsearch_field'  => $ldapsearch_field,
    }

    $acctmap_script = '/etc/condor/condor.acctmap.sh'
    file { $acctmap_script:
        content => epp( 'htcondor/condor.acctmap.sh.epp', $template_data ),
        mode    => '0744',
    }

    # Cron
    if $enable_cron {
        $cron_ensure = 'present'
    }
    else {
        $cron_ensure = 'absent'
    }

    cron { "${acctmap_script}_cron":
        ensure  => $cron_ensure,
        command => $acctmap_script,
        require => [
            File[$acctmap_script],
        ],
    }

}
