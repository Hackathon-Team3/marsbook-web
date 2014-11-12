require "sinatra"
require "json"

require File.dirname(__FILE__) + "/lib/marsbook/startup"
require File.dirname(__FILE__) + "/lib/marsbook/controllers/interesting_image_controller"

Marsbook::Startup.initialize

get "/rover/images/new/?" do
  content_type "application/json"
  begin
    next_image = Marsbook::Controllers::InterestingImageController.next_image
    { captcha: "/images/captcha/new/", rover: next_image }.to_json
  rescue ActiveRecord::RecordNotFound
    halt 204
  end
end

get "/images/captcha/new/?" do
  content_type "image/png"
  send_file "public/images/captcha.png"
end

run Sinatra::Application