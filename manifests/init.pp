# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include htcondor
class htcondor {

    # Sub-classes to include
    include ::htcondor::user
    include ::htcondor::install
    include ::htcondor::local_dir
    include ::htcondor::config
    include ::htcondor::firewall
    #include ::htcondor::service

    # should try to rework these such that the dependencies are specified at the resource
    # level instead of at the class level, if possible
    ## does config really need to happen after install?
    Class['::htcondor::user'] -> Class['::htcondor::install'] -> Class['::htcondor::config']
    Class['::htcondor::local_dir'] -> Class['::htcondor::config'] #-> Class['::htcondor::service']
    #Class[::htcondor::firewall'] -> Class['::htcondor::service']
}
