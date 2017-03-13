class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :omniauthable

  validates :name, presence: true, length: { maximum: 25 }

  has_many :subscriptions
  has_many :projects, through: :subscriptions

  has_many :reviews

  def self.find_for_facebook_oauth(access_token, _signed_in_resourse = nil)
    data = access_token.info
    user = User.where(provider: access_token.provider, uid: access_token.uid).first

    if user
      return user
    else
      registered_user = User.where(email: data.email).first
      if registered_user
        return registered_user
      else
        user = User.create(
          name: access_token.extra.raw_info.name,
          provider: access_token.provider,
          email: data.email,
          uid: access_token.uid,
          image: data.image,
          password: Devise.friendly_token[0, 20]
        )
      end
    end
  end
end
