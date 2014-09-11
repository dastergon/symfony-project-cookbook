require 'chef/provider'

class Chef
  class Provider
    class SymfonyProject < Chef::Provider
      def load_current_resource
        @current_resource ||= Chef::Resource::SymfonyProject.new(new_resource.name)
        
        @current_resource.destination(new_resource.destination)
        @current_resource.repo(new_resource.repo)
        @current_resource.revision(new_resource.revision)
        @current_resource.user(new_resource.user)
        @current_resource.group(new_resource.group)
        @current_resource.shared_web_dirs(new_resource.shared_web_dirs)
        @current_resource.ssh_wrapper(new_resource.ssh_wrapper)
        @current_resource.keep_releases(new_resource.keep_releases)
        @current_resource.shared_vendor(new_resource.shared_vendor)
        @current_resource.acl_method(new_resource.acl_method)
        @current_resource.web_user(new_resource.web_user)
        @current_resource.deploy_provider(new_resource.deploy_provider)

        @current_resource.run_context = new_resource.run_context
      end

      def action_deploy
        converge_by("Deploying #{ @current_resource.repo }@#{ @current_resource.revision } to #{ @current_resource.destination }") do
          deploy(:deploy)
        end
      end

      def action_revision
        converge_by("Revising #{ @current_resource.repo }@#{ @current_resource.revision } to #{ @current_resource.destination }") do
          deploy(:revision)
        end
      end

      def deploy(run_action)

        shared_dirs = %w(logs cache)
        shared_dirs.push(*@current_resource.shared_web_dirs)
        if @current_resource.shared_vendor
          shared_dirs.push('vendor')
        end

        for dir in shared_dirs
          directory = Chef::Resource::Directory.new(@current_resource.destination + '/shared/' + dir, @current_resource.run_context)
          directory.recursive(true)
          directory.user(@current_resource.user)
          directory.group(@current_resource.group)
          directory.mode('0755')
          directory.provider(Chef::Provider::Directory)
          directory.run_action(:create)
        end

        deploy = Chef::Resource::Deploy.new(@current_resource.destination, @current_resource.run_context)
        deploy.repo(@current_resource.repo)
        deploy.revision(@current_resource.revision)
        deploy.user(@current_resource.user)
        deploy.group(@current_resource.group)
        deploy.provider(@current_resource.deploy_provider)
        deploy.group(@current_resource.group)
        deploy.git_ssh_wrapper(@current_resource.ssh_wrapper)
        deploy.symlink_before_migrate.clear
        deploy.create_dirs_before_symlink.clear
        deploy.purge_before_symlink(['app/logs', 'app/cache'])
        deploy.purge_before_symlink.push(*@current_resource.shared_web_dirs)

        symlinks = {
           'logs' => 'app/logs',
           'cache' => 'app/cache'
        }

        if @current_resource.shared_vendor
          deploy.purge_before_symlink.push('vendor')
          symlinks['vendor'] = 'vendor'
        end

        for dir in @current_resource.shared_web_dirs
          symlinks[dir] = dir
        end

        deploy.symlinks(symlinks)
        deploy.run_action(run_action)

      end
    end
  end
end