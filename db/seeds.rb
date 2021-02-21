# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

batchsize = 100
500.times do |n|
  Student.create({
    school_code: "1001",
    school_cluster: "SOUTH 1",
    school_name: "SOUTH ISLAND PRIMARY SCHOOL",
    level: "P1",
    class_name: "P1-D",
    nric: "S1234567J",
    name: "STUDENT NAME #{"%04d" % (n + 1)}",
    contact: "88888888",
    status: Student.statuses[:pending],
    serial_no: "%04d" % (n + 1),
    batch: "SIPS %d" % (1 + (n / batchsize))
  })
end
