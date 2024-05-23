plan simple_puppet_bolt::install_nginx (
  TargetSpec $nodes,
) {
  run_task($nodes, 'package', {'action' => 'install', 'name' => 'nginx'})
  run_task($nodes, 'service', {'action' => 'start', 'name' => 'nginx'})
  run_task($nodes, 'service', {'action' => 'enable', 'name' => 'nginx'})
}
