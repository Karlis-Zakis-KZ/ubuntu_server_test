plan simple_puppet_bolt::remove_nginx (
  TargetSpec $nodes,
) {
  $package_task = get_task('package')
  $service_task = get_task('service')

  run_task($nodes, $service_task, {'action' => 'stop', 'name' => 'nginx'})
  run_task($nodes, $service_task, {'action' => 'disable', 'name' => 'nginx'})
  run_task($nodes, $package_task, {'action' => 'uninstall', 'name' => 'nginx'})
}
