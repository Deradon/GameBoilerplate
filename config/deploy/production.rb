set :domain,          '188.40.124.76'
set :user,            'deradon'
set :deploy_to,       "/home/deradon/public_html/#{application}"
set :port, 59023

role :app, "188.40.124.76", :primary => true
server domain, :app

