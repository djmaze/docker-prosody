# To build for armhf (ARMv7) devices, change like this:
# * FROM mazzolino/armhf-debian
# * add "lua-sec-prosody" to prosody install line (because lua-sec v0.5 is needed for PFS)
FROM debian:wheezy

RUN apt-get update
RUN apt-get install -y ca-certificates wget; apt-get clean
RUN echo deb http://packages.prosody.im/debian wheezy main | tee -a /etc/apt/sources.list && \
    wget https://prosody.im/files/prosody-debian-packages.key -O- | apt-key add - && \
    apt-get update && \
    apt-get install -y lua-sec-prosody prosody lua-event lua-zlib; apt-get clean

# Add modules
RUN cd /usr/lib/prosody/modules && \
    wget http://prosody-modules.googlecode.com/hg/mod_carbons/mod_carbons.lua \
         http://prosody-modules.googlecode.com/hg/mod_smacks/mod_smacks.lua
RUN sed -i '/modules_enabled/,/}/ s/}/\n\t\t"carbons"; "smacks"; "proxy65"; \n }/' /etc/prosody/prosody.cfg.lua

RUN echo include \"/etc/prosody/conf.d/*.cfg.lua\" >>/etc/prosody/prosody.cfg.lua
ADD 00prosody.cfg.lua /etc/prosody/conf.d/
ONBUILD ADD conf.d /etc/prosody/conf.d
ONBUILD ADD certs /etc/prosody/certs
ONBUILD RUN chown -R prosody:prosody /etc/prosody/certs && chmod 0700 /etc/prosody/certs && chmod 0600 /etc/prosody/certs/*

RUN touch /var/lib/prosody/.keep && chown -R prosody /var/lib/prosody
VOLUME /var/lib/prosody

ENV __FLUSH_LOG 1
CMD sh -c "chown prosody /var/lib/prosody && prosodyctl start"

EXPOSE 5222 5269 5280 5347
