FROM ruby:2.4.3

WORKDIR /app

RUN useradd -ms /bin/bash wunder-wander
RUN chown wunder-wander:wunder-wander /app
USER wunder-wander

COPY --chown=wunder-wander:wunder-wander Gemfile .
RUN bundle install --without development test


COPY --chown=wunder-wander:wunder-wander deployment deployment
COPY --chown=wunder-wander:wunder-wander frontend frontend
COPY --chown=wunder-wander:wunder-wander controller controller
COPY --chown=wunder-wander:wunder-wander lib lib
COPY --chown=wunder-wander:wunder-wander access.sh .

COPY --chown=wunder-wander:wunder-wander wunderwander_gitops_controller.rb .
COPY --chown=wunder-wander:wunder-wander wunderwander_gitops_worker.rb .
COPY --chown=wunder-wander:wunder-wander wunderwander_gitops_frontend.rb .
