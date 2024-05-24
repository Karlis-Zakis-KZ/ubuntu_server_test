plan complex_bolt::deploy_app (
  TargetSpec $targets
) {
  # Ensure we are using an agentless approach
  $targets.run_task('package', {'name' => ['python3-pip', 'default-libmysqlclient-dev', 'mysql-server', 'python3-mysql.connector', 'python3-venv'], 'action' => 'install'})

  # Start MySQL service
  $targets.run_task('service', {'name' => 'mysql', 'action' => 'start'})

  # Create database
  $targets.run_task('command', {'command' => 'mysql -u root -e "CREATE DATABASE IF NOT EXISTS sample_db"'})

  # Create MySQL user
  $targets.run_task('command', {'command' => 'mysql -u root -e "CREATE USER IF NOT EXISTS \'sample_user\'@\'localhost\' IDENTIFIED BY \'sample_pass\'; GRANT ALL PRIVILEGES ON sample_db.* TO \'sample_user\'@\'localhost\'; FLUSH PRIVILEGES;"'})

  # Clone the application repository
  $targets.run_task('git', {'repository' => 'https://github.com/jainamoswal/Flask-Example', 'destination' => '/opt/sample-app'})

  # Create a virtual environment and install dependencies
  $targets.run_task('command', {'command' => 'python3 -m venv /opt/sample-app/venv'})
  $targets.run_task('command', {'command' => '/opt/sample-app/venv/bin/pip install -r /opt/sample-app/requirements.txt'})

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

  $targets.run_task('file', {'path' => '/etc/systemd/system/flask-app.service', 'content' => $service_file, 'action' => 'create'})

  # Reload systemd and start the service
  $targets.run_task('command', {'command' => 'systemctl daemon-reload'})
  $targets.run_task('service', {'name' => 'flask-app', 'action' => 'start', 'enabled' => true})
}
