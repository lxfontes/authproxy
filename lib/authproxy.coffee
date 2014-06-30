express = require('express')
session = require('express-session')
http = require('http')
toml = require('toml')
fs = require('fs')
proxy = require('./proxy')

getConfig = (path) ->
  try
    conf = fs.readFileSync(path)
    toml.parse(conf)
  catch e
    console.log("Failed to parse configuration file #{path}")
    process.exit(1)

args = process.argv.slice(2);
if args.length < 1
  console.log("Please specify configuration file")
  process.exit(1)

CONFIG = getConfig(args[0])

for k, domain of CONFIG.domains
  proxy.addInternalDomain(CONFIG.server.auth_domain, domain)

app = express()
app.use(session({
  secret: CONFIG.server.cookie_secret,
  resave: true,
  saveUninitialized: true
}))
proxy.configApp(app)

server = http.createServer(app)
server.listen CONFIG.server.bind_port, CONFIG.server.bind_ip, (err) ->
  if err
    console.log("Failed to bind")
    process.exit(1)
  console.log("Listening on #{CONFIG.server.bind_ip}:#{CONFIG.server.bind_port}")
