plan complex_bolt::deploy_app (
  TargetSpec $targets
) {
  # Install necessary packages
  run_task('package', $targets, 'name' => 'python3-pip', 'action' => 'install', '_run_as' => 'root')
  run_task('package', $targets, 'name' => 'default-libmysqlclient-dev', 'action' => 'install', '_run_as' => 'root')
  run_task('package', $targets, 'name' => 'mysql-server', 'action' => 'install', '_run_as' => 'root')
  run_task('package', $targets, 'name' => 'python3-mysql.connector', 'action' => 'install', '_run_as' => 'root')
  run_task('package', $targets, 'name' => 'python3-venv', 'action' => 'install', '_run_as' => 'root')
  run_task('package', $targets, 'name' => 'git', 'action' => 'install', '_run_as' => 'root')

  # Start MySQL service
  run_task('service', $targets, 'name' => 'mysql', 'action' => 'start', '_run_as' => 'root')

  # Create database and user
  run_command('mysql -u root -e "CREATE DATABASE IF NOT EXISTS sample_db"', $targets, '_run_as' => 'root')
  run_command('mysql -u root -e "CREATE USER IF NOT EXISTS \'sample_user\'@\'localhost\' IDENTIFIED BY \'sample_pass\'; GRANT ALL PRIVILEGES ON sample_db.* TO \'sample_user\'@\'localhost\'; FLUSH PRIVILEGES;"', $targets, '_run_as' => 'root')

  # Clone the application repository
  run_command('git clone https://github.com/jainamoswal/Flask-Example /opt/sample-app', $targets, '_run_as' => 'root')

  # Create a virtual environment and install dependencies
  run_command('python3 -m venv /opt/sample-app/venv', $targets, '_run_as' => 'root')
  run_command('/opt/sample-app/venv/bin/pip install -r /opt/sample-app/requirements.txt', $targets, '_run_as' => 'root')

  # Prepare targets for applying Puppet code
  apply_prep($targets)

  # Apply Puppet code to create systemd service file
  apply($targets) {
    file { '/etc/systemd/system/flask-app.service':
      ensure  => 'file',
      content => @(END)
        [Unit]
        Description=Flask Application

        [Service]
        ExecStart=/opt/sample-app/venv/bin/python /opt/sample-app/run.py
        Restart=always
        User=root
        Group=root
        Environment=PYTHONUNBUFFERED=1

        [Install]
        WantedBy=multi-user.target
        END
    }

    # Reload systemd and start the service
    exec { 'systemctl daemon-reload':
      path => '/usr/bin:/bin:/usr/sbin:/sbin',
    }

    service { 'flask-app':
      ensure    => 'running',
      enable    => true,
      hasstatus => true,
      hasrestart => true,
    }
  }
}
