# == Class: oae::preview_processor::common
# Common resources for the ruby and java preview processors.
# Not directly called. Used by the ruby and java classes.
#
# === Parameters
#
# [*user*]
#    A sakai OAE admin username
#
# [*password*]
#    The password for $user
#
# [*upload_url*]
#    Where to fetch and update content previews
#
# [*pp_mode*]
#    Which processor are we using? valid values are ruby and java
class oae::preview_processor::common (
    $user     = 'admin',
    $password = 'admin',
    $upload_url,
    $pp_mode){

    Class['oae::params'] -> Class['oae::preview_processor::common']
    
    class { 'oae::preview_processor::openoffice': }

    if !defined(File["${oae::params::basedir}/bin"]) {
        file { "${oae::params::basedir}/bin":
            ensure => directory,
            owner  => $oae::params::user,
            group  => $oae::params::group,
            mode   => 750,
        }
    }

    file { $oae::params::preview_log_dir:
        ensure  => directory,
        owner   => root,
        group   => $oae::params::group,
        mode    => 0775,
    }

    # OAE password file
    file { "${oae::params::basedir}/.oae_credentials.txt":
        owner => $oae::params::user,
        group => $oae::params::group,
        mode  => 0600,
        content => "${upload_url} ${password}",
    }

    # Script for the cron job
    file { "${oae::params::basedir}/bin/run_preview_processor.sh":
        content => template('oae/run_preview_processor.sh.erb'),
        owner  => root,
        group  => root,
        mode   => 755,
    }

    # Nagios check
    file { "${oae::params::basedir}/bin/check_preview_processor.sh":
        content => template('oae/check_preview_processor.sh.erb'),
        owner  => root,
        group  => root,
        mode   => 755,
    }
    
    cron { 'run_preview_processor':
        command => "${oae::params::basedir}/bin/run_preview_processor.sh 2>&1 > /dev/null",
        user => $oae::params::user,
        ensure => present,
        minute => '*',
        require => [
            File["${oae::params::basedir}/bin/run_preview_processor.sh"],
            File["${oae::params::basedir}/.oae_credentials.txt"],
        ],
    }
}
