plan simple_puppet_bolt::remove_nginx (
  TargetSpec $nodes,
) {
  run_task('service', $nodes, {'action' => 'stop', 'name' => 'nginx'}, 'become' => true)
  run_task('service', $nodes, {'action' => 'disable', 'name' => 'nginx'}, 'become' => true)
  run_task('package', $nodes, {'action' => 'uninstall', 'name' => 'nginx'}, 'become' => true)
}
