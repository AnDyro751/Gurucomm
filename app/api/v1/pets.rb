# frozen_string_literal: true
include CreateNextUrl
module V1

  ##
  # This class mount a Pets api
  class Pets < Grape::API
    format :json
    prefix :api
    helpers do
      # @return [Error]
      # @param [String] status
      # @param [String] message
      def render_error(status, message)
        error!({
                   status: status,
                   message: message,
               }, status)
      end
    end
    rescue_from :all, rescue_subclasses: false do |e|
      error_class = e.class.to_s
      if error_class == "NameError"
        render_error(500, e.message)
      elsif error_class == "ActiveRecord::RecordNotFound"
        render_error(404, e.message)
      elsif error_class == "ActiveRecord::RecordInvalid"
        render_error(422, e.message)
      else
        render_error(500, e.message)
      end
    end
    namespace :v1 do
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
      end
    end
  end
end

