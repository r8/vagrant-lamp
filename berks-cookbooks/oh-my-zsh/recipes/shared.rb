git "/usr/src/oh-my-zsh" do
  repository "https://github.com/robbyrussell/oh-my-zsh.git"
  reference "master"
  action :sync
end

search( :users, "shell:*zsh" ).each do |u|
  user_id = u["id"]

  theme = data_bag_item( "users", user_id )["oh-my-zsh-theme"]

  link "/home/#{user_id}/.oh-my-zsh" do
    to "/usr/src/oh-my-zsh"
    not_if "test -d /home/#{user_id}/.oh-my-zsh"
  end

  template "/home/#{user_id}/.zshrc" do
    source "zshrc.erb"
    owner user_id
    group user_id
    variables( :theme => ( theme || node[:ohmyzsh][:theme] ))
    action :create_if_missing
  end
end
