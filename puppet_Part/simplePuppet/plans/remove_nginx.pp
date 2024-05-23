plan simple_puppet_bolt::remove_nginx (
  TargetSpec $nodes,
) {
  run_task('service', $nodes, {'action' => 'stop', 'name' => 'nginx', '_run_as' => 'root'})
  run_task('service', $nodes, {'action' => 'disable', 'name' => 'nginx', '_run_as' => 'root'})
  run_task('package', $nodes, {'action' => 'uninstall', 'name' => 'nginx', '_run_as' => 'root'})
}
