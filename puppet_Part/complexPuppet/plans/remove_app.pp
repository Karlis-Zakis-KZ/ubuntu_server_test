plan complex_bolt::remove_app (
  TargetSpec $targets
) {
  # Check if Flask application service exists and stop it if active
  $service_check = run_command('systemctl status flask-app', $targets, '_run_as' => 'root', '_catch_errors' => true)
  out::message("Service check result: ${service_check}")

  $service_check.each |$result| {
    if $result['value'] and $result['value']['exit_code'] == 0 {
      run_task('service', $result['target'], 'name' => 'flask-app', 'action' => 'stop', '_run_as' => 'root')
      run_task('service', $result['target'], 'name' => 'flask-app', 'action' => 'disable', '_run_as' => 'root')
    } elsif $result['value'] and $result['value']['exit_code'] == 3 {
      out::message("Service 'flask-app' is inactive on ${result['target']}.")
      run_task('service', $result['target'], 'name' => 'flask-app', 'action' => 'disable', '_run_as' => 'root')
    } else {
      out::message("Service 'flask-app' not found on ${result['target']}. Skipping stop service step.")
    }
  }

  # Remove systemd service file and application files using commands
  run_command('rm -rf /opt/sample-app', $targets, '_run_as' => 'root')
  run_command('rm -f /etc/systemd/system/flask-app.service', $targets, '_run_as' => 'root')
  run_command('systemctl daemon-reload', $targets, '_run_as' => 'root')

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
