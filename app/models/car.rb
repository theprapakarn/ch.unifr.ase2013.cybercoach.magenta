class Car < ActiveRecord::Base
  belongs_to :user
  has_many :bids, dependent: :destroy
  validates :user_id, :brand, :model, presence: true
  default_scope -> { order('created_at DESC') }
  validates_numericality_of :price, only_decimal: true, allow_blank: false

  def self.search(search)
    if search
      where('LOWER(model) LIKE ? OR LOWER(brand) LIKE ?', "%#{search.downcase}%", "%#{search.downcase}%" ).order("created_at DESC")
     else
      find(:all, :order => 'created_at  desc')
    end
  end

end
