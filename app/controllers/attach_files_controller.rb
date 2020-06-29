class AttachFilesController < ApplicationController
  protect_from_forgery :except => [:upload]
  layout "admin"

  def index
    @attach_files = AttachFile.order("created_at DESC").page(params[:page])
    render :index
  end
  def show
  end
  def destroy
    p params.to_s
    @attach_file = AttachFile.find(params[:id])
    @attach_file.destroy
    respond_to do |format|
      format.html {
        redirect_to action: :index
      }
      format.json {
        render json: { code: 0 }
      }
    end
  end
  def upload
    id, content_type, code = upload_attach_file(params[:attach_file], params[:obj_id], params[:obj_class])
    render json: { id: id, content_type: content_type, code: code }
  end
  def icon
    @attach_file = AttachFile.find(params[:id])
    disposition = params[:disposition] ? params[:disposition] : 'inline'

    send_data(@attach_file.thumb, {
                filename: @attach_file.name,
                type: 'image/png',
                disposition: disposition })
  end
  def download
    @attach_file = AttachFile.find(params[:id])
    disposition = params[:disposition] ? params[:disposition] : 'inline'
    send_data(@attach_file.body, {
                filename: @attach_file.name,
                type: @attach_file.content_type,
                disposition: disposition })
  end
end
