plan complex_bolt::remove_app (
  TargetSpec $targets
) {
  # Ensure we are using an agentless approach
  $targets.run_task('service', {'name' => 'flask-app', 'action' => 'stop'})

  # Remove application files
  $targets.run_task('file', {'path' => '/opt/sample-app', 'action' => 'delete'})

  # Remove systemd service file
  $targets.run_task('file', {'path' => '/etc/systemd/system/flask-app.service', 'action' => 'delete'})

  # Reload systemd
  $targets.run_task('command', {'command' => 'systemctl daemon-reload'})

  # Remove MySQL user
  $targets.run_task('command', {'command' => 'mysql -u root -e "DROP USER IF EXISTS \'sample_user\'@\'localhost\'"'})

  # Drop database
  $targets.run_task('command', {'command' => 'mysql -u root -e "DROP DATABASE IF EXISTS sample_db"'})

  # Uninstall necessary packages
  $targets.run_task('package', {'name' => ['python3-pip', 'default-libmysqlclient-dev', 'mysql-server', 'python3-mysql.connector', 'python3-venv'], 'action' => 'uninstall'})
}
