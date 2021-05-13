require 'spec_helper'
require 'rails_helper'
require "rack/test"
OUTER_APP = Rack::Builder.parse_file("config.ru").first
describe API do
  include Rack::Test::Methods

  def app
    OUTER_APP
  end

  context 'GET /api/pets' do
    it 'returns an empty array of pets' do
      get '/api/pets'
      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body).length).to eq(0)
    end
  end


  context 'GET /api/pets' do
    before(:all) do
      create(:pet)
    end
    it 'return one element of pets' do
      get '/api/pets'
      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body).length).to eq(1)
    end

  end

end