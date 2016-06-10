FROM elixir:1.2.5

# Install docker and docker-compose
RUN curl -sSL https://get.docker.com/ | sh
RUN sh -c "curl -L https://github.com/docker/compose/releases/download/1.7.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose"
RUN chmod +x /usr/local/bin/docker-compose

RUN mkdir -p /dockup
WORKDIR /dockup
COPY . ./
COPY ./apps/dockup_ui/config/prod.secret.example.exs apps/dockup_ui/config/prod.secret.exs

ENV MIX_ENV prod
ENV PORT 4000

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get --force --only prod
RUN mix compile

# Precompile DockupUi assets
WORKDIR /dockup/apps/dockup_ui
RUN wget -qO- https://deb.nodesource.com/setup_6.x | bash
RUN apt-get update && apt-get install -y nodejs build-essential
RUN npm install
RUN ./node_modules/brunch/bin/brunch build --production
RUN mix phoenix.digest

WORKDIR /dockup
EXPOSE 4000

CMD ["mix", "phoenix.server"]
