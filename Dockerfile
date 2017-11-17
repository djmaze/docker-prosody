FROM ubuntu:16.04

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates inotify-tools wget \
 && echo deb http://packages.prosody.im/debian wheezy main | tee -a /etc/apt/sources.list.d/prosody.list \
 && wget --no-check-certificate https://prosody.im/files/prosody-debian-packages.key -O- | apt-key add - \
 && apt-get update \
 && apt-get install -y --no-install-recommends lua-bitop lua-sec-prosody prosody  \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Add modules
RUN cd /usr/lib/prosody/modules \
 && wget https://hg.prosody.im/prosody-modules/raw-file/tip/mod_http_upload/mod_http_upload.lua

# Add custom config
RUN echo include \"/etc/prosody/conf.d/*.cfg.lua\" >>/etc/prosody/prosody.cfg.lua
COPY 00prosody.cfg.lua /etc/prosody/conf.d/

#ENV __FLUSH_LOG 1
COPY docker-entrypoint /
ENTRYPOINT ["/docker-entrypoint"]
CMD ["prosodyctl", "start"]

EXPOSE 5222 5269 5280 5347
VOLUME "/var/lib/prosody"
