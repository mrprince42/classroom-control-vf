class nginx {
  case$::osfamily {
    'redhat','debian':{
    $package   = 'nginx'
    $owner     = 'root'
    $group     = 'root'
    $docroot   = '/var/www'
    $confdir   = '/etc/nginx/'
    $logdir    = '/var/log/nginx'
    $serverdir = '/etc/nginx/conf.d'
    }
    
    'windows':{
    $package   = 'nginx-service'
    $owner     = 'Administrator'
    $group     = 'Administrators'
    $docroot   = 'C:/ProgramData/nginx/html'
    $confdir   = 'C:/ProgramData/nginx'
    $logdir    = 'C:/ProgramData/nginx/logs'
    $serverdir = 'C:/ProgramData/nginx/conf.d'
    }
    
   default  :{
     fail("Module ${module_name} is not supported on ${::osfamily}")
   }
 }
 
   $user = $::osfamily ? {
    'redhat' => 'nginx',
    'debian' => 'www-data',
    'windows' => 'nobody',
   }

  File {
   owner => 'root',
   group => 'root',
   mode => '0664',
  }
  
   package { 'nginx':
    ensure => present,
   }
   
   file { [ '/var/www', '/etc/nginx/conf.d' ]:
    ensure => directory,
   }
   
   file { '/var/www/index.html':
    ensure => file,
    source => 'puppet:///modules/nginx/index.html',
   }
   
   file { '/etc/nginx/nginx.conf':
    ensure => file,
    source => 'puppet:///modules/nginx/nginx.conf',
    require => Package['nginx'],
    notify => Service['nginx'],
   }
   
   file { '/etc/nginx/conf.d/default.conf':
    ensure => file,
    source => 'puppet:///modules/nginx/default.conf',
    notify => Service['nginx'],
    require => Package['nginx'],
   }
   
   service { 'nginx':
    ensure => running,
    enable => true,
   }
 }
