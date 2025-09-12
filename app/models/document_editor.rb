# frozen_string_literal: true

class DocumentEditor < ApplicationRecord
  belongs_to :document
  belongs_to :user

  enum :role, { viewer: 0, editor: 1 }

  validates :role, presence: true
  validates :role, inclusion: { in: roles.keys }

  def attributes
    super.merge(role: role.humanize)
  end
end
