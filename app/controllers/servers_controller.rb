class ServersController < ApplicationController

  SRV_TMPL = "Server Templates"

  before_filter :get_environments, except: [:update, :create]
  before_filter :get_environment
  before_filter :get_server, only: [:edit, :update, :destroy]
  before_filter :get_tmpl, only: [:edit, :new]

  def new
  end

  def create
    @server = @environment.servers.new(server_params)
    @server[:java], @server[:oracle_client] = params[:server][:java], params[:server][:oracle_client]
    @server[:server_roles] = create_server_role_hash(params[:server][:server_roles])    
    if @server.save
      flash[:info] = "Server is added"
    else
      flash[:danger] = "Error during update"
    end

    redirect_to @environment
  end

  def edit
    if @server[:server_roles]
      @tmpl[:server_roles].each do |sr|
        role = @server[:server_roles].detect{|ssr| ssr[:name] == sr[:name]}
        sr[:parameters], sr[:assign] = role[:parameters], true if role
      end
    end
  end

  def update
    @server.update(server_params)
    @server[:java], @server[:oracle_client] = params[:server][:java], params[:server][:oracle_client]
    @server[:server_roles] = create_server_role_hash(params[:server][:server_roles])
    if @server.save
      flash[:info] = "Server is updated"
    else
      flash[:danger] = "Error during update"
    end
    
    redirect_to @environment
  end

  def destroy
    @server.destroy
    redirect_to @environment
  end

  private

    def get_environments
      @environments = Environment.all_asc_order
    end

    def get_environment
      @environment = Environment.find(params[:environment_id])
    end

    def get_server
      @server = @environment.get_server(params[:id])
    end

    def get_tmpl
      @tmpl = Setting.get_value_source_for_name(SRV_TMPL, "Base")

      unless @tmpl
        flash[:info] = "There is no server templates. Create One"
        redirect_to settings_path
      end
    end

    def server_params
      params.require(:server).permit(:name, :domain, :ip, :os, :ram, :cpu, :hdd, :ssh_user, :ssh_password)
    end

    def create_server_role_hash param_roles
      param_roles["Siebel Server"]["roles"] = param_roles["Siebel Server"]["roles"].split(" ")
      param_roles.map { |key, value| { name: key, parameters: value.except(:assoc) } if value[:assoc] } - [nil]
    end

end
