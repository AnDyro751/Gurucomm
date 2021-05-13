class API < Grape::API
  include GrapeRouteHelpers::NamedRouteMatcher
  prefix '/api'
  format :json
  mount ::Pets::API
end
