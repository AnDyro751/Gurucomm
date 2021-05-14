require 'spec_helper'
require 'rails_helper'
require "rack/test"
require "rspec/json_expectations"
OUTER_APP = Rack::Builder.parse_file("config.ru").first
describe API do
  include Rack::Test::Methods

  def app
    OUTER_APP
  end

  describe "POST /api/pets" do
    context "without pet params" do
      it 'return 500 status' do
        post "/api/pets"
        expect(last_response.status).to eq(400)
        expect(JSON.parse(last_response.body)).to include_json(status: 400, message: "Param is missing")
      end
    end

    context "with only name param" do
      let(:pet_name) { Faker::Name.first_name }
      it 'returns 201 status' do
        post "/api/pets", {pet: {name: pet_name}}
        expect(last_response.status).to eq(201)
        expect(JSON.parse(last_response.body)).to include_json(id: 1, name: pet_name, tag: nil)
      end
    end

    context "only with wrong parameters" do
      it 'return 422 status when pass incorrect param' do
        post "/api/pets", {pet: {demo: 1}}
        expect(last_response.status).to eq(422)
        expect(JSON.parse(last_response.body)).to include_json(status: 422, message: "Validation failed: Name can't be blank, Name is too short (minimum is 1 character)")
      end

      it 'return 422 status when pass empty name param' do
        post "/api/pets", {pet: {name: ""}}
        expect(last_response.status).to eq(422)
        expect(JSON.parse(last_response.body)).to include_json(status: 422, message: "Validation failed: Name can't be blank, Name is too short (minimum is 1 character)")
      end

      it 'return 500 status when pass invalid body' do
        post "/api/pets", {pet: {demo: ""}.to_s}
        expect(last_response.status).to eq(500)
        expect(JSON.parse(last_response.body)).to include_json(status: 500)
      end

      it 'return 422 status when pass name parameter with a length > 100' do
        post "/api/pets", {pet: {name: SecureRandom.hex(120)}}
        expect(last_response.status).to eq(422)
        expect(JSON.parse(last_response.body)).to include_json(status: 422, message: "Validation failed: Name is too long (maximum is 100 characters)")
      end

      it 'return 422 status when pass tag parameter with a length > 100' do
        post "/api/pets", {pet: {name: Faker::Name.first_name, tag: SecureRandom.hex(120)}}
        expect(last_response.status).to eq(422)
        expect(JSON.parse(last_response.body)).to include_json(status: 422, message: "Validation failed: Tag is too long (maximum is 100 characters)")
      end

      it 'return 422 status when pass all parameters with a length > 100' do
        post "/api/pets", {pet: {name: SecureRandom.hex(120), tag: SecureRandom.hex(120)}}
        expect(last_response.status).to eq(422)
        expect(JSON.parse(last_response.body)).to include_json(status: 422, message: "Validation failed: Name is too long (maximum is 100 characters), Tag is too long (maximum is 100 characters)")
      end

    end

    context "pass correct params" do
      let(:pet_attributes) { attributes_for(:pet) }
      it 'should be return 201 status' do
        post "/api/pets", {pet: pet_attributes}
        expect(last_response.status).to eq(201)
        expect(JSON.parse(last_response.body)).to include_json(id: 1, name: pet_attributes[:name], tag: pet_attributes[:tag])
      end

    end

  end

  describe "GET /api/pets/:pet_id" do
    context "with find record" do
      before(:each) do
        create(:pet, {name: "Demo dog", tag: "dog"})
      end

      it 'returns pet record when find by id' do
        get '/api/pets/1'
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)).to include_json(id: 1, name: "Demo dog", tag: "dog")
      end

      it 'returns active record error when find by id returns nil' do
        get '/api/pets/111111'
        expect(last_response.status).to eq(404)
        expect(JSON.parse(last_response.body)).to include_json(status: 404, message: "Couldn't find Pet with 'id'=111111")
      end
    end
  end

  describe "GET /api/pets" do
    context 'without records' do
      it 'returns an empty array of pets' do
        get '/api/pets'
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body).length).to eq(0)
      end
    end


    context 'with one records' do

      before(:each) do
        FactoryBot.create(:pet, {name: 'Demo', tag: 'dog'})
      end

      it 'return one element of pets' do
        get '/api/pets'
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body).length).to eq(1)
        expect(JSON.parse(last_response.body)).to include_json(
                                                      [{id: 1, name: 'Demo', tag: 'dog'}]
                                                  )
      end
    end

    context 'with n records' do
      before(:each) do
        [*1..15].map { create(:pet) }
      end
      it 'returns n elements of pets' do
        get '/api/pets'
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body).length).to eq(15)
      end

      it 'returns 10 elements when limit query params is included' do
        get '/api/pets?limit=10'
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body).length).to eq(10)
      end

      it 'returns the x-next header when the limit is 10 and there are still records' do
        get '/api/pets?limit=10'
        expect(last_response.headers["X-Next"].to_s).to eq("http://example.org/api/pets?limit=10&page=2")
        expect(last_response.status).to eq(200)
      end

      it 'returns null x-next header when limit is 15 and there are no more records' do
        get '/api/pets?limit=15'
        expect(last_response.headers["X-Next"]).to be_nil
        expect(last_response.status).to eq(200)
      end

      it 'returns second page and 5 records when limit is 10 and page is 2' do
        get '/api/pets?limit=10&page=2'
        expect(last_response.status).to eq(200)
        expect(last_response.headers["X-Next"]).to be_nil
        expect(JSON.parse(last_response.body).length).to eq(5)
      end


      it "returns error when query limit params is > 100" do
        get '/api/pets?limit=101'
        expect(last_response.status).to eq(400)
        expect(JSON.parse(last_response.body)).to include_json(status: 400, message: 'Max limit is 100')
      end

      it "returns error when query limit params is <= 0" do
        get '/api/pets?limit=0'
        expect(last_response.status).to eq(400)
        expect(JSON.parse(last_response.body)).to include_json(status: 400, message: 'Minimum limit is 1')
      end

      it "returns error when query page params is <= 0" do
        get '/api/pets?page=0'
        expect(last_response.status).to eq(400)
        expect(JSON.parse(last_response.body)).to include_json(status: 400, message: 'Minimum page is 1')
      end

      it "returns empty array when paging returns no records" do
        get '/api/pets?limit=100&page=100'
        expect(JSON.parse(last_response.body)).to include_json([])
      end
    end
  end

end