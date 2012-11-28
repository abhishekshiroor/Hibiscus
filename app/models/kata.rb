require 'indextank'
require "searchify"

# Kata represents the exercises to improve the software craftsmanship.
# Kata operations are managed by PostController because they share many operations and information in common.

class Kata
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning
  #paranoia module allows to implement "soft deletion"
  include Mongoid::Paranoia
  include Mongoid::Slug
  include Searchify

  belongs_to :category

  attr_accessor :tempTags

  field :title, :type => String
  field :content, :type => String
  field :source, :type => String
  field :rating, :type => Float, default: 0.0

  field :challenge_level, :type => String
  field :user_categories, :type => String

  slug :title

  embeds_many :reviews
  #both teams decide to remove it
  #references_many :likes, :dependent => :destroy
  has_and_belongs_to_many :tags
  referenced_in :user

  validates :title, :presence => true
  validates :content, :presence => true
  validates :user_id, :presence => true
  # challenge_level can be "low", "medium", "high"
  validates :challenge_level, presence: true, inclusion: { in: %w(Low Medium High) }
  # a kata must have one and only one category
  validates :category, presence: true

  after_save :update_search_index
  before_destroy :delete_from_search_index

  def survived_reviews
    reviews.where(:deleted_at.exists => false)
  end

  # get user proposal categories for a kata
  def kata_user_categories
      kataUserCategories = []
      survived_reviews.each do |review|
        review.category_ids.each {|category_id| kataUserCategories << category_id}
      end
      kataUserCategories.uniq
  end
end