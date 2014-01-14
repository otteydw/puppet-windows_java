# == Class: jdk
#
# Full description of class jdk here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*install_name*]
#   The name as it will appear in the Add or Remove Programes
# [*default*]
#   If this is the default Java install and will accordingly assign
#   to JAVA_HOME and Environment Variable Path defaults to true
# [*source*]
#   URL to download the msi or executable from can be ftp as well as http
# [*cookie_string*]
#   String to bypass the accept license from Oracle
# [*ensure*]
#   Present or absent
# [*install_path*]
#   The path to install java to, defaults to c:\Program Files\Java\jdk1.7.0_45
# === Examples
#
#  windows_java::jdk{'JDK 7u45':
#     install_name = 'Java SE Development Kit 7 Update 45 (64-bit)',
#     ensure      = 'present',
#     install_path= "c:\\java\\jdk1.7.0_45"
#  }
#
# === Authors
#
# Author Name Travis Fields
#
# === Copyright
#
# Copyright 2013 Your name here, unless otherwise noted.
#
define windows_java::jdk (
  $version        = '7u45',
  $arch           = 'x64',
  $default        = true,
  $ensure         = 'present',
  $install_name    = undef,
  $source         = undef,
  $install_path   = undef,
  $cookie_string  = 'gpw_e24=http%3A%2F%2Fwww.oracle.com%2Ftechnetwork%2Fjava%2Fjavase%2Fdownloads%2Fjdk-7u3-download-1501626.html;')
{
  $version_info = hiera($version)
  $arch_info = $version_info[$arch]

  if ! $install_name {
    $installName = $arch_info['install_name']
  }else{
    $installName = $install_name
  }

  if($ensure == 'present'){
    if ! $source {
      $remoteSource = $arch_info['source']
    }else{
      $remoteSource = $source
    }
    if ! $install_path {
      $installPath = $arch_info['install_path']
    }else{
      $installPath = $install_path
    }

    $filename = filename($remoteSource)

    $tempLocation = "C:\\temp\\${filename}"
    $headerInfo = {
      'user-agent'
        =>'Mozilla/5.0 (Windows NT 6.3; Trident/7.0; rv:11.0) like Gecko'
      ,'Cookie' => $cookie_string }
    debug("My header info is ${headerInfo}")
    pget{"Download-${filename}":
      source      => $remoteSource,
      target      => "C:\\temp",
      headerHash  => $headerInfo
    }

    package{$installName:
      ensure          => $ensure,
      provider        => windows,
      source          => $tempLocation,
      install_options => ['/s',{'INSTALLDIR'=> $installPath}],
      require         => Exec["Download-${filename}"]
    }

    if($default){
      windows_env{'JAVA_HOME':
        ensure    => present,
        value     => $installPath,
        mergemode => clobber,
        require   => Package[$installName];
      }
      windows_env{'PATH=%JAVA_HOME%\bin':}
    }
  }else{
    package{$installName:
      ensure          => $ensure,
      provider        => windows,
    }
  }
}
