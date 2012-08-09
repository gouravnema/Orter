class RetrosController < ApplicationController

  def new
    @user = current_user
  end

  def create
    @retro = Retro.new({:name => CGI.escapeHTML(params[:name]), :description => CGI.escapeHTML(params[:description])})

    params[:numberOfSections].to_i.times do |section_number|
      section_name = ("sectionname"+section_number.to_s)
      @retro.sections << Section.new({:name => CGI.escapeHTML(params[section_name])})
    end
    @retro.users = [current_user] if current_user

    if @retro.save
      flash[:notice] = 'Retro was successfully created.'
      redirect_to :controller => :retros, :action => :show, :id => @retro.id.to_s, :name => @retro.name
    else
      render new
    end
  end

  def show
    @retrospective = Retro.find_by_id_and_name(params[:id], params[:name], :include => :sections)
    add_current_user(@retrospective)
    render :action => :show
  end

  def show_old
    @retrospective = Retro.find_by_name(params[:name], :include => :sections)
    add_current_user(@retrospective)
    render :action => :show
  end

  def export
    @retro = Retro.find(params[:id])
    headers["Content-Disposition"] = "attachment; filename=\"#{@retro.name}.#{params[:format]}\""
    respond_to do |format|
      format.pdf { render :layout => false } if params[:format] == 'pdf'
      format.xls { render :layout => false } if params[:format] == 'xls'
    end
  end

  private
  def add_current_user(retrospective)
    retrospective.users ||= []
    retrospective.users << current_user unless current_user.nil? or retrospective.users.include?(current_user)
  end


end
