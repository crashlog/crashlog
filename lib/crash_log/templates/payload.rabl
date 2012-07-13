object @payload

attribute :notifier
attribute :exception


# node(:exception) do |payload|
#   node(:message) { payload.exception[:message] }
# end

# child :exception do
#   attribute :timestamp
#   # extends 'exception', @payload.exception
# end

# child :environment do
#   extends 'environment'
# end
#
# child :session do
#   extends 'session'
# end
#
# attribute :user_data
