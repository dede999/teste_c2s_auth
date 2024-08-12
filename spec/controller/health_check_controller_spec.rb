require 'rails_helper'

RSpec.describe HealthCheckController, type: :controller do
  describe 'GET #check' do
    let(:current_time) { double("current_time") }
    let(:time_str) { "01/01/2021 00:00:00" }

    before do
      allow(Time).to receive(:now).and_return(current_time)
      allow(current_time).to receive(:strftime)
        .with("%d/%m/%Y %H:%M:%S").and_return(time_str)
      get :check
    end

    it 'is expected to have checked the current time' do
      expect(Time).to have_received(:now).at_least(:once)
    end

    it 'is expected to have formatted the current time' do
      expect(current_time).to have_received(:strftime)
        .with("%d/%m/%Y %H:%M:%S")
    end

    it 'returns a success response' do
      expect(response).to be_successful
      expect(response.body).to eq({ status: :ok, message: "API is running at #{time_str}" }.to_json)
    end
  end
end
