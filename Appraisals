# require 'json'
# require 'open-uri'
# require 'bundler/setup'
# require 'version'

# # puts "----> Fetching Rails versions..."
# open('https://rubygems.org/api/v1/versions/rails.json') do |json|
#   versions = JSON.load(json).map do |rails_version|
#     Version.new(*rails_version['number'].split('.'))
#   end

#   # Reject prerelease versions and anything pre 2.3.1
#   @versions = versions.sort.reject(&:prerelease?).reject { |version| version < Version.new(2,3,13) || version.revision.to_i <= 2 }
# end

# # ALL THE Rails

@versions = %w(3.2.9 3.1.8 3.0.17 2.3.14)

@versions.each do |version|
  # puts "    - Writing appraisal for Rails #{version.to_s}"
  appraise "rails_#{version.to_s.split('.')[0,2].join('_')}" do
    gem "rails", version.to_s
  end
end
