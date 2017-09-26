{
  title: "SalesforceIQ",

  connection: {
    fields: [
      { name: "api_key", label: "API Key", optional: false },
      { name: "api_secret", label: "API Secret", optional: false,
        control_type: "password" }
    ],

    authorization: {
      type: "basic_auth",

      credentials: ->(connection) {
        user(connection["api_key"])
        password(connection["api_secret"])
      }
    }
  },

  test: ->(connection) {
    get("https://api.salesforceiq.com/v2/accounts?_limit=1")
  },

  object_definitions: {
    account: {
      fields: ->(connection) {
        [
          { name: "id" },
          { name: "name" },
          { name: "modifiedDate", type: :integer,
            hint:
            "Stores a particular Date & Time in UTC milliseconds past the epoch." }, # milliseconds since epoch
        ].concat(
          get("https://api.salesforceiq.com/v2/accounts/fields")["fields"].
          map do |field|
            pick_list = field["listOptions"].
              map { |o| [o["display"], o["id"]] } if field["dataType"] == "List"
            {
              name: field["id"],
              label: field["name"],
              control_type: field["dataType"] == "List" ? "select" : "text",
              pick_list: pick_list
            }
        end)
      }
    },
  },

  actions: {
    create_account: {

      description:
      "Create <span class='provider'>Account</span> in <span class='provider'>SalesforceIQ</span>",

      input_fields: ->(object_definitions) {
        object_definitions["account"].ignored("id")
      },

      execute: ->(connection,input) {
        fields = {}
        input.each do |k, v|
          if k != "name"
            fields[k] = [ { raw: v } ]
          end
        end
        post("https://api.salesforceiq.com/v2/accounts",
             { name: input[:name], fieldValues: fields })
      },

      output_fields: ->(object_definitions) {
        object_definitions["account"]
      },
      sample_output: ->(connection){
        get("https://api.salesforceiq.com/v2/accounts")["objects"]&.first || {}
      }
    },

    search_account: {
      description:
      "Search <span class='provider'>Account</span>in <span class='provider'>SalesforceIQ</span>",


      input_fields: ->() {
        [
          { name: "_ids", label: "Account identifiers",
            hint: "Comma separated list of Account identifiers" }
        ]
      },

      execute: ->(connection,input) {
        response = get("https://api.salesforceiq.com/v2/accounts",input)
        accounts = response["objects"]

        accounts.each do |account| # add each custom field to account response object
          (account["fieldValues"] || {}).map do |k,v|
            account[k] = v.first["raw"]
          end
        end

        { "accounts": accounts }
      },

      output_fields: ->(object_definitions) {
        [{ name: "accounts", type: :array, of: :object,
           properties: object_definitions["account"] }]
      },
      sample_output: ->(connection){
        get("https://api.salesforceiq.com/v2/accounts")["objects"]&.first || {}
      }
    }
  },

  triggers: {

    new_updated_accounts: {
      description:
      "New/Updated <span class='provider'>Account</span> in
      <span class='provider'>SalesforceIQ</span>",
      help: "Checks for new or updated accounts based on the plan",


      input_fields: -> (object_definitions) {
        [
          { name: "since", type: :timestamp,
            hint: "Recipe picks records start time, If value is not provided" }]
      },

      poll: -> (connection,input,modified_date_since) {

        modified_date = modified_date_since || (
        input["since"].present? ? (input["since"].to_time.to_f * 1000).to_i : (
          Time.now.to_time.to_f * 1000).to_i )
        modified_date = 1506336003313
        result = get("https://api.salesforceiq.com/v2/accounts").
          params(_limit: 50, _start: 0, 
          modifiedDate: modified_date_since)["objects"] # result returns in ascending order
        accounts = result.each do |account| # add each custom field to account response object
          (account["fieldValues"] || {}).map do |k,v|
            account[k] = v.first["raw"]
          end
        end
        # TODO Handle the mass update case by storing the page number
        if accounts.size == 0
          modified_date_since = (Time.now.to_f * 1000).to_i
        else
          modified_date_since = accounts.last["modifiedDate"]
        end

        {
          events: accounts,
          next_poll: modified_date_since,
          next_page: accounts.size == 50
        }
      },

      sort_by: ->(account) {
        account["modifiedDate"]
      },

      dedup: ->(account) {
        [account["id"], account["modifiedDate"]].join("_")
      },

      output_fields: ->(object_definitions) {
        object_definitions["account"]
      },
      sample_output: ->(connection){
        get("https://api.salesforceiq.com/v2/accounts")["objects"]&.first || {}
      }
    }
  }

}
