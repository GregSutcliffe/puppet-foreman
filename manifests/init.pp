# Manage your foreman server
#
# === Parameters:
#
# $foreman_url::            URL on which foreman is going to run
#
# $unattended::             Should foreman manage host provisioning as well
#                           type:boolean
#
# $authentication::         Enable users authentication (default user:admin pw:changeme)
#                           type:boolean
#
# $passenger::              Configure foreman via apache and passenger
#                           type:boolean
#
# $passenger_scl::          Software collection name (on RHEL currently 'ruby193', undef on others)
#
# $use_vhost::              Enclose apache configuration in <VirtualHost>...</VirtualHost>
#                           type:boolean
#
# $ssl::                    Enable and set require_ssl in Foreman settings (note: requires passenger, SSL does not apply to kickstarts)
#                           type:boolean
#
# $custom_repo::            No need to change anything here by default
#                           if set to true, no repo will be added by this module, letting you to
#                           set it to some custom location.
#                           type:boolean
#
# $repo::                   This can be stable, rc, or nightly
#
# $configure_epel_repo::    If disabled the EPEL repo will not be configured on RedHat family systems.
#                           type:boolean
#
# $configure_scl_repo::     If disabled the the SCL repo will not be configured on Red Hat clone systems.
#                           (Currently only installs repos for CentOS and Scientific)
#                           type:boolean
#
# $selinux::                when undef, foreman-selinux will be installed if SELinux is enabled
#                           setting to false/true will override this check (e.g. set to false on 1.1)
#                           type:boolean
#
# $gpgcheck::               turn on/off gpg check in repo files (effective only on RedHat family systems)
#                           type:boolean
#
# $version::                foreman package version, it's passed to ensure parameter of package resource
#                           can be set to specific version number, 'latest', 'present' etc.
#
# $db_manage::              if enabled, will install and configure the database server on this host
#                           type:boolean
#
# $db_type::                Database 'production' type (valid types: mysql/postgresql/sqlite)
#
# $db_adapter::             Database 'production' adapter
#
# $db_host::                Database 'production' host
#
# $db_port::                Database 'production' port
#                           type:integer
#
# $db_database::            Database 'production' database (e.g. foreman)
#
# $db_username::            Database 'production' user (e.g. foreman)
#
# $db_password::            Database 'production' password (default is random)
#
# $db_sslmode::             Database 'production' ssl mode
#
# $app_root::               Name of foreman root directory
#
# $user::                   User under which foreman will run
#
# $group::                  Primary group for the Foreman user
#
# $user_groups::            Additional groups for the Foreman user
#                           type:array
#
# $environment::            Rails environment of foreman
#
# $puppet_home::            Puppet home directory
#
# $locations_enabled::      Enable locations?
#                           type:boolean
#
# $organizations_enabled::  Enable organizations?
#                           type:boolean
#
# $passenger_interface::    Defines which network interface passenger should listen on, undef means all interfaces
#
# $server_ssl_ca::          Defines Apache mod_ssl SSLCACertificateFile setting in Foreman vhost conf file.
#
# $server_ssl_chain::       Defines Apache mod_ssl SSLCertificateChainFile setting in Foreman vhost conf file.
#
# $server_ssl_cert::        Defines Apache mod_ssl SSLCertificateFile setting in Foreman vhost conf file.
#
# $server_ssl_key::         Defines Apache mod_ssl SSLCertificateKeyFile setting in Foreman vhost conf file.
#
# $oauth_active::           Enable OAuth authentication for REST API
#                           type:boolean
#
# $oauth_map_users::        Should foreman use the foreman_user header to identify API user?
#                           type:boolean
#
# $oauth_consumer_key::     OAuth consumer key
#
# $oauth_consumer_secret::  OAuth consumer secret
#
class foreman (
  $foreman_url            = $foreman::params::foreman_url,
  $unattended             = $foreman::params::unattended,
  $authentication         = $foreman::params::authentication,
  $passenger              = $foreman::params::passenger,
  $passenger_scl          = $foreman::params::passenger_scl,
  $use_vhost              = $foreman::params::use_vhost,
  $ssl                    = $foreman::params::ssl,
  $custom_repo            = $foreman::params::custom_repo,
  $repo                   = $foreman::params::repo,
  $configure_epel_repo    = $foreman::params::configure_epel_repo,
  $configure_scl_repo     = $foreman::params::configure_scl_repo,
  $selinux                = $foreman::params::selinux,
  $gpgcheck               = $foreman::params::gpgcheck,
  $version                = $foreman::params::version,
  $db_manage              = $foreman::params::db_manage,
  $db_type                = $foreman::params::db_type,
  $db_adapter             = 'UNSET',
  $db_host                = 'UNSET',
  $db_port                = 'UNSET',
  $db_database            = 'UNSET',
  $db_username            = $foreman::params::db_username,
  $db_password            = $foreman::params::db_password,
  $db_sslmode             = 'UNSET',
  $app_root               = $foreman::params::app_root,
  $user                   = $foreman::params::user,
  $group                  = $foreman::params::group,
  $user_groups            = $foreman::params::user_groups,
  $environment            = $foreman::params::environment,
  $puppet_home            = $foreman::params::puppet_home,
  $locations_enabled      = $foreman::params::locations_enabled,
  $organizations_enabled  = $foreman::params::organizations_enabled,
  $passenger_interface    = $foreman::params::passenger_interface,
  $server_ssl_ca          = $foreman::params::server_ssl_ca,
  $server_ssl_chain       = $foreman::params::server_ssl_chain,
  $server_ssl_cert        = $foreman::params::server_ssl_cert,
  $server_ssl_key         = $foreman::params::server_ssl_key,
  $oauth_active           = $foreman::params::oauth_active,
  $oauth_map_users        = $foreman::params::oauth_map_users,
  $oauth_consumer_key     = $foreman::params::oauth_consumer_key,
  $oauth_consumer_secret  = $foreman::params::oauth_consumer_secret
) inherits foreman::params {
  if $db_adapter == 'UNSET' {
    $db_adapter_real = $foreman::db_type ? {
      'sqlite' => 'sqlite3',
      'mysql'  => 'mysql2',
      default  => $foreman::db_type,
    }
  } else {
    $db_adapter_real = $db_adapter
  }
  class { 'foreman::install': } ~>
  class { 'foreman::config': } ~>
  class { 'foreman::database': } ~>
  class { 'foreman::service': } ->
  Class['foreman'] ->
  Foreman_smartproxy <| |>

  # Handle these separately so as not to break
  # the notify between main classes
  class { 'foreman::install': } ~>
  class { 'foreman::compute': }

  Class['foreman::database']~>
  Foreman::Plugin <| |> ~>
  Class['foreman::service']

}
