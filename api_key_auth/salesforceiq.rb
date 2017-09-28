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

      credentials: lambda do |connection|
        user(connection["api_key"])
        password(connection["api_secret"])
      end
    }
  },

  test: lambda do |connection|
    get("https://api.salesforceiq.com/v2/accounts?_limit=1")
  end,

  object_definitions: {
    account: {
      fields: lambda do |connection|
        [
          { name: "id" },
          { name: "name" },
          { name: "modifiedDate", type: :integer,
            hint:
            "Stores a particular Date & Time in UTC milliseconds past the epoch." },# milliseconds since epoch
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
      end
    },
  },

  actions: {
    create_account: {
      description:
      "Create <span class='provider'>Account</span> in <span class='provider'>SalesforceIQ</span>",
      input_fields: lambda do |object_definitions|
        object_definitions["account"].ignored("id", "modifiedDate", "address_city", 
        "address_state", "address_postal_code", "address_country")
      end,
      execute: lambda do |connection,input|
        fields = {}
        input.each do |k, v|
          if k != "name"
            fields[k] = [ { raw: v } ]
          end
        end
        post("https://api.salesforceiq.com/v2/accounts").
          payload(name: input['name'], fieldValues: fields)

      end,
      output_fields: lambda do |object_definitions|
        object_definitions["account"]
      end,
      sample_output: lambda do
        get("https://api.salesforceiq.com/v2/accounts")["objects"]&.first || {}
      end
    },
    search_account: {
      description:
      "Search <span class='provider'>Account</span> in <span class='provider'>SalesforceIQ</span>",
      hint: 
      "Returns accounts matching the IDs. Returns all accounts, if blank.",

      input_fields: lambda do
        [ 
          { name: "_ids", label: "Account identifiers",
            hint: "Comma separated list of Account identifiers" 
          } 
        ]
      end,
      execute: lambda do |connection,input|
        accounts = get("https://api.salesforceiq.com/v2/accounts",input)["objects"]
        accounts.each do |account| # add each custom field to account response object
          (account["fieldValues"] || {}).map do |k, v|
            account[k] = v.first["raw"]
          end
        end
        {
          "accounts": accounts
        }
      end,
      output_fields: lambda do |object_definitions|
        [ 
          {
            name: "accounts", type: :array, of: :object,
            properties: object_definitions["account"]
          }
        ]
      end,
      sample_output: lambda do
        get("https://api.salesforceiq.com/v2/accounts")["objects"]&.first || {}
      end
    }
  },

  triggers: {
    new_updated_accounts: {
      description:
      "New/Updated <span class='provider'>Account</span> in " \
        "<span class='provider'>SalesforceIQ</span>",
      help: "Checks for new or updated accounts",
      input_fields: lambda do
        [
          {
            name: "since", type: :timestamp,
            hint: "Fetch trigger events from specified time"
          }
        ]
      end,
      poll: lambda do |connection, input, modified_date_since|
        modified_date = modified_date_since || ((input["since"].presence || 
          Time.now).to_time.to_f * 1000).to_i
        result = get("https://api.salesforceiq.com/v2/accounts").
          params(_limit: 50, _start: 0,
          modifiedDate: modified_date)["objects"] # result returns in ascending order
        accounts = result.each do |account|
          (account["fieldValues"] || {}).map do |k, v|
            account[k] = v.first["raw"]
          end
        end
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
      end,
      sort_by: lambda do |account|
        account["modifiedDate"]
      end,
      dedup: lambda do |account|
        [account["id"], account["modifiedDate"]].join("_")
      end,
      output_fields: lambda do |object_definitions|
        object_definitions["account"]
      end,
      sample_output: lambda do
        get("https://api.salesforceiq.com/v2/accounts")["objects"]&.first || {}
      end
    }
  }

}
