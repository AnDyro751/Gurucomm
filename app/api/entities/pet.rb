module Entities
  class Pet < Grape::Entity
    expose :id, :name, :tag
  end
end
