class MissionsController < ApplicationController
  before_action :set_mission, only: [:show]

  def index
      @missions = Mission.search(params[:search])
  end

  def show
    @missions=Mission.all
  end


  private

  def set_mission
    @mission = Mission.find(params[:id])
  end

  def mission_params
    param.require(:mission).permit(:search, :organisaion_id, :title, :tags)
  end

end
