# frozen_string_literal: true
include CreateNextUrl
module V1

  ##
  # This class mount a Pets api
  class Pets < Grape::API
    format :json
    prefix :api
    # error_formatter :json, ->(message, backtrace, options, env, original_exception) {
    #   {error: message}
    # }
    # error_formatter :json, JsonErrorFormatter
    rescue_from :all, rescue_subclasses: false do |e|
      error!({
                 status: e.status,
                 message: e.message,
             }, e.status)
    end
    namespace :v1 do
      resource :pets do
        desc 'Find pet by id'
        params do
          requires :limit, type: Integer, desc: 'Limit of records to show'
          optional :page, type: Integer, desc: 'Page for pagination'
        end
        # @return [ActiveRecord::Relation<Pet>]
        get do
          page = params[:page].nil? ? 1 : params[:page]
          error!({code: 400, message: 'Limit is missing'}, 400) if params[:limit].nil?
          error!({code: 400, message: 'Max limit is 100'}, 400) if params[:limit] > 100
          error!({code: 400, message: 'Minimum limit is 1'}, 400) if params[:limit] <= 0
          error!({code: 400, message: 'Minimum page is 1'}, 400) if page <= 0
          records = Pet.all.paginate(per_page: params[:limit], page: page)
          header 'X-Next', create_next_url(request.url, records.next_page)
          records
        end
      end
    end
  end
end

