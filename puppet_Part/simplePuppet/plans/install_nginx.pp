plan simple_puppet_bolt::install_nginx (
  TargetSpec $nodes,
) {
  run_task('package', $nodes, {'action' => 'install', 'name' => 'nginx'})
  run_task('service', $nodes, {'action' => 'start', 'name' => 'nginx'})
  run_task('service', $nodes, {'action' => 'enable', 'name' => 'nginx'})
}
