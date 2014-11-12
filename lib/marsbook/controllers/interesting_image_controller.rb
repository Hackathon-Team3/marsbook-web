require_relative "../models/interesting_image"

module Marsbook
  module Controllers
    class InterestingImageController

      def self.next_image
        Models::InterestingImage.first! || "foo"
      end
    end
  end
end
