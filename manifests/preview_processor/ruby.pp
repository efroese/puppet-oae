# = Class: oae::preview_processor
#
# Install the OAE preview processor
#
# == Parameters:
#
# [*user*]
#    An OAE admin username
#
# [*password*]
#    The OAE admin password
#
# [*upload_protocol*]
#    The protocol that the preview pocessor will use to upload images. (https or http)
#
# [*nakamura_zip*]
#    The url to a zip of nakamura.
class oae::preview_processor::ruby (
        $user='admin',
        $password='admin',
        $upload_url,
        $nakamura_zip='http://nodeload.github.com/sakaiproject/nakamura/zipball/master') {

    Class['oae::params'] -> Class['oae::preview_processor::ruby']
    Class['oae::preview_processor::common'] -> Class['oae::preview_processor::ruby']

    class { 'oae::preview_processor::common':
        user           => $user,
        password       => $password,
        upload_url     => $upload_url,
        pp_mode        => 'ruby',
    }

    class { 'oae::preview_processor::gems': }
    class { 'oae::preview_processor::packages': }

    exec { 'download nakamura':
        command => "curl -o nakamura.zip ${nakamura_zip}",
        cwd     => $oae::params::basedir,
        user    => $oae::params::user,
        creates => "${oae::params::basedir}/nakamura.zip",
        notify  => Exec['unpack nakamura'],
        timeout => 0,
    }

    exec { 'unpack nakamura':
        command => 'unzip nakamura.zip',
        cwd     => $oae::params::basedir,
        user    => $oae::params::user,
        refreshonly => true,
        require => Exec['download nakamura'],
        timeout => 0,
    }

    exec { 'mv nakamura':
        command => "mv `unzip -l nakamura.zip | head -5 | tail -1 | awk '{ print \$4 }'` nakamura",
        cwd     => $oae::params::basedir,
        user    => $oae::params::user,
        creates => "${oae::params::basedir}/nakamura",
        require => Exec['unpack nakamura'],
        timeout => 0,
    }

    file { "${oae::params::basedir}/nakamura/scripts/logs":
        ensure => link,
        target => $oae::params::preview_log_dir,
    }
}
