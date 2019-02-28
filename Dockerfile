FROM ruby:2.4.3

WORKDIR /app

RUN useradd -ms /bin/bash wunder-wander
RUN chown wunder-wander:wunder-wander /app
USER wunder-wander

COPY Gemfile .
RUN bundle install

COPY deployment deployment
COPY frontend frontend
COPY operator operator
COPY lib lib
COPY access.sh .

COPY wunderwander_gitops_operator.rb .
COPY wunderwander_gitops_worker.rb .
COPY wunderwander_gitops_frontend.rb .
