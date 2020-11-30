FROM kong/kong:2.1.4

USER root

ENV PACKAGES="openssl-devel kernel-headers gcc git openssh" \
    LUA_BASE_DIR="/usr/local/share/lua/5.1" \
    KONG_OIDC_VER="1.2.1-1" \
    LUA_RESTY_OIDC_VER="1.7.4-1" \
    KONG_PLUGIN_SESSION_VER="2.4.1"

RUN set -ex \
  && apk --no-cache add \
    libssl1.1 \
    openssl \
    curl \
    unzip \
    git \
  && apk --no-cache add --virtual .build-dependencies \
    make \
    gcc \
    openssl-dev \
  \
## Install plugins
 # Remove old lua-resty-session and dependent kong-plugin-session
    && luarocks remove --force kong-plugin-session \
    && luarocks remove --force lua-resty-session \
 # Build kong-plugin-session
    && curl -sL https://raw.githubusercontent.com/Kong/kong-plugin-session/${KONG_PLUGIN_SESSION_VER}/kong-plugin-session-${KONG_PLUGIN_SESSION_VER}-1.rockspec | tee kong-plugin-session-${KONG_PLUGIN_SESSION_VER}-1.rockspec \
    && luarocks build kong-plugin-session-${KONG_PLUGIN_SESSION_VER}-1.rockspec \
 # Build kong-oidc from forked repo because is not keeping up with lua-resty-openidc
    && curl -sL https://raw.githubusercontent.com/nagra-insight/kong-oidc/master/kong-oidc-${KONG_OIDC_VER}.rockspec | tee kong-oidc-${KONG_OIDC_VER}.rockspec | \
        sed -E -e 's/(tag =)[^,]+/\1 "master"/' -e "s/(lua-resty-openidc ~>)[^\"]+/\1 ${LUA_RESTY_OIDC_VER}/" > kong-oidc-${KONG_OIDC_VER}.rockspec \
    && luarocks build kong-oidc-${KONG_OIDC_VER}.rockspec \
 # Patch nginx_kong.lua for kong-oidc session_secret
    && TPL=${LUA_BASE_DIR}/kong/templates/nginx_kong.lua \
    # May cause side effects when using another nginx under this kong, unless set to the same value
    && sed -i "/server_name kong;/a\ \n\
set_decode_base64 \$session_secret \${{X_SESSION_SECRET}};\n" "$TPL" \
## Cleanup
    && rm -fr *.rock* \
    && apk del .build-dependencies 2>/dev/null \
## Create kong and working directory (https://github.com/Kong/kong/issues/2690)
    && mkdir -p /usr/local/kong \
    && chown -R kong:`id -gn kong` /usr/local/kong \
    # Allow regular users to run these programs and bind to ports < 1024
    && setcap 'cap_net_bind_service=+ep' /usr/local/bin/kong \
    && setcap 'cap_net_bind_service=+ep' /usr/local/openresty/nginx/sbin/nginx

USER kong
