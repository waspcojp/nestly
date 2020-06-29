# -*- coding: utf-8 -*-
require_relative 'batch'
require 'json'

class SendMail < ActionMailer::Base
  def send_mail(param)
    @params = JSON.parse(param.render_params).symbolize_keys
    print param.render_file, "\n"
    out = ""
    File.open("#{Rails.root}/app/views/#{param.render_file}.html.erb") do | file |
      out = ERB::new(file.read).result(binding)
    end
    mail(to: param.to,
         from: param.from,
         subject: param.subject) do | format |
      format.text { render plain: out }
    end
  end
end
