plan complex_bolt::deploy_app (
  TargetSpec $targets
) {
  $targets.apply_prep

  # Install necessary packages
  run_task('package', $targets, {'name' => ['python3-pip', 'default-libmysqlclient-dev', 'mysql-server', 'python3-mysql.connector', 'python3-venv'], 'action' => 'install'})

  # Start MySQL service
  run_task('service', $targets, {'name' => 'mysql', 'action' => 'start'})

  # Create database
  run_task('command', $targets, {'command' => 'mysql -u root -e "CREATE DATABASE IF NOT EXISTS sample_db"'})

  # Create MySQL user
  run_task('command', $targets, {'command' => 'mysql -u root -e "CREATE USER IF NOT EXISTS \'sample_user\'@\'localhost\' IDENTIFIED BY \'sample_pass\'; GRANT ALL PRIVILEGES ON sample_db.* TO \'sample_user\'@\'localhost\'; FLUSH PRIVILEGES;"'})

  # Clone the application repository
  run_task('git', $targets, {'repository' => 'https://github.com/jainamoswal/Flask-Example', 'destination' => '/opt/sample-app'})

  # Create a virtual environment and install dependencies
  run_task('command', $targets, {'command' => 'python3 -m venv /opt/sample-app/venv'})
  run_task('command', $targets, {'command' => '/opt/sample-app/venv/bin/pip install -r /opt/sample-app/requirements.txt'})

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

  run_task('file', $targets, {'path' => '/etc/systemd/system/flask-app.service', 'content' => $service_file, 'action' => 'create'})

  # Reload systemd and start the service
  run_task('command', $targets, {'command' => 'systemctl daemon-reload'})
  run_task('service', $targets, {'name' => 'flask-app', 'action' => 'start', 'enabled' => true})
}
