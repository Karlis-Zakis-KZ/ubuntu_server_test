plan complex_bolt::deploy_app (
  TargetSpec $targets
) {
  # Ensure we are using an agentless approach
  run_task('package', $targets, {'name' => 'python3-pip', 'action' => 'install'}, '_run_as' => 'root')
  run_task('package', $targets, {'name' => 'default-libmysqlclient-dev', 'action' => 'install'}, '_run_as' => 'root')
  run_task('package', $targets, {'name' => 'mysql-server', 'action' => 'install'}, '_run_as' => 'root')
  run_task('package', $targets, {'name' => 'python3-mysql.connector', 'action' => 'install'}, '_run_as' => 'root')
  run_task('package', $targets, {'name' => 'python3-venv', 'action' => 'install'}, '_run_as' => 'root')

  # Start MySQL service
  run_task('service', $targets, {'name' => 'mysql', 'action' => 'start'}, '_run_as' => 'root')

  # Create database
  run_task('command', $targets, {'command' => 'mysql -u root -e "CREATE DATABASE IF NOT EXISTS sample_db"'}, '_run_as' => 'root')

  # Create MySQL user
  run_task('command', $targets, {'command' => 'mysql -u root -e "CREATE USER IF NOT EXISTS \'sample_user\'@\'localhost\' IDENTIFIED BY \'sample_pass\'; GRANT ALL PRIVILEGES ON sample_db.* TO \'sample_user\'@\'localhost\'; FLUSH PRIVILEGES;"'}, '_run_as' => 'root')

  # Clone the application repository
  run_task('git', $targets, {'repository' => 'https://github.com/jainamoswal/Flask-Example', 'destination' => '/opt/sample-app'}, '_run_as' => 'root')

  # Create a virtual environment and install dependencies
  run_task('command', $targets, {'command' => 'python3 -m venv /opt/sample-app/venv'}, '_run_as' => 'root')
  run_task('command', $targets, {'command' => '/opt/sample-app/venv/bin/pip install -r /opt/sample-app/requirements.txt'}, '_run_as' => 'root')

  # Create systemd service file
  $service_file = @("END"/L)
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

  run_task('file', $targets, {'path' => '/etc/systemd/system/flask-app.service', 'content' => $service_file, 'action' => 'create'}, '_run_as' => 'root')

  # Reload systemd and start the service
  run_task('command', $targets, {'command' => 'systemctl daemon-reload'}, '_run_as' => 'root')
  run_task('service', $targets, {'name' => 'flask-app', 'action' => 'start', 'enabled' => true}, '_run_as' => 'root')
}
