class CommentsController < ApplicationController
  def create
    @entry = Entry.find(params[:entry])
    if ( @entry )
      comment = params.require(:comment).permit(:body);

      @comment = Comment.new(comment)
      @comment.author = current_user
      @comment.entry = @entry
      @entry.comment_count += 1
      @comment.number = @entry.comment_count
      @comment.save

      params[:comment].each do | key, attach |
        if ( key =~ /^attach_file_/ )
          upload_attach_file(attach, @comment)
        end
      end
      @entry.save

      redirect_to entry_path(@entry,anchor: "comment", from:-10)
    end
  end
  def destroy
    @comment = Comment.find(params[:id])
    @comment.deleted_at = Time.now
    @comment.deleted_by = current_user
    @comment.save
    @entry = @comment.entry
    render json: {}
#    redirect_to entry_path(@entry, from:params[:from], to:params[:to], count: params[:count])
  end
end
