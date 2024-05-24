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

  # Create systemd service file for Flask application
  run_command('echo "[Unit]
Description=Flask App
After=network.target

[Service]
User=root
WorkingDirectory=/opt/sample-app
Environment="PATH=/opt/sample-app/venv/bin"
ExecStart=/opt/sample-app/venv/bin/python /opt/sample-app/app.py

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/flask-app.service', $targets, '_run_as' => 'root')

  # Start and enable Flask application service
  run_task('service', $targets, 'name' => 'flask-app', 'action' => 'start', '_run_as' => 'root')
  run_task('service', $targets, 'name' => 'flask-app', 'action' => 'enable', '_run_as' => 'root')
}
