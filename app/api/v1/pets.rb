# frozen_string_literal: true

module V1

  ##
  # This class mount a Pets api
  class Pets < Grape::API
    format :json
    prefix :api

    namespace :v1 do
      resource :pets do
        desc 'Find pet by id'
        params do
          requires :limit, type: Integer, desc: 'Limit of records to show'
        end
        # @return [ActiveRecord::Relation<Pet>]
        get do
          error!('limit is missing') if params[:limit].nil?
          error!('Max limit is 100') if params[:limit] > 100
          error!('Minimum limit is 1') if params[:limit] <= 0
          Pet.all.limit(params[:limit])
        end
      end
    end
  end
end

