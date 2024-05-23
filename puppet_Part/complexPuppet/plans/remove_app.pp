plan simple_puppet_bolt::remove_app (
  TargetSpec $nodes,
) {
  apply_prep($nodes)

  apply($nodes) {
    service { 'flask-app':
      ensure => stopped,
      enable => false,
    }

    file { '/opt/sample-app':
      ensure => absent,
      recurse => true,
      force => true,
    }

    exec { 'Remove database and user':
      command => "mysql -u root -pyour_root_password -e 'DROP DATABASE IF EXISTS sampledb; DROP USER IF EXISTS \"sampleuser\"@\"localhost\";'",
    }

    package { ['git', 'python3', 'python3-pip', 'mysql-server']:
      ensure => absent,
    }
  }
}
