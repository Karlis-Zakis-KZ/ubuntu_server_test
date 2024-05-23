plan simple_puppet_bolt::revert_nginx (
  TargetSpec $nodes,
) {
  apply_prep($nodes)

  apply($nodes) {
    service { 'nginx':
      ensure => stopped,
      enable => false,
    }

    package { 'nginx':
      ensure => absent,
    }
  }
}
