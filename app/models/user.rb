class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :omniauthable, :omniauth_providers => [:google_oauth2, :microsoft_graph_auth]

  has_many :events

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(:email => data["email"]).first

    unless user
      user = User.create(
        name: data["name"],
        email: data["email"],
        encrypted_password: Devise.friendly_token[0, 20],
      )
    end
    user
  end

  def self.from_omniauth_microsoft(access_token)
    data = access_token.extra.raw_info
    user = User.where(:email => data["userPrincipalName"]).first

    unless user
      user = User.create(
        name: data["diplayName"],
        email: data["userPrincipalName"],
        encrypted_password: Devise.friendly_token[0, 20],
      )
    end
    user
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.google_data"] && session["devise.google_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end
end
