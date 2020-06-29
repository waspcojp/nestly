# -*- coding: utf-8 -*-
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

begin
  pg = EndpointProgram.find(1)
  pg.save!
rescue ActiveRecord::RecordNotFound
  EndpointProgram.create(
                         title: "ES形式をlogに格納する",
                         name: "OriginalLog",
                         publication: EndpointProgram::Publication::OPEN,
                         reviewed_at: Time.now
                         )
end
