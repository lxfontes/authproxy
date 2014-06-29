passport = require('passport-oauth')

class Strategy extends passport.OAuth2Strategy
  constructor: (options, verify) ->
    options.authorizationURL = 'https://accounts.google.com/o/oauth2/auth'
    options.tokenURL = 'https://accounts.google.com/o/oauth2/token'
    @auth_domain = options.hostedDomain
    super(options, verify)

  authorizationParams: (options) ->
    {hd: @auth_domain}

  userProfile: (accessToken, done) ->
    @_oauth2.get 'https://www.googleapis.com/oauth2/v1/userinfo', accessToken, (err, body, res) ->
      if err
        return done('Failed to fetch user profile')
      json = JSON.parse(body)
      profile = {
        provider: 'google'
      }
      profile.id = json.id
      profile.displayName = json.name
      profile.email = json.email
      return done(null, profile)

module.exports = Strategy
