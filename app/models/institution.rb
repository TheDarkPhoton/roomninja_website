class Institution < ActiveRecord::Base
  has_many :rooms, dependent: :destroy
  has_many :users, dependent: :destroy

  before_save { self.domain = self.domain.downcase }
  before_save { self.data = self.data.downcase }

  validates :name, presence: true

  VALID_DOMAIN_REGEX = /\A\w+(\.|-)(\w+(\.|-))*\w+\z/i

  validates :domain, {
    presence: true,
    format: { with: VALID_DOMAIN_REGEX },
    uniqueness: { case_sensitive: false }
  }

  validates :data, presence: true
end
