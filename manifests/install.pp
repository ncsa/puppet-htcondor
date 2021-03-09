# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include htcondor::install
# @param yum_repos
#   Hash
#   One or more yum repo definitions in form key=reponame, values=raw yumrepo config.
#   E.g.:
#     name: (String)
#       descr: (String; corresponds to 'name' key in the .repo file)
#       baseurl: (String)
#       enabled: (Integer 0 or 1)
#       gpgcheck: (Integer 0 or 1)
#       gpgkey: (String)
class htcondor::install (

    Hash[String, Hash] $yum_repos,
    String $condor_package_name,

) {

    # Configure Yum repo
    $yum_repos_defaults = {
        ensure => 'present',
        before => Package[$condor_package_name],
    }

    ensure_resources( 'yumrepo', $yum_repos, $yum_repos_defaults )

    # should re-try using ensure_packages; Jake thinks he tried to get the
    # dependency between yumrepo and package to work but it didn't work when the RPM
    # was wrapped in ensure_resources? but it might be worth investigating again
    package { $condor_package_name:
        ensure => 'present',
    }

}
