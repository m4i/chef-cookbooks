require 'chef/provider/user/useradd'
require 'chef/resource/user'

class ::Chef
  class Resource
    class User
      def groups(arg = nil)
        set_or_return(
          :groups,
          arg,
          :kind_of => [ String ]
        )
      end unless method_defined?(:groups)
    end
  end
end

unless ::Chef::Provider::User::Useradd::UNIVERSAL_OPTIONS.assoc(:groups)
  ::Chef::Provider::User::Useradd::UNIVERSAL_OPTIONS << [:groups, '-G']
end
