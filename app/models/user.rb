class User < ApplicationRecord
  has_based_uuid prefix: :usr

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { admin: 0, teacher: 1, student: 2 }

  validates :first_name, :last_name, :role, presence: true
  validates :email, presence: true, uniqueness: true

  has_many :documents

  def generate_jwt
    JWT.encode(
      { 
        id: id, 
        email: email,
        exp: 30.days.from_now.to_i
      },
      Rails.application.credentials.secret_key_base
    )
  end

  def attributes
    super.merge(role: role.humanize)
  end
end
