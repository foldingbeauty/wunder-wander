FROM ruby:2.4.3

WORKDIR /app

COPY Gemfile .
RUN bundle install

COPY public public
COPY views views
COPY config config
COPY lib lib
COPY access.sh .
COPY wunderwander-gitops-operator.rb .
COPY wunderwander-gitops-worker.rb .
COPY wunderwander-gitops-frontend.rb .