FROM ruby:3.1.2

ENV TZ Asia/Tokyo
ENV APP_ROOT /usr/src/app
ENV BUILD_PACKAGES="vim mariadb-client"

WORKDIR $APP_ROOT
# 作成したapp rootディレクトリを作業用ディレクトリとして設定

RUN \
  apt-get update -qq && apt-get install -y $BUILD_PACKAGES --no-install-recommends && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/* /var/tmp/*

COPY Gemfile $APP_ROOT/
COPY Gemfile.lock $APP_ROOT/
# ローカルの Gemfile と Gemfile.lock をコンテナ内のapp配下にコピー

RUN \
  echo 'gem: --no-document' >> ~/.gemrc && \
  cp ~/.gemrc /etc/gemrc && \
  chmod uog+r /etc/gemrc && \
  bundle config build.nokogiri --use-system-libraries && \
  bundle config jobs 4 && \
  bundle install && \
  rm -rf ~/.gem

COPY . $APP_ROOT/
# ローカルのapp配下のファイルをコンテナ内のmyapp配下にコピー

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
