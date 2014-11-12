require "active_record"

module Marsbook
  module Models
    class InterestingImage < ActiveRecord::Base
      self.primary_key = 'url'
      validates :timestamp, presence: true
    end
  end
end
