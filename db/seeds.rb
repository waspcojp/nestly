# -*- coding: utf-8 -*-
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

begin
  user = User.find(1)
rescue
  user = User.create!(user_name: 'root',
                      password: 'rootroot',
                      password_confirmation: 'rootroot',
                      default_display_name: 'root')
end
design = NestTop.create!
nest = Nest.create!(owner: user,
                      title: 'メンバー用',
                      description: <<__NEST__,
会員のためのネストです
主に「お知らせ」のためにありますが、それ以外のスペースはサンドボックスとして使えます。
__NEST__
                      design: design,
                      join_method: Nest::JoinMethod::INVITE_BY_OWNER,
                      preparation_level: Nest::PreparationLevel::PRIVATE)
NestMember.create!(
                   nest: nest,
                   user: user,
                   display_name: 'root',
                   board: true)
space = Space.create!(creater: user,
                     nest: nest,
                     title: '運営からのお知らせ',
                     description: <<__SPACE__,
運営からのお知らせです。
__SPACE__
                     publication_level: Space::PublicationLevel::MEMBERS_ONLY,
                     preparation_level: Space::PreparationLevel::PRIVATE)
