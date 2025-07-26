FROM ruby:3.2.2

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

WORKDIR /app

COPY Gemfile ./
RUN bundle install

COPY . .

CMD ["rails", "server", "-b", "0.0.0.0"]
