plan complex_bolt::remove_app (
  TargetSpec $targets
) {
  # Check if Flask application service exists
  $service_check = run_command('systemctl status flask-app', $targets, '_run_as' => 'root', '_catch_errors' => true)

  if $service_check['_error'] {
    out::message("Service 'flask-app' not found. Skipping stop service step.")
  } else {
    # Stop Flask application service if it exists
    run_task('service', $targets, 'name' => 'flask-app', 'action' => 'stop', '_run_as' => 'root')
  }

  # Prepare targets for applying Puppet code
  apply_prep($targets)

  # Apply Puppet code to remove systemd service file and application files
  apply($targets) {
    file { '/opt/sample-app':
      ensure  => 'absent',
      force   => true,
      recurse => true,
    }

    file { '/etc/systemd/system/flask-app.service':
      ensure => 'absent',
    }

    exec { 'systemctl daemon-reload':
      path => '/usr/bin:/bin:/usr/sbin:/sbin',
    }
  }

  # Remove MySQL user and database
  run_command('mysql -u root -e "DROP USER IF EXISTS \'sample_user\'@\'localhost\'"', $targets, '_run_as' => 'root')
  run_command('mysql -u root -e "DROP DATABASE IF EXISTS sample_db"', $targets, '_run_as' => 'root')

  # Uninstall necessary packages
  run_task('package', $targets, 'name' => 'python3-pip', 'action' => 'uninstall', '_run_as' => 'root')
  run_task('package', $targets, 'name' => 'default-libmysqlclient-dev', 'action' => 'uninstall', '_run_as' => 'root')
  run_task('package', $targets, 'name' => 'mysql-server', 'action' => 'uninstall', '_run_as' => 'root')
  run_task('package', $targets, 'name' => 'python3-mysql.connector', 'action' => 'uninstall', '_run_as' => 'root')
  run_task('package', $targets, 'name' => 'python3-venv', 'action' => 'uninstall', '_run_as' => 'root')
  run_task('package', $targets, 'name' => 'git', 'action' => 'uninstall', '_run_as' => 'root')
}
