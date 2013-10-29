class Entry < ActiveRecord::Base
  belongs_to :subscription

  def save()
    if self.is_proxy
      #if Entry.find_by(reference: self.reference) == nil
        #super
      #end
    else
      EntriesHelper.save_cy_ber_coach(self)
      #if Entry.find_by(reference: self.reference) == nil
        #super
      #end
    end
  end
end
