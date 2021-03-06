class Mission < ApplicationRecord
  validates :title,
    presence: true,
    length: { in: 1..200 }
  validates :contact_first_name,
    presence: true,
    length: { maximum: 50 }
  validates :contact_last_name,
    presence: true,
    length: { maximum: 50 }
  validates :contact_phone,
    presence: true,
    numericality: true,
    length: { minimum: 8, maximum: 15 }
  validates :description,
    presence: true,
    length: { minimum:100, maximum: 10000 }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :date_validation
  validates :volunteers_needed,
    presence: true,
    numericality: { only_integer: true, greater_than: 0 }


  belongs_to :organisation

  has_one :address, as: :addressable, dependent: :destroy
  has_one_attached :cover, dependent: :destroy

  has_many :participations
  has_many :users, through: :participations

  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings


  accepts_nested_attributes_for :address


  def self.search(search, location, date)
    if search.present? && location.present? && date.present?
      tag = Tag.find_by(name: search)
      address = Address.find_by(city: location.strip.capitalize)
      search_date= date.to_date
      if address.present?
        Mission.all.select{|m| m if m.tags.any? {|t| t.name == tag.name} && m.address.city.downcase == address.city.downcase && m.start_date.to_date >= search_date}
      else
        Mission.all
      end
    elsif search.present? && location.blank? && date.present?
      tag = Tag.find_by(name: search)
      search_date= date.to_date
      Mission.all.select{|m| m if m.tags.any? {|t| t.name == tag.name} && m.start_date.to_date >= search_date}
    elsif search.present? && location.blank? && date.blank?
      tag = Tag.find_by(name: search)
      Mission.all.select{|m| m if m.tags.any? {|t| t.name == tag.name}}
    elsif search.blank? && location.present? && date.present?
      address = Address.find_by(city: location.strip.capitalize)
      search_date= date.to_date
      if address.present?
        Mission.all.select{|m| m if m.address.city.downcase == address.city.downcase && m.start_date.to_date >= search_date}
      else
        Mission.all
      end
    elsif search.blank? && location.present? && date.blank?
      address = Address.find_by(city: location.strip.capitalize)
      if address.present?
        Mission.all.select{|m| m if m.address.city.downcase == address.city.downcase}
      else
        Mission.all
      end
    elsif search.blank? && location.blank? && date.present?
      search_date= date.to_date
      Mission.all.select{|m| m if m.start_date.to_date >= search_date}
    elsif search.present? && location.present? && date.blank?
      tag = Tag.find_by(name: search)
      address = Address.find_by(city: location.strip.capitalize)
      if address.present?
        Mission.all.select{|m| m if m.tags.any? {|t| t.name == tag.name} && m.address.city.downcase == address.city.downcase}
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

  private

  def date_validation
    if self[:end_date] < self[:start_date]
      errors[:end_date] << "La date de fin doit être après la date de début"
      return false
    else
      return true
    end
  end

end
