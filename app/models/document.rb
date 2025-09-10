class Document < ApplicationRecord
  include PageViewable

  belongs_to :author, class_name: "User", foreign_key: "user_id"

  has_many :document_editors, dependent: :destroy
  has_many :editors, through: :document_editors, source: :user

  has_one_attached :file

  validates :title, presence: true

  has_paper_trail

  def attributes
    super.merge(
      editors: editors.map(&:attributes),
      can_view: file.content_type == "text/markdown",
      page_view_count: page_view_count
    )
  end
end
