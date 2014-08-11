FROM ubuntu:14.04

## Use closest mirror
RUN sed -i -e 's|http://archive.ubuntu.com/ubuntu/ |mirror://mirrors.ubuntu.com/mirrors.txt |g' /etc/apt/sources.list
RUN apt-get -y update

## Basic dev libraries (for gems)
RUN apt-get --no-install-recommends -y install build-essential libssl-dev libxml2-dev libxslt-dev zlib1g-dev git

# Dependencies for project
RUN apt-get --no-install-recommends -y install libpq-dev libgeos-dev libproj-dev postgresql-client-9.3 postgis rpm
# Add libgeos symlinks for rgeo gem
RUN ln -sf /usr/lib/libgeos-3.4.2.so /usr/lib/libgeos.so && ln -sf /usr/lib/libgeos-3.4.2.so /usr/lib/libgeos.so.1

## Ruby
RUN apt-get --no-install-recommends -y install software-properties-common python-software-properties
RUN apt-add-repository ppa:brightbox/ruby-ng-experimental
RUN apt-get -y update
RUN apt-get --no-install-recommends -y install ruby2.1 ruby2.1-dev
# Fix Ruby symlinks
RUN ln -sf /usr/bin/ruby2.1 /usr/bin/ruby
RUN ln -sf /usr/bin/gem2.1 /usr/bin/gem
RUN gem install bundler --no-rdoc --no-ri -v '>= 1.6.2'
#
# Install packages for installing Huboard
RUN apt-get -qq -y install couchdb memcached nodejs
RUN apt-get clean
RUN gem install foreman

RUN mkdir -p /var/run/couchdb
# Install Huboard
RUN git clone -b master https://github.com/rauhryan/huboard.git /app
RUN cd /app; bundle install;
ADD .env /app/.env
ADD Procfile /app/Procfile

# Run Huboard instance
EXPOSE 3000
EXPOSE 5200
CMD foreman start -f /app/Procfile
