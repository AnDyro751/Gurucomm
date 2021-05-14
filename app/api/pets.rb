# frozen_string_literal: true
include CreateNextUrl
module Pets
  ##
  # This class mount a Pets api
  class API < Grape::API
    helpers do
      # @param [String] status
      # @param [String] message
      # @return [Error]
      def render_error(status, message)
        error!({
                   status: status,
                   message: message,
               }, status)
      end

      # @return [ActionController::Parameters]
      def pet_params
        ActionController::Parameters.new(params).require(:pet).permit(:name, :tag)
      end

    end
    rescue_from :all, rescue_subclasses: false do |e|
      error_class = e.class.to_s
      case error_class
      when "ActiveRecord::RecordNotFound"
        render_error(404, e.message)
      when "ActiveRecord::RecordInvalid"
        render_error(422, e.message)
      when "ActionController::ParameterMissing"
        render_error(400, "Param is missing")
      else
        render_error(500, e.message)
      end
    end
    resource :pets do
      desc 'Find pet by id'
      params do
        optional :limit, type: Integer, desc: 'Limit of records to show'
        optional :page, type: Integer, desc: 'Page for pagination'
      end
      # @return [ActiveRecord::Relation<Pet>]
      get do
        page = params[:page].nil? ? 1 : params[:page]
        limit = params[:limit].nil? ? 30 : params[:limit]
        render_error(400, 'Max limit is 100') if limit > 100
        render_error(400, 'Minimum limit is 1') if limit <= 0
        render_error(400, 'Minimum page is 1') if page <= 0

        records = Pet.all.paginate(per_page: limit, page: page)
        header 'X-Next', create_next_url(request.url, records.next_page)
        present records, with: API::Entities::Pet
      end

      desc 'Info for a specific pet'
      params do
        requires :id
      end
      # @return [Pet]
      route_param :id do
        get do
          present Pet.find(params[:id]), with: API::Entities::Pet
        end
      end

      desc 'Create a pet'
      post do
        @pet = Pet.new(pet_params)
        if @pet.save!
          status 201
          present @pet, with: API::Entities::Pet
        else
          render_error(422, @pet.errors.full_message)
        end
      end

    end
  end
end

