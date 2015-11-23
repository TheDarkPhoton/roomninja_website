class UserReset
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks

  before_validation :default_values

  attr_accessor :email, :user

  VALID_EMAIL_REGEX = /\A(“|”|\+|\-|\w)+\.?(“|”|\w)+@\w+(\.|-)(\w+(\.|-))*\w+\z/i
  validates :email, {
      length: { maximum: 255 },
      format: { with: VALID_EMAIL_REGEX },
      presence: true
  }

  validate :user_exists

  def initialize(attributes = {})
    super(attributes)
    init_values
  end

  def form_name
    'User reset'
  end

  private

  def init_values
  end

  def default_values
    self.user = User.find_by(email: self.email)
  end

  def user_exists
    if self.user.nil?
      errors.add(:email, 'User with this email does not exist')
    end
  end
end