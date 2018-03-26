{
  title: 'On-prem security',
  secure_tunnel: true,

  connection: {
    fields: [
      {
        name: 'profile',
        hint: 'On-prem security connection profile'
      }
    ],

    authorization: {
      type: 'none'
    }
  },

  test: ->(connection) {
    post("http://localhost/ext/#{connection['profile']}", { payload: 'test' }).headers('X-Workato-Connector': 'enforce')
  },

  actions: {
    sha256_digest: {

      title: 'Create SHA-256 digest',
      description: 'Create <span class="provider">SHA-256</span> digest',

      input_fields: ->(_) {
        [
          {
            name: 'payload'
          }
        ]
      },

      execute: ->(connection, input) {
        post("http://localhost/ext/#{connection['profile']}", input).headers('X-Workato-Connector': 'enforce')
      },

      # Output schema.  Same as input above.
      output_fields: ->(_) {
        [
          {
            name: 'signature'
          }
        ]
      }
    }
  }
}
