class NestsController < ApplicationController
  def index
    case params[:type]
    when 'member'
      @nests = []
      NestMember.where(user: current_user).each do | nest_member |
        @nests << nest_member.nest
      end
    when nil, 'all'
      @nests = Nest.where(join_method: Nest::JoinMethod::FREE_JOIN)
    end
  end

  def show
    @nest = Nest.find(params[:id])
    if ( @nest.visible?(current_user) )
      render
    else
      redirect_to_404
    end
  end

  def new
    @nest = Nest.new
  end

  def edit
    @nest = Nest.find(params[:id])
  end

  def create
    nest = params.require(:nest).
      permit(:title, :description, :icon_image, :publication_level, :preparation_level, :join_method)
    nest.delete(:icon_image)
    @nest = Nest.new(nest)
    @nest.owner_id = current_user.id
    @attach = _create_icon(@nest,
                           params[:nest][:icon_image],
                           params[:icon_x],
                           params[:icon_y],
                           params[:icon_width],
                           params[:icon_height]
                          )
    if @attach
      @nest.icon_image_id = @attach.id
    end
    @nest.design = NestTop.create
    @nest.save
    @nest_member = NestMember.new(
                                  user: current_user,
                                  nest: @nest,
                                  inviter: current_user,
                                  display_name: current_user.default_display_name,
                                  board: true)
    @nest_member.save
    redirect_to edit_nest_path(@nest)
  end

  def invite
    session[:addresses] ||= ''
    @nest = Nest.find(params[:id])
    if ( @nest.invitable?(current_user) )
      render
    else
      redirect_to_404
    end
  end
  def invite_update
    @nest = Nest.find(params[:id])

    addresses = params[:addresses]
    session[:addresses] = addresses

    address_list = []
    addresses.split(/\s*\,\s*|\s+|\r\n/).each do | address |
      address.gsub!(/\s+/, '')
      if (( address != '' ) &&
          ( address =~ /.+@.+/ ))
        if ( address =~ /\<(.+)\>/ )
          address_list << $1
        else
          address_list << address
        end
      end
    end

    address_list.each do | address |
      if ( @nest.enrollable?(address) )
        invite = Invite.where(to_mail: address,
                              nest: @nest).first
        unless ( invite )
          invite = Invite.create(inviter: current_user,
                                 to_mail: address,
                                 nest: @nest)
        end
      end
    end
    redirect_to :invite_nest
  end
  def invite_send
    @nest = Nest.find(params[:id])
    @invite = Invite.find(params[:invite])
    NestInvitationMailMailer.with(invite: @invite).nest_invitation_mail.deliver_later
    @invite.mail_sent_at = Time.now
    if ( @invite.save )
      flash[:success] = 'invitation mail sent'
    else
      flash[:danger] = 'invitation mail fail'
    end

    redirect_to :invite_nest
  end
  def invite_destroy
    @nest = Nest.find(params[:id])
    @invite = Invite.find(params[:entry])
    @invite.destroy

    redirect_to :invite_nest
  end



  def join
    if ( params[:token] )
      @invite = Invite.where(invitation_token: params[:token]).first
      if ( @invite )
        @nest = @invite.nest
      end
    elsif ( params[:id] )
      @nest = Nest.find(params[:id])
    end
  end
  def do_join
    @nest = Nest.find(params[:id])
    if ( params[:token] )
      @invite = Invite.where(invitation_token: params[:token]).first
      if (( @invite ) &&
          ( @invite.nest == @nest ))
        @nest.join(current_user, @invite.inviter, params[:display_name])
        if ( !current_user.mail_owner?(@invite.to_mail) )
          current_user.append_mail(@invite.to_mail)
        end
        @invite.destroy

        redirect_to @nest
      else
        redirect_to_404
      end
    else
      if ( @nest.joinable?(current_user) )
        @nest.join(current_user, nil, params[:display_name])
        flash[:success] = t('nests.join_OK')
      else
        flash[:danger] = t('nests.already_joined')
      end
      redirect_to @nest
    end
  end
  def resign
    @nest = Nest.find(params[:id])
  end
  def do_resign
    @nest = Nest.find(params[:id])
    @nest.resign(current_user)
    flash[:success] = t("nests.resigned", name: @nest.title)

    redirect_to @nest
  end

  def member_control
    @nest = Nest.find(params[:id])
  end
  def ban
    @nest = Nest.find(params[:id])
    @member = NestMember.find(params[:member])
    @member.destroy

    redirect_to nest_member_control_path(@nest)
  end
  def member_board
    p params
    @nest = Nest.find(params[:id])
    @member = NestMember.find(params[:member])
    @member.board = params[:board] == "true" ? true : false
    @member.save
  end

  def update
    @nest = Nest.find(params[:id])
    nest = params.require(:nest).
      permit(:title, :description, :icon_image, :publication_level, :preparation_level, :join_method)
    nest.delete(:icon_image)

    @nest.attributes = nest
    if ( params[:nest][:icon_deleted] &&
         params[:nest][:icon_deleted] == "true")
      @nest.icon_image_id = nil
    end
    @attach = _create_icon(@nest,
                           params[:nest][:icon_image],
                           params[:icon_x],
                           params[:icon_y],
                           params[:icon_width],
                           params[:icon_height]
                          )
    if @attach
      @nest.icon_image_id = @attach.id
    end
    @nest.save

    redirect_to edit_nest_path(@nest)
  end

  # DELETE /foos/1
  # DELETE /foos/1.json
  def destroy
    @foo.destroy
    respond_to do |format|
      format.html { redirect_to foos_url, notice: 'Foo was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

end
