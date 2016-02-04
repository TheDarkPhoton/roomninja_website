# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Institution.new(name: "King's College London (University)", domain: 'kcl.ac.uk', data: 'http://www.inf.kcl.ac.uk/staff/andrew/rooms/allrooms.json').save

default = User.new(email: 'dovydas.rupsys', domain: 'kcl.ac.uk', password: 'password', password_confirmation: 'password')
default.save

Institution.find_by(domain: default.domain).users << default

RoomJob.new.perform