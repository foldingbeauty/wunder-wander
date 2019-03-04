FROM ruby:2.4.3

WORKDIR /app

RUN useradd -ms /bin/bash wunder-wander
RUN chown wunder-wander:wunder-wander /app
USER wunder-wander

COPY --chown=wunder-wander:wunder-wander Gemfile .
RUN bundle install

RUN mkdir bin
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl -o /app/bin/kubectl
RUN chmod +x /app/bin/kubectl

COPY --chown=wunder-wander:wunder-wander deployment deployment
COPY --chown=wunder-wander:wunder-wander frontend frontend
COPY --chown=wunder-wander:wunder-wander operator operator
COPY --chown=wunder-wander:wunder-wander lib lib
COPY --chown=wunder-wander:wunder-wander access.sh .

COPY --chown=wunder-wander:wunder-wander wunderwander_gitops_operator.rb .
COPY --chown=wunder-wander:wunder-wander wunderwander_gitops_worker.rb .
COPY --chown=wunder-wander:wunder-wander wunderwander_gitops_frontend.rb .
