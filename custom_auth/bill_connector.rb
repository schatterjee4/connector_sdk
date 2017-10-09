# Adds operations missing from the standard adapter.
{
  title: "Bill.com(custom)",

  connection: {
    fields: [
      {
        name: "user_name",
        hint: "Bill.com app login username",
        optional: false
      },
      {
        name: "password",
        hint: "Bill.com app login password",
        optional: false,
        control_type: "password"
      },
      {
        name: "org_id",
        label: "Organisation ID",
        hint: "Log in to your Bill.com account, click on gear icon, click " \
          "on settings then click on profiles under your company.<br>The "  \
          "Organization ID is at the end of the URL, after "                \
          "https://[app/app-stage].bill.com/Organization?Id=",
        optional: false
      },
      {
        name: "dev_key",
        label: "Developer API key",
        hint: "Sign up for the developer program to get API key. "           \
          "You may find more info <a href='https://developer.bill.com/hc/"   \
          "en-us/articles/208695076'>here</a>",
        optional: false,
        control_type: "password"
      },
      {
        name: "endpoint",
        label: "Edition",
        hint: "Find more info <a href='https://developer.bill.com/hc/en-us/" \
          "articles/208249476-Sandbox-production-differences'>here</a>",
        control_type: "select",
        pick_list: [
          ["Bill.com Sandbox/Stage Environment",
           "https://api-stage.bill.com/api/v2/"],
          ["Bill.com Production", "https://api.bill.com/api/v2/"]
        ],
        optional: false
      }
    ],

    authorization: {
      type: "custom_auth",

      acquire: lambda { |connection|
        {
          session_id: post("#{connection['endpoint']}Login.json")
            .payload(userName: connection["user_name"],
                     password: connection["password"],
                     orgId: connection["org_id"],
                     devKey: connection["dev_key"])
            .request_format_www_form_urlencoded
            .dig("response_data", "sessionId")
        }
      },

      refresh_on: [/"error_message"\s*\:\s*"Session is invalid/],

      detect_on: [/"response_message"\s*\:\s*"Error"/],

      apply: lambda { |connection|
        payload(sessionId:  connection["session_id"],
                devKey: connection["dev_key"])
        request_format_www_form_urlencoded
      }
    }
  },

  test: lambda { |connection|
    post("#{connection['endpoint']}GetSessionInfo.json")
  },

  object_definitions: {
    vendor: {
      fields: lambda { |connection, _config_fields|
        post("#{connection['endpoint']}GetEntityMetadata.json")
          .dig("response_data", "Vendor", "fields")
          .map do |key, _value|
            {
              name: key
            }
          end
      }
    }
  },

  triggers: {
    new_or_updated_vendor: {
      description: "New or updated <span class='provider'>vendor</span> in " \
        "<span class='provider'>Bill.com</span>",
      subtitle: "New/updated vendor",
      type: "paging_desc",

      input_fields: lambda { |_connection|
        [
          {
            name: "since",
            label: "From",
            type: "timestamp",
            optional: true,
            sticky: true,
            hint: "Get vendors created or updated since given date/time. " \
              "Leave empty to get vendors created or updated one hour ago."
          }
        ]
      },
      poll: lambda { |connection, input, page|
        page ||= 0
        page_size = 50
        query = {
          start: page,
          max: page_size,
          filters: [
            {
              field: "updatedTime",
              op: ">=",
              value: (input["since"].presence || 1.hour.ago)
                .utc
                .strftime("%Y-%m-%dT%H:%M:%S.%L%z")
            }
          ],
          sort: [{ field: "updatedTime", asc: 0 }]
        }

        vendors = post("#{connection['endpoint']}List/Vendor.json")
                  .payload(data: query.to_json)
                  .dig("response_data")

        {
          events: vendors,
          next_page: (vendors.size >= page_size ? page + page_size : nil)
        }
      },

      document_id: lambda { |vendor|
        vendor["id"].to_s + "@" + vendor["updatedTime"].to_s
      },

      output_fields: lambda { |object_definitions|
        object_definitions["vendor"]
      },

      sample_output: lambda { |connection|
        post("#{connection['endpoint']}List/Vendor.json")
          .payload(data: { start: 0, max: 1 }.to_json)
          .dig("response_data")
          &.first
      }
    }
  }
}
