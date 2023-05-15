# frozen_string_literal: true

class Post < ApplicationRecord
  belongs_to :author, class_name: 'User', foreign_key: :author
  belongs_to :reviewer, class_name: 'User', foreign_key: :reviewer
end
