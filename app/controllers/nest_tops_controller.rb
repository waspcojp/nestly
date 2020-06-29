class NestTopsController < ApplicationController
  def edit
    @nest_tops = NestTops.find(params[:id])
  end
  def update
    nest_tops = params.require(:nest_top).
      permit(:max_update_entries, :max_spaces)
    @nest_tops = NestTop.find(params[:id])
    @nest_tops.attributes = nest_tops
    @nest_tops.save

    redirect_to nest_path(@nest_tops.nest)
  end
end
