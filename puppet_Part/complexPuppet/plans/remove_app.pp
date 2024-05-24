plan complex_bolt::remove_app (
  TargetSpec $targets
) {
  # Stop Flask application service
  run_task('service', $targets, 'name' => 'flask-app', 'action' => 'stop', '_run_as' => 'root')

  # Remove application files
  run_task('file', $targets, 'path' => '/opt/sample-app', 'action' => 'delete', '_run_as' => 'root')

  # Remove systemd service file
  run_task('file', $targets, 'path' => '/etc/systemd/system/flask-app.service', 'action' => 'delete', '_run_as' => 'root')

  # Reload systemd
  run_task('command', $targets, 'command' => 'systemctl daemon-reload', '_run_as' => 'root')

  # Remove MySQL user
  run_task('command', $targets, 'command' => 'mysql -u root -e "DROP USER IF EXISTS \'sample_user\'@\'localhost\'"', '_run_as' => 'root')

  # Drop database
  run_task('command', $targets, 'command' => 'mysql -u root -e "DROP DATABASE IF EXISTS sample_db"', '_run_as' => 'root')

  # Uninstall necessary packages
  run_task('package', $targets, 'name' => 'python3-pip', 'action' => 'uninstall', '_run_as' => 'root')
  run_task('package', $targets, 'name' => 'default-libmysqlclient-dev', 'action' => 'uninstall', '_run_as' => 'root')
  run_task('package', $targets, 'name' => 'mysql-server', 'action' => 'uninstall', '_run_as' => 'root')
  run_task('package', $targets, 'name' => 'python3-mysql.connector', 'action' => 'uninstall', '_run_as' => 'root')
  run_task('package', $targets, 'name' => 'python3-venv', 'action' => 'uninstall', '_run_as' => 'root')
}
