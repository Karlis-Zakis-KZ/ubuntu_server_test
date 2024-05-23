plan simple_puppet_bolt::install_nginx (
  TargetSpec $nodes,
) {
  $package_task = get_task('package')
  $service_task = get_task('service')

  run_task($nodes, $package_task, {'action' => 'install', 'name' => 'nginx'})
  run_task($nodes, $service_task, {'action' => 'start', 'name' => 'nginx'})
  run_task($nodes, $service_task, {'action' => 'enable', 'name' => 'nginx'})
}
