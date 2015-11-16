class User < ActiveRecord::Base
  attr_accessor :domain
  attr_accessor :remember_token

  before_save :default_values, unless: :persisted?

  belongs_to :institution
  has_many :booking_times, dependent: :destroy

  VALID_EMAIL_REGEX = /\A(“|”|\+|\-|\w)+\.?(“|”|\w)+\z/i
  VALID_DOMAIN_REGEX = /\A\w+(\.|-)(\w+(\.|-))*\w+\z/i

  validates :email, {
      length: { maximum: 255 },
      format: { with: VALID_EMAIL_REGEX },
      uniqueness: { case_sensitive: false },
      unless: :persisted?
  }

  validate :domain_validation

  has_secure_password
  validates :password, {
    length: { minimum: 6, maximum: 255 },
    allow_blank: true
  }

  def new_reset_token
    self.new_unique_token(:reset_token)
    self.reset_expire = 1.hours.from_now
    self.save
  end

  def nil_reset_token
    self.reset_token = nil
    self.reset_expire = nil
    self.save
  end

  def new_unique_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end

  private

  def domain_validation
    errors.add(:email, 'domain is invalid') unless domain =~ VALID_DOMAIN_REGEX
  end

  def default_values
    self.email += "@#{self.domain}"
    self.email = self.email.downcase
  end
end
