--use_libevent = true

-- https://prosody.im/doc/certificates#automatic_location
--ssl = {
--  key = "/etc/prosody/certs/ssl.key";
--  certificate = "/etc/prosody/certs/ssl.cert";
--}

daemonize = false

log = "*console"

local hostname = os.getenv("XMPP_DOMAIN")
if not hostname then
  hostname = io.input(io.popen("hostname --fqdn")):read()
end

VirtualHost(hostname)
  modules_enabled = { "mam"; "http"; } -- pep_vcard_avatar ?

local conference_hostname = "conference." .. hostname
Component(conference_hostname) "muc"

local upload_hostname = "upload." .. hostname
local upload_url = "https://" .. upload_hostname
Component(upload_hostname) "http_upload"
  http_external_url = upload_url
  http_upload_file_size_limit = 10 * 1024 * 1024  -- 10 MB
  http_upload_expire_after = 60 * 60 * 24 * 7 -- a week in seconds
  http_upload_quota = 100 * 1024 * 1024 -- 100 MB
