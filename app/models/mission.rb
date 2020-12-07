class Mission < ApplicationRecord
  belongs_to :organisation

  has_one :address, as: :addressable, dependent: :destroy

  has_many :participations
  has_many :users, through: :participations

  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings

  has_one_attached :cover
  has_many_attached :images

  accepts_nested_attributes_for :address


  def self.search(search)
    if search
      tag = Tag.find_by(name: search)
      if tag
        Mission.all.select{|m| m if m.tags.any? {|t| t.name == tag.name}}
      else
        Mission.all
      end
    else
      Mission.all
    end
  end

  def self.street(id)
    Mission.find(id).address.street.split(" ").flat_map { |x| [x, "%20"] }[0...-1].join(" ")
  end

end
