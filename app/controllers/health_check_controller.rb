class HealthCheckController < ApplicationController
  def check
    current_time = Time.now.strftime("%d/%m/%Y %H:%M:%S")
    render json: { status: :ok, message: "API is running at #{current_time}" }
  end
end
