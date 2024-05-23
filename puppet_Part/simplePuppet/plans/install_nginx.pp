plan simple_puppet_bolt::install_nginx (
  TargetSpec $nodes,
) {
  apply_prep($nodes)

  apply($nodes) {
    package { 'nginx':
      ensure => installed,
    }

    service { 'nginx':
      ensure => running,
      enable => true,
    }
  }
}
