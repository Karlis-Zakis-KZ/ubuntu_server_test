plan complex_bolt::remove_app (
  TargetSpec $targets
) {
  # Ensure we are using an agentless approach
  run_task('service', $targets, {'name' => 'flask-app', 'action' => 'stop'})

  # Remove application files
  run_task('file', $targets, {'path' => '/opt/sample-app', 'action' => 'delete'})

  # Remove systemd service file
  run_task('file', $targets, {'path' => '/etc/systemd/system/flask-app.service', 'action' => 'delete'})

  # Reload systemd
  run_task('command', $targets, {'command' => 'systemctl daemon-reload'})

  # Remove MySQL user
  run_task('command', $targets, {'command' => 'mysql -u root -e "DROP USER IF EXISTS \'sample_user\'@\'localhost\'"'})

  # Drop database
  run_task('command', $targets, {'command' => 'mysql -u root -e "DROP DATABASE IF EXISTS sample_db"'})

  # Uninstall necessary packages
  run_task('package', $targets, {'name' => ['python3-pip', 'default-libmysqlclient-dev', 'mysql-server', 'python3-mysql.connector', 'python3-venv'], 'action' => 'uninstall'})
}
