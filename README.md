[![Build Status](https://travis-ci.org/activelamp/symfony-project-cookbook.png)](https://travis-ci.org/activelamp/symfony-project-cookbook)

Description
===========

This cookbook provides an easy way to deploy a Symfony2 application, as well as run console commands on it.

Requirements
============

* `activelamp_composer` cookbook


__You might also need to install this on your node(s):__

* `acl` package to support the use of `Chef::Provider::SymfonyPermission::Setfacl`. You might have to use this if your nodes does not support the `chmod +a ...` command. You can install this using your platform's package manager (.i.e., `apt`)

#### Installing PHP and other packages is outside the scope of this cookbook.

## Platforms:

* Tested on Ubuntu/Debian only, but the deploy actions should work with any platform. However, there is no provider to handle `:set_permissions` on Windows at the moment.

Attributes
==========

_NA_

Resources / Providers
=====================

### `symfony_project`

This resource simply extends the built-in `deploy` resource, but provides sensible defaults that are relevant to most Symfony projects. For example, a symlink is automatically created for `app/logs` into the shared folder so that they persist between deploys. `web/uploads` is also automatically symlinked. You can override these links by specifying the `shared_dirs` option in the resource.

#### Actions
- All actions supported by the [`deploy`](https://docs.getchef.com/resource_deploy.html) resource.
- `:set_permissions` - Sets the permissions of `app/logs`, `app/cache`, `web/uploads` and any other directories you specified under `world_writable_dirs`

#### Examples
```ruby
#Deploy a Symfony project
symfony_project "/path/to/project" do
    repo 'git@github.com:foo_organization/bar_application.git'
    revision 'v1.2'
    git_ssh_wrapper '/tmp/ssh-wrapper.sh'
    action [:deploy, :set_permissions]
    composer_options({
        :dev => true,
        :quiet => false,
        :verbosity => 2
    })
    parameters({
        :database_user => 'root',
        :database_password => node[:mysql][:server_root_password]
    })
end
```

#### Attributes

All options for the `deploy` resource is applicable here. However here are additional options that are `symfony_project`-specific:


Name | Default | Description
-------|---------|------------
__shared_dirs__ | `{'logs' => 'app/logs','cache' => 'app/cache','uploads' => 'web/media/uploads','vendor' => 'vendor'}` | The directories to create under the shared directory and symlinked into every deployment.
__world_writable_dirs__ | `['app/logs', 'app/cache', 'web/uploads']` | Directories that should be world writeable.
__permission_provider__ | `Chef::Provider::SymfonyPermission::Chmod` | The provider that handles the setting of the appropriate permissions on the directories listed under `world_writable_dirs`. Only relevant on `:set_permissions`. You can also substitute this for `Chef::Provider::SymfonyPermission::Setfacl` if your prefer to use `setfacl` to set the permissions.
__web_user__ | `"www-data"` | The user to whom permission will be granted/umasked. Only relevant on `:set_permissions`
__parameters__ | `{}` | Parameters overrides.
__parameters_file__ | `app/config/parameters.yml` | Path to the parameters file
__parameters_dist_file__ | `app/config/parameters.yml.dist` | Path to the parameters file distributable.
__parameters_file_template__ | `parameters.yml.erb` | The `ERB` template for the parameters file. Parameter overriding is disabled if this is set to `nil`.
__parameters_file_template_cookbook__ | `nil` | The cookbook where the prefered template is located. This will default to the current cookbook. Specify `:activelamp_symfony` if you wish to use the built-in one. Use `@parameters` to access the container parameters which are merged from the contents of the distributable and the values in `parameters`.
__composer_options__ | `{ :action => [:download_phar, :install], :lock_file_only => true, :dev => false, :prefer_dist => true, :prefer_source => false, :optimize_autoloader => true}` | The options used when the `composer` resource is called internally during `migrate`. Refer to the [`activelamp_composer`](https://supermarket.getchef.com/cookbooks/activelamp_composer) cookbook for available options.

### `app_console`

You can use this resource to interact with your Symfony application via the Symfony Console.

#### Actions
- `:run` (default) - Runs the command
- `:nothing`

#### Examples
```ruby
#Run a Symfony Console command
app_console "/path/to/project/current" do
    command 'assetic:dump --force'
    environment 'prod'
    quiet false
    verbosity 3
    user node[:user]
    group node[:group]
end
```

#### Attributes


Attribute | Default | Description
-------|---------|------------
__app__| __The name attribute__ | The project root of the Symfony application.
__command__ | `nil` | The command to execute
__environment__ | `:prod` | The environment to run the command in. Used in the `--env` flag
__quiet__ | `true` | If `true`, adds the `--quiet` flag
__verbosity__ | `1` | Value for the `--verbose` flag.
__user__ | nil | The user to execute the command as.
__group__ | nil | The group to execute the command as.
__console__ | `php app/console` | The Symfony Console command to use.


### An example on using `symfony_project` and `app_console` together during deploys:

```ruby
symfony_project "/path/to/project" do
    repo 'git@github.com:foo_organization/bar_application.git'
    revision 'v1.2'
    git_ssh_wrapper '/tmp/ssh-wrapper.sh'
    parameters({
        :database_user => 'root',
        :database_password => node[:mysql][:server_root_password],
        :database_host => 'localhost'
    })
    user node[:deploy_user]
    group node[:deploy_group]
    permission_provider Chef::Provider::SymfonyPermission::Setfacl
    world_writable_dirs.push('web/media/thumbnails')
    action [:deploy, :set_permissions]
    notifies :run, 'app_console[assetic-dump]'
end

app_console "assetic-dump" doo
   app '/path/to/project/current'
   command 'assetic:dump --force'
   console 'php bin/console' # If you are using Symfony 3.0 directory structure.
   user node[:deploy_user]
   group node[:deploy_group]
   action :nothing
end

```

License and Authors
===================

Author: Bez Hermoso <bez@activelamp.com>

Author: ActiveLAMP

Copyright: 2012-2014, ActiveLAMP

[Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0.html)
