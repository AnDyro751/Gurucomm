# frozen_string_literal: true
include CreateNextUrl
module V1

  ##
  # This class mount a Pets api
  class Pets < Grape::API
    format :json
    prefix :api
    # rescue_from ActiveRecord::RecordNotFound, rescue_subclasses: false do |e|
    # end
    rescue_from :all, rescue_subclasses: false do |e|
      # puts "#{e}"
      error_class = e.class.to_s
      if error_class == "NameError"
        error!({
                   status: 500,
                   message: e,
               }, 500)
      elsif error_class == "ActiveRecord::RecordNotFound"
        error!({
                   status: 404,
                   message: e.message,
               }, 404)
      elsif error_class == "ActiveRecord::RecordInvalid"
        error!({
                   status: 422,
                   message: e.message,
               }, 422)
      else
        error!({
                   status: e.status,
                   message: e.message,
               }, e.status)
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
          page = params[page].nil? ? 1 : params[:page]
          limit = params[:limit].nil? || params[:limit] <= 0 ? 30 : params[:limit]
          error!({code: 400, message: 'Max limit is 100'}, 400) if limit > 100
          error!({code: 400, message: 'Minimum limit is 1'}, 400) if limit <= 0
          error!({code: 400, message: 'Minimum page is 1'}, 400) if page <= 0
          records = Pet.all.paginate(per_page: limit, page: page)
          header 'X-Next', create_next_url(request.url, records.next_page)
          records
        end

        desc 'Info for a specific pet'
        params do
          requires :id
        end
        # @return [Pet]
        route_param :id do
          get do
            Pet.find(params["id"])
          end
        end
      end
    end
  end
end

