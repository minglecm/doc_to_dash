FROM ruby

RUN touch ~/.gemrc && \
  echo "gem: --no-ri --no-rdoc" >> ~/.gemrc && \
  mkdir -p /gem/

WORKDIR /gem/
COPY . /gem/
RUN bundle install

VOLUME .:/gem/

ENTRYPOINT ["bundle", "exec"]
CMD ["rake", "-T"]
