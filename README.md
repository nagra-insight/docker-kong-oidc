# docker-kong-oidc
> Builds a [Docker image](https://hub.docker.com/r/revomatico/docker-kong-oidc) from base Kong + [revomatico/kong-oidc](https://github.com/revomatico/kong-oidc) plugin (based on zmartzone/lua-resty-openidc)

> Note on overriding numeric values like ports via env vars: due to a limitation in the lua templating engine in openresty, they must be quoted twice: KONG_X_VAR="'1234'".


## Session: Cookie
- This is the default, but not recommended. I would recommend **shm** for a single instance, lightweight deployment.
- If you have too much information in the session (claims, etc), you may need to [increase the nginx header size](https://github.com/bungle/lua-resty-session#cookie-storage-adapter):
    - `KONG_NGINX_LARGE_CLIENT_HEADER_BUFFERS='4 16k'`
- You can also enable [session compression](https://github.com/bungle/lua-resty-session#pluggable-compressors) to reduce cookie size:
    - `KONG_X_SESSION_COMPRESSOR=zlib`


## Session: Memcached

> Instead of actual memcached, Hazelcast (that is Kubernetes aware), with memcache protocol enabled should be used.
> See https://docs.hazelcast.org/docs/latest-dev/manual/html-single/#memcache-client.

- Reference: https://github.com/bungle/lua-resty-session#memcache-storage-adapter
- To replace the default sesion storage: **cookie**, set
    - `KONG_X_SESSION_STORAGE=memcache`
- Memcached hostname is by default **memcached** (in my case installed via helm in a Kubernetes cluster)
    - Set `KONG_X_SESSION_MEMCACHE_HOST=mynewhost`
    - Alternatively, set up DNS entry for **memcached** to be resolved from within the container
- Memcached port is by default **11211**, override by setting:
    - `KONG_X_SESSION_MEMCACHE_PORT="'12345'"`
- KONG_X_SESSION_MEMCACHE_USELOCKING, default: off
- KONG_X_SESSION_MEMCACHE_SPINLOCKWAIT, default: 150
- KONG_X_SESSION_MEMCACHE_MAXLOCKWAIT, default: 30
- KONG_X_SESSION_MEMCACHE_POOL_TIMEOUT, default: 10
- KONG_X_SESSION_MEMCACHE_POOL_SIZE, default: 10
- KONG_X_SESSION_MEMCACHE_CONNECT_TIMEOUT, default 1000 (milliseconds)
- KONG_X_SESSION_MEMCACHE_SEND_TIMEOUT, default 1000 (milliseconds)
- KONG_X_SESSION_MEMCACHE_READ_TIMEOUT, default 1000 (milliseconds)


## Session: DSHM (Hazelcast + Vertex)

> This lua-resty-session implementation depends on [grrolland/ngx-distributed-shm](https://github.com/grrolland/ngx-distributed-shm) dshm.lua library.
> Recommended: Hazelcast with memcache protocol enabled (see above).

- Reference: https://github.com/bungle/lua-resty-session#dshm-storage-adapter
- To replace the default sesion storage: **cookie**, set
    - `KONG_X_SESSION_STORAGE=dshm`
- X_SESSION_DSHM_REGION, default: oidc_sessions
- X_SESSION_DSHM_CONNECT_TIMEOUT, default: 1000
- X_SESSION_DSHM_SEND_TIMEOUT, default: 1000
- X_SESSION_DSHM_READ_TIMEOUT, default: 1000
- X_SESSION_DSHM_HOST, default: hazelcast
- X_SESSION_DSHM_PORT, default: 4321
- X_SESSION_DSHM_POOL_NAME, default: oidc_sessions
- X_SESSION_DSHM_POOL_TIMEOUT, default: 1000
- X_SESSION_DSHM_POOL_SIZE, default: 10
- X_SESSION_DSMM_POOL_BACKLOG, default: 10


## Session: SHM

> Good for single instance. No additional software is required.

- Reference: https://github.com/bungle/lua-resty-session#shared-dictionary-storage-adapter
- To replace the default sesion storage: **cookie** with **shm**, set
    - `KONG_X_SESSION_STORAGE=shm`
- KONG_X_SESSION_SHM_STORE, default: oidc_sessions
- KONG_X_SESSION_SHM_STORE_SIZE, default: 5m
- KONG_X_SESSION_SHM_USELOCKING, default: no
- KONG_X_SESSION_SHM_LOCK_EXPTIME, default: 30
- KONG_X_SESSION_SHM_LOCK_TIMEOUT, default: 5
- KONG_X_SESSION_SHM_LOCK_STEP, default: 0.001
- KONG_X_SESSION_SHM_LOCK_RATIO, default: 2
- KONG_X_SESSION_SHM_LOCK_MAX_STEP, default: 0.5


## Notes
- Dockerfile will patch `nginx_kong.lua` template at build time, to include `set_decode_base64 $session_secret 'some_base64_string';`
    - This is needed for the kong-oidc plugin to set a session secret that will later override the template string
    - See: https://github.com/nokia/kong-oidc/issues/1
- To enable the plugins, set the env variable for the container with comma separated plugin values:
    - [Kong < 0.14] `KONG_CUSTOM_PLUGINS=oidc`
    - [Kong >= 0.14] `KONG_PLUGINS=bundled,oidc`
- A common default session_secret should be defined by setting env KONG_X_SESSION_SECRET
- KONG_X_SESSION_NAME=oidc_session


## Releases
- Kong v2.3.3: [Dockerfile](https://github.com/Revomatico/docker-kong-oidc/blob/master/Dockerfile)
- Kong v2.3.2: [Dockerfile](https://github.com/Revomatico/docker-kong-oidc/blob/2.3.2-2/Dockerfile)
- Kong v2.3.0: [Dockerfile](https://github.com/Revomatico/docker-kong-oidc/blob/2.3.0-3/Dockerfile)
- Kong v2.2.1: [Dockerfile](https://github.com/Revomatico/docker-kong-oidc/blob/2.2.1-3/Dockerfile)
- Kong v2.1.4: [Dockerfile](https://github.com/Revomatico/docker-kong-oidc/blob/2.1.4-1/Dockerfile)
- Kong v2.1.0: [Dockerfile](https://github.com/Revomatico/docker-kong-oidc/blob/2.1.0-1/Dockerfile)
- Kong v2.0.5: [Dockerfile](https://github.com/Revomatico/docker-kong-oidc/blob/2.0.5-4/Dockerfile)
- Kong v2.0.4: [Dockerfile](https://github.com/Revomatico/docker-kong-oidc/blob/2.0.4-1/Dockerfile)
- Kong v2.0.3: [Dockerfile](https://github.com/Revomatico/docker-kong-oidc/blob/2.0.3-1/Dockerfile)
- Kong v2.0.2: [Dockerfile](https://github.com/Revomatico/docker-kong-oidc/blob/2.0.2-1/Dockerfile)
- Kong v1.5.0: [Dockerfile](https://github.com/Revomatico/docker-kong-oidc/blob/1.5.0-1/Dockerfile)
- Kong v1.4.2: [Dockerfile](https://github.com/Revomatico/docker-kong-oidc/blob/1.4.2-1/Dockerfile)
- Kong v1.4.1: [Dockerfile](https://github.com/Revomatico/docker-kong-oidc/blob/1.4.1-1/Dockerfile)
- Kong v1.4.0: [Dockerfile](https://github.com/Revomatico/docker-kong-oidc/blob/1.4.0-1/Dockerfile)
- Kong v1.3.0: [Dockerfile](https://github.com/Revomatico/docker-kong-oidc/blob/1.3.0-2/Dockerfile)
- Kong v1.2.2: [Dockerfile](https://github.com/Revomatico/docker-kong-oidc/blob/1.2.2-1/Dockerfile)
- Kong v1.1.2: [Dockerfile](https://github.com/Revomatico/docker-kong-oidc/blob/1.1.2-1/Dockerfile)
- Kong v1.0.3: [Dockerfile](https://github.com/Revomatico/docker-kong-oidc/blob/1.0.3-1/Dockerfile)
- Kong v0.14: [Dockerfile](https://github.com/Revomatico/docker-kong-oidc/blob/0.14-2/Dockerfile)
- Kong v0.13: [Dockerfile](https://github.com/Revomatico/docker-kong-oidc/blob/0.13-3/Dockerfile)
- Kong v0.12:  [Dockerfile](https://github.com/Revomatico/docker-kong-oidc/blob/0.12/Dockerfile)


## Release notes
- 2021-03-10 [2.3.3-1]:
    - Bumped kong to 2.3.3
- 2021-02-25 [2.3.2-2]:
    - Do not add NET_BIND_SERVICE capability to make it easier to deploy the image in environments with security constraints
    - Improved test script
- 2021-02-17 [2.3.2-1]:
    - Bumped kong to 2.3.2
- 2021-02-17 [2.3.0-3]:
    - Bumped kong-oidc version to 1.2.3-1 to implement PR [revomatico#3](https://github.com/revomatico/kong-oidc/pull/3) and [revomatico#4](https://github.com/revomatico/kong-oidc/pull/4)
- 2021-01-21 [2.3.0-2]:
    - Added session compression configuration using `KONG_X_SESSION_COMPRESSOR`
- 2021-01-16 [2.3.0-1]:
    - Bumped Kong to 2.3.0
- 2021-01-16 [2.2.1-3]:
    - Added `lua_shared_dict` caching for discovery, jwks and introspection. Default cache size is 128k (small).
    - Bumped kong-oidc version to 1.2.2-2 to implement PR [revomatico#2](https://github.com/revomatico/kong-oidc/pull/2)
    - Compatibility note: Groups/credentials are now injected regardless of `disable_userinfo_header` param
    - Compatibility note: Param `disable_userinfo_header` is now honored also for introspection
    - Compatibility note: OIDC authenticated request now clears possible (anonymous) consumer identity and sets X-Credential-Identifier
- 2021-01-06 [2.2.1-2]:
    - Removed `x_proxy_cache_storage_name` in favor of built-in `nginx_http_lua_shared_dict`. See: https://github.com/Kong/kong/issues/4643
    - Bump `kong-plugin-session` to 2.4.4
- 2020-12-14 [2.2.1-1]:
    - Bumped Kong to 2.2.1
    - Bumped lua-resty-oidc to 1.7.4-1
    - Bumped kong-plugin-session to 2.4.3
- 2020-10-27 [2.1.4-1]:
    - Bumped Kong to 2.1.4
    - Bumped lua-resty-oidc to 1.7.3-1
- 2020-07-26 [2.1.0-1]:
    - Bumped Kong to 2.1.0
- 2020-07-26 [2.0.5-4]:
    - Set default image user to kong
- 2020-07-03 [2.0.5-3]:
    - Added DSHM (Hazelcast) session storage support using [ngx-distributed-shm](https://github.com/grrolland/ngx-distributed-shm/) dshm.lua library
- 2020-07-02 [2.0.5-2]:
    - Using kong-plugin-session 2.4.1
    - Using lua-resty-session 3.5
- 2020-07-02 [2.0.5-1]:
    - Bumped Kong version to 2.0.5
    - Add memcache env vars
- 2020-05-06 [2.0.4-1]:
    - Bumped Kong version to 2.0.4
    - Bumped kong-oidc plugin to 1.2.1-1 after implementing PR [nokia#132](https://github.com/nokia/kong-oidc/pull/132)
- 2020-04-12 [2.0.3-1]:
    - Bumped Kong version to 2.0.3
- 2020-03-20 [2.0.2-1]:
    - Bumped Kong version to 2.0.2, using alpine image instead of centos
- 2020-02-21 [1.5.0-1]:
    - Bumped Kong version to 1.5.0, the last 1.x version
    - Using [Revomatico/kong-oidc](https://github.com/Revomatico/kong-oidc) repo
- 2019-11-19 [1.4.2-1]:
    - Bumped Kong version to 1.4.2
    - Added proxy cache plugin custom dictionary
- 2019-10-28 [1.4.1-1]:
    - Bumped Kong version to 1.4.1
    - Added shm session storage support
    - Added test.sh to quickly validate the build
    - Improved README.md
- 2019-10-28 [1.4.0-1]:
    - Bumped Kong version to 1.4.0
- 2019-09-05 [1.3.0-2]:
    - Introduced `session_name` to override the default 'session' with 'oidc_session' as it may be overriden by upstream applications.
- 2019-08-16 [1.3.0-1]:
    - Bump to Kong 1.3.0-centos image
    - Trying again lua-resty-oidc 1.7.2-1
- 2019-08-16 [1.2.2-1]:
    - Bump to Kong 1.2.2-centos image
- 2019-07-05 [1.2.1-4]:
    - Removed **kong-http-to-https-redirect** in favor of the built in route attribute: [https_redirect_status_code=301](https://docs.konghq.com/1.2.x/admin-api/#create-route)
- 2019-07-04 [1.2.1-3]:
    - Reverted to original nokia/kong-oidc, that uses lua-resty-oidc 1.6.1-1 - because of bad performance, again, with 1.7.1-1
- 2019-07-04 [1.2.1-2]:
    - Correctly added **hostname** package in Dockerfile
    - Forced a commit to rebuild the image on docker hub, because of changes in kong-oidc plugin
- 2019-07-01 [1.2.1-1]:
    - Bump to Kong 1.2.1-centos image
- 2019-06-13 [1.2.0-1]:
    - Bump to Kong 1.2.0-centos image
- 2019-04-27 [1.1.2-1]:
    - Used Kong 1.1.2-centos image
    - Changed kong-oidc plugin repo from Nokia to [Revomatico](https://github.com/Revomatico/kong-oidc) for various improvements and compatibility with lua-resty-openidc 1.7
- 2019-04-02 [1.1.1-1]:
    - Using Kong 1.1.1-centos image
- 2019-02-22 [1.0.3-1]:
    - Kept creation of `/usr/local/kong` in Dockerfile
    - Removed Dockerfile's `USER` directive is incompatible with su-exec. See https://github.com/ncopa/su-exec/issues/2#issuecomment-336670196
- 2019-02-21 [1.0.3]:
    - Replaced **Revomatico/kong-http-to-https-redirect** with [dsteinkopf/kong-http-to-https-redirect](https://github.com/dsteinkopf/kong-http-to-https-redirect) as it has more fixes and improvements
    - Upgraded rockspec [zmartzone/lua-resty-openidc](https://github.com/zmartzone/lua-resty-openidc) to 1.7.1-1
    - Using Kong 1.0.3 image
    - Added new environment variables to configure memcached
- 2018-11-27 [0.14-2]:
    - ~~Upgraded rockspec [zmartzone/lua-resty-openidc](https://github.com/zmartzone/lua-resty-openidc) to 1.7.0-2~~ this causes issues, staying with 1.6.1-1 for now
    - Added env variable KONG_X_SESSION_SECRET to populate $session_secret variable with the same variable for all pods in the cluster
    - Removed explicitly building lua-resty-openidc in Dockerfile, since is automatically done by luarocks build, since is a dependency of kong-oidc
    - Set everything to run under regular user kong instead of root
- 2018-10-09 [0.14-1]:
    - Upgraded to Kong 0.14
- 2018-10-09 [0.13-3]:
    - Changed repo for kong-http-to-https-redirect to [Revomatico/kong-http-to-https-redirect](https://github.com/Revomatico/kong-http-to-https-redirect)
- 2018-08-10 [0.13-2]:
    - Forced a rebuild to update rockspec [HappyValleyIO/kong-http-to-https-redirect](https://github.com/HappyValleyIO/kong-http-to-https-redirect)
- 2018-07-07 [0.13-1]:
    - Updated rockspec [zmartzone/lua-resty-openidc](https://github.com/zmartzone/lua-resty-openidc) to 1.6.1-1
- 2018-07-04 [0.13]:
    - Updated rockspec [nokia/kong-oidc](https://github.com/nokia/kong-oidc) to 1.1.0-0
    - Updated rockspec [zmartzone/lua-resty-openidc](https://github.com/zmartzone/lua-resty-openidc) to 1.6.0-1
