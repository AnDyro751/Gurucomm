class API < Grape::API
  include GrapeRouteHelpers::NamedRouteMatcher
  prefix '/pets'
  mount V1::Pets

end
