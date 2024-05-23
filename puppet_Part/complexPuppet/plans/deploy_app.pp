plan simple_puppet_bolt::deploy_app (
  TargetSpec $nodes,
) {
  apply_prep($nodes)

  apply($nodes) {
    package { ['git', 'python3', 'python3-pip', 'mysql-server']:
      ensure => installed,
    }

    service { 'mysql':
      ensure => running,
      enable => true,
    }

    exec { 'Clone repository':
      command => '/usr/bin/git clone https://github.com/sample/sample-app.git /opt/sample-app',
      creates => '/opt/sample-app',
    }

    exec { 'Create database and user':
      command => "mysql -u root -pyour_root_password -e 'CREATE DATABASE sampledb; CREATE USER \"sampleuser\"@\"localhost\" IDENTIFIED BY \"samplepassword\"; GRANT ALL PRIVILEGES ON sampledb.* TO \"sampleuser\"@\"localhost\";'",
      unless  => "mysql -u root -pyour_root_password -e 'SHOW DATABASES LIKE \"sampledb\";' | grep sampledb",
    }

    exec { 'Install dependencies':
      command => '/usr/bin/pip3 install -r /opt/sample-app/requirements.txt',
    }

    file { '/opt/sample-app/config.ini':
      content => epp('templates/config.epp'),
    }

    service { 'sample-app':
      ensure => running,
      enable => true,
    }
  }
}
