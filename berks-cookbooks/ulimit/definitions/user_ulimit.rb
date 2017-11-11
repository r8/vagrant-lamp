# Defines a user_ulimit modification
# Sample:
#
# depends 'ulimit'
#
# user_ulimit "tomcat" do
#  filehandle_limit 8192
#  process_limit 61504
#  memory_limit 1024
# end

define :user_ulimit, :filehandle_limit => nil, :process_limit => nil, :memory_limit => nil, :stack_soft_limit => nil, :stack_hard_limit => nil, :filename => nil do

  filename = params[:filename]
  unless params[:filename]
   filename = case params[:name]
              when "*"
                "00_all_limits"
              else
                "#{params[:name]}_limits"
              end
  end

  template "/etc/security/limits.d/#{filename}.conf" do
    source "ulimit.erb"
    cookbook "ulimit"
    owner "root"
    group "root"
    mode 0644
    variables(
      :ulimit_user => params[:name],
      :filehandle_limit => params[:filehandle_limit],
      :filehandle_soft_limit => params[:filehandle_soft_limit],
      :filehandle_hard_limit => params[:filehandle_hard_limit],
      :process_limit => params[:process_limit],
      :process_soft_limit => params[:process_soft_limit],
      :process_hard_limit => params[:process_hard_limit],
      :memory_limit => params[:memory_limit],
      :core_limit => params[:core_limit],
      :core_soft_limit => params[:core_soft_limit],
      :core_hard_limit => params[:core_hard_limit],
      :stack_limit => params[:stack_limit],
      :stack_soft_limit => params[:stack_soft_limit],
      :stack_hard_limit => params[:stack_hard_limit]
    )
  end
end
