plan simple_puppet_bolt::remove_nginx (
  TargetSpec $nodes,
) {
  run_task($nodes, 'service', {'action' => 'stop', 'name' => 'nginx'})
  run_task($nodes, 'service', {'action' => 'disable', 'name' => 'nginx'})
  run_task($nodes, 'package', {'action' => 'uninstall', 'name' => 'nginx'})
}
