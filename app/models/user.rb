class User < ApplicationRecord
  include ApplicationHelper

  include PgSearch::Model

  pg_search_scope :search, against: [:first_name, :last_name, :email], using: { trigram: { threshold: 0.1 } }

  has_based_uuid prefix: :usr

  has_one_attached :avatar

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { admin: 0, teacher: 1, student: 2 }

  validates :first_name, :last_name, :role, presence: true
  validates :email, presence: true, uniqueness: true

  has_many :documents
  has_many :page_views, dependent: :destroy
  has_many :document_editors, dependent: :destroy
  has_many :shared_documents, through: :document_editors, source: :document

  after_create :generate_avatar

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
    super.merge(role: role.humanize, avatar_url: avatar_url)
  end

  def avatar_url
    cdn_for(self.avatar)
  end

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  private

  def generate_avatar
    new_avatar_path = LetterAvatar.generate(full_name, 200)
    
    self.avatar.attach(io: File.open(new_avatar_path), filename: "#{full_name.parameterize}_#{self.id}.png")

    self.save
  end
end
