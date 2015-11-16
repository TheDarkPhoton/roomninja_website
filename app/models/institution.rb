class Institution < ActiveRecord::Base
  has_many :rooms, dependent: :destroy
  has_many :users, dependent: :destroy

  validates :name, presence: true
  validates :domain, presence: true
  validates :data, presence: true
end
