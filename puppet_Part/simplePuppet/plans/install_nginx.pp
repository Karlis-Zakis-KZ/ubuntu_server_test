plan simple_puppet_bolt::install_nginx (
  TargetSpec $nodes,
) {
  bolt::task { 'install_nginx':
    targets => $nodes,
    task    => 'package',
    params  => {
      action => 'install',
      name   => 'nginx',
    },
  }

  bolt::task { 'start_nginx':
    targets => $nodes,
    task    => 'service',
    params  => {
      action => 'start',
      name   => 'nginx',
    },
  }

  bolt::task { 'enable_nginx':
    targets => $nodes,
    task    => 'service',
    params  => {
      action => 'enable',
      name   => 'nginx',
    },
  }
}
