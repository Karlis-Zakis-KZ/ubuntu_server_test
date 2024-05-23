plan simple_puppet_bolt::remove_nginx (
  TargetSpec $nodes,
) {
  bolt::task { 'stop_nginx':
    targets => $nodes,
    task    => 'service',
    params  => {
      action => 'stop',
      name   => 'nginx',
    },
  }

  bolt::task { 'disable_nginx':
    targets => $nodes,
    task    => 'service',
    params  => {
      action => 'disable',
      name   => 'nginx',
    },
  }

  bolt::task { 'remove_nginx':
    targets => $nodes,
    task    => 'package',
    params  => {
      action => 'uninstall',
      name   => 'nginx',
    },
  }
}
