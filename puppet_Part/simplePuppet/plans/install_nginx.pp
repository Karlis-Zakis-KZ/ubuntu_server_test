plan simple_puppet_bolt::install_nginx (
  TargetSpec $nodes,
) {
  run_task('package', $nodes, {'action' => 'install', 'name' => 'nginx'}, 'become' => true)
  run_task('service', $nodes, {'action' => 'start', 'name' => 'nginx'}, 'become' => true)
  run_task('service', $nodes, {'action' => 'enable', 'name' => 'nginx'}, 'become' => true)
}
