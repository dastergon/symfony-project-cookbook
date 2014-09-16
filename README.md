[![Build Status](https://travis-ci.org/activelamp/symfony-project-cookbook.png)](https://travis-ci.org/activelamp/symfony-project-cookbook)

Description
===========

This cookbook provides an easy way to deploy a Symfony2 application, as well as run console commands on it.

Requirements
============

This does not have any hard dependencies on other cookbooks. However you would obviously need the version of PHP you need to run the Symfony application, and of course Composer. You have the choice of which cookbooks you want to use to have this ready on your nodes.

## Platforms:

* Tested on Ubuntu/Debian only, but the deploy actions should work with any platform. However, there is no provider to handle `:set_permissions` on Windows at the moment.

Attributes
==========

_NA_

Resources / Providers
=====================

### `symfony_project`

This resource simply extends the built-in `deploy` resource, but provides sensible defaults that are relevant to most Symfony projects. For example, symlinks are automatically created for `app/logs`, `app/cache`, and `vendor` into the shared folder so that they persist between deploys. `web/media/uploads` is also automatically symlinked. You can override these links by specifying the `shared_dirs` option in the resource.

#### Actions
- All actions supported by the [`deploy`](https://docs.getchef.com/resource_deploy.html) resource.
- `:set_permissions` - Sets the permissions of `app/logs`, `app/cache`, and other shared folders you specify.

#### Examples
```ruby
#Deploy a Symfony project
symfony_project "/path/to/project" do
    repo 'git@github.com:foo_organization/bar_application.git'
    revision 'v1.2'
    git_ssh_wrapper '/tmp/ssh-wrapper.sh'
    action [:deploy, :set_permissions]
end
```

#### Options

All options for the `deploy` resource is applicable here. However here are additional options that are `symfony_project`-specific:


Option | Default | Description
-------|---------|------------
__shared_dirs__ | `{'logs' => 'app/logs','cache' => 'app/cache','uploads' => 'web/media/uploads','vendor' => 'vendor'}` | The directories to create under the shared directory and symlinked into every deployment.
__permission_provider__ | `Chef::Provider::SymfonyPermission::Setfacl` | The provider that handles the setting of the appropriate permissions on the shared directories, most notably `app/logs` and `app/cache`. Only relevant on `:set_permissions`. You can also substitute this for `Chef::Provider::SymfonyPermission::Chmod` if your nodes support the `chmod +a` flag.
__web_user__ | `"www-data"` | The user to whom permission will be granted. Only relevant on `:set_permissions`

License and Authors
===================

Author: Bez Hermoso <bez@activelamp.com>

Author: ActiveLAMP

Copyright: 2012-2014, ActiveLAMP

[Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0.html)
