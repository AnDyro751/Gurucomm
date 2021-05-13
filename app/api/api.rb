class API < Grape::API
  prefix '/pets'
  mount V1::Pets
end
