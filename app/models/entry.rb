class Entry < ActiveRecord::Base
  belongs_to :subscription
  belongs_to :user

  @dynamic_properties = Hash.new()

  def set_property(property, value)
    if (@dynamic_properties == nil)
      @dynamic_properties = Hash.new()
    end

    @dynamic_properties[property] = value
  end

  def get_property(property)
    if (@dynamic_properties == nil)
      @dynamic_properties = Hash.new()
    end

    @dynamic_properties[property]
  end

  def get_data()
    #if (id == nil)
    @data ={
        "entry" + subscription.sport.name.downcase => @dynamic_properties
    }
    #else
    #  @dynamic_properties
    #end
  end

  def self.save(save_info)
    if is_proxy == true
      super(save_info)
    else
      EntriesHelper.save_cy_ber_coach(self)
      super(save_info)
    end
  end


  def save
    if (is_proxy == true)
      if Entry.find_by(reference: self.reference) == nil
        super
      end
    else
      EntriesHelper.save_cy_ber_coach(self)
      if Entry.find_by(reference: self.reference) == nil
        if (self.subscription != nil)
          self.subscription = Subscription.find_by(reference: self.subscription.reference)
        end
        super
      end
    end
  end

  def delete
    EntriesHelper.delete_cy_ber_coach(self)
    if (self.subscription != nil)
      self.subscription = Subscription.find_by(reference: self.subscription.reference)
    end
    super
  end
end
