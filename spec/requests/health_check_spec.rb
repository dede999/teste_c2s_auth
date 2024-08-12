require 'rails_helper'

RSpec.describe "HealthChecks", type: :request do
  describe "GET /check" do
    it "returns http success" do
      get "/health_check/check"
      expect(response).to have_http_status(:success)
    end

    it "returns message with the current timestamp" do
      get "/health_check/check"
      expect(response.body).to eq({ status: :ok, message: "API is running at #{Time.now.strftime("%d/%m/%Y %H:%M:%S")}" }.to_json)
    end
  end
end
