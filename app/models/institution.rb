class Institution < ActiveRecord::Base
  has_many :rooms, dependent: :destroy
  has_many :users, dependent: :destroy

  before_save :default_values, if: :domain_or_data_changed?

  validates :name, presence: true

  VALID_DOMAIN_REGEX = /\A\w+(\.|-)(\w+(\.|-))*\w+\z/i

  validates :domain, {
    presence: true,
    format: { with: VALID_DOMAIN_REGEX },
    uniqueness: { case_sensitive: false }
  }

  validates :data, presence: true

  private

  def default_values
    self.domain = self.domain.downcase
    self.data = self.data.downcase
  end

  def domain_or_data_changed?
    self.domain_changed? || self.data_changed?
  end
end
