# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Institution.new(name: "King's College London (University)", domain: 'kcl.ac.uk', data: 'http://www.inf.kcl.ac.uk/staff/andrew/rooms/allrooms.json').save
RoomJob.new.perform