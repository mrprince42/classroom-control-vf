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
   owner => $owner,
   group => $group,
   mode => '0664',
  }
  
   package { 'nginx':
    ensure => present,
   }
   
   file { [ $docroot, '${confdir}/conf.d' ]:
    ensure => directory,
   }
   
   file { '${docroot}/index.html':
    ensure => file,
    source => 'puppet:///modules/nginx/index.html',
   }
   
   file { '${confdir}/nginx.conf':
    ensure  => file,
    content => epp('/templates/nginx.conf.epp',
      {
        user    => $user,
        confdir => $confdir,
        logdir  => $logdir,
        }),
     notify => Service['nginx'],
   }
   
   file { '${confdir}/conf.d/default.conf':
    ensure  => file,
    content => epp('templates/default.conf.epp',
    {
      docroot => $docroot,
    }),
    notify  => Service['nginx'],
   }
   
   service { 'nginx':
    ensure => running,
    enable => true,
   }
 }
