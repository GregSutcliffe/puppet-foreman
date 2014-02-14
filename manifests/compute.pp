class foreman::compute {
  # A bunch of virtual packages for using in compute classes
  @package { ['foreman-compute','foreman-libvirt']:
    ensure => installed,
    notify => Class['foreman::service'],
  }
}
