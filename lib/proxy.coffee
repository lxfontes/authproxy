httpProxy = require('http-proxy')
passport = require('passport')
MixedStrategy = require('./mixed_strategy')

passport.serializeUser (user, done) ->
  done(null, user.email)

passport.deserializeUser (id, done) ->
  done(null, id)

ensureAuthed = (req, res, next) ->
  if req.session.passport?.user?
    return next()
  return res.redirect('/conci/google')

testVerify = (accessToken, refreshToken, profile, done) ->
  console.log("Verified #{profile.email}")
  process.nextTick ->
    return done(null, profile)

randomUpstream = (upstreams) ->
  upstreams[Math.floor((Math.random()*upstreams.length))]

splitHostPort = (s) ->
  parts = s.split(':', 2)
  ret = {
    host: parts[0]
  }

  if parts.length > 1
    ret.port = parseInt(parts[1], 10)
  else
    ret.port = 80

  return ret

class InternalDomain
  constructor: (config) ->
    @config = config

class Proxy
  constructor: () ->
    @internal_domains = {}
    @http_proxy = httpProxy.createProxyServer({})

  # host,upstream,client_id,client_secret,cookie_secret
  addInternalDomain: (auth_domain, domain) ->
    console.log("Adding #{domain.host}")
    @internal_domains[domain.host] = domain

    strategy = new MixedStrategy({
      hostedDomain: auth_domain,
      clientID: domain.client_id,
      clientSecret: domain.client_secret,
      callbackURL: "http://#{domain.host}/conci/google/return"
      }, testVerify)
    passport.use(domain.host, strategy)

  configApp: (app) =>
    app.use(passport.initialize())
    app.use(passport.session())
    app.use(@checkDomain())
    app.get('/conci/google', @redirect())
    app.get('/conci/google/return', @callback())
    app.get('/conci/user', ensureAuthed, @getUser())
    app.get('/*', ensureAuthed, @goProxy())


  getUser: =>
    (req, res) =>
      res.send(req.session.passport.user)

  redirect: =>
    (req, res, next) =>
      passport.authenticate(req.conci_domain, { scope: ['profile', 'email'] })(req, res, next)

  callback: =>
    (req, res, next) =>
      passport.authenticate(req.conci_domain, { successRedirect: '/', failureRedirect: '/conci/google' })(req, res, next)

  checkDomain: =>
    (req, res, next) =>
      endpoint = splitHostPort(req.headers['host'])
      search_domain = "#{endpoint.host}:#{endpoint.port}"
      e = @internal_domains[search_domain]

      unless e?
        return res.status(404).send('invalid domain')

      req.conci_endpoint = e
      req.conci_domain = search_domain
      next()

  goProxy: =>
    (req, res, next) =>
      dest = splitHostPort(randomUpstream(req.conci_endpoint.upstream))
      @http_proxy.web(req, res, {
        target: "http://#{dest.host}:#{dest.port}"
        })

module.exports = new Proxy
