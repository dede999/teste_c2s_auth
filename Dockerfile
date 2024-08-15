# Use the official Ruby image as a base image
FROM ruby:3.0.2

# Set the working directory
WORKDIR /app

# Copy the Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install the gems
RUN bundle install

# Copy the rest of the application code
COPY . .

# DB commands
RUN bundle exec rails db:create

RUN bundle exec rails db:migrate

# Expose port 4000 to the Docker host
EXPOSE 4000

# Start the Rails server
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "4000"]