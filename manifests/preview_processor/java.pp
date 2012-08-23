#
# == Class oae::preview_processor::java
# Install the preview processor jar.
#
# == Parameters:
#
# [*user*]
#    An OAE admin username
#
# [*password*]
#    The OAE admin password
#
# [*upload_url*]
#    The url that the preview pocessor will use to upload images. (https or http)
#
# [*content_url*]
#    The url that OAE redirects to for content [needed mostly for split hostname SSL setups]
#
# [*jar_url*]
#    A url to a jar-with-dependencies artifact of the preview processor
#
# [*jar_source*]
#    A source url to the jar-with-dependencies artifact of the preview processor
#
# === Example Usage
#
# class { 'oae::preview_processor::java':
#     user => 'admin',
#     password => 'verysecret',
#     upload_url => 'http://localhost:8080/',
#     content_url => 'http://localhost:8082/'
#     jar_source  => '/usr/local/deploy/org.sakaiproject.nakamura.preview-1.5.0-SNAPSHOT-jar-with-dependencies.jar'
# }
class oae::preview_processor::java (
    $user='admin',
    $password='admin',
    $upload_url,
    $content_url,
    $jar_url    = '',
    $jar_source = '',
    $directory  = ''
    ) {

    Class['Oae::Params'] -> Class['Oae::Preview_processor::Java']
    Class['Oae::Preview_processor::Common'] -> Class['Oae::Preview_processor::Java']

    $home = "${oae::params::basedir}/preview" 
    $working_directory = $directory ? {
        ''      => "${home}/scratch",
        default => $directory,
    }
    
    class { 'oae::preview_processor::common': 
        user           => $user,
        password       => $password,
        upload_url     => $upload_url,
        pp_mode        => 'java',
    }

    file { [$home, $working_directory]:
        ensure => directory,
        owner  => $oae::params::user,
        group  => $oae::params::group,
    }

    if $jar_url != '' {
        archive::download { "preview.jar":
            ensure     => present,
            url        => $jar_url,
            src_target => $home,
            require    => File[$home],
        }
    }

    if $jar_source != '' {
        file { "${home}/preview.jar":
            owner  => root,
            group  => root,
            mode   => 0644,
            source => $jar_source
        }
    }
}