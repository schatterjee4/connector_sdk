{
  title: "Typeform",

  connection: {
    fields: [
      {
        name: "client_id",
        label: "Client ID",
        hint: "You can find your client ID in the settings page.",
        optional: false
      },
      {
        name: "client_secret",
        label: "Client Secret",
        control_type: "password",
        hint: "You can find your client ID in the settings page.",
        optional: false
      }
    ],

    authorization: {
      type: "oauth2",

      authorization_url: lambda do |connection|
        scopes = [
          "forms:read",
          "workspaces:read"
        ].join(" ")

        "https://api.typeform.com/oauth/authorize?client_id=" \
          "#{connection["client_id"]}&scope=#{scopes}" \
          "&redirect_uri=https%3A%2F%2Fwww.workato.com%2Foauth%2Fcallback"
      end,

      acquire: lambda do |connection, auth_code, _redirect_uri|
        response = post("https://api.typeform.com/oauth/token").
          payload(
            client_id: connection["client_id"],
            client_secret: connection["client_secret"],
            code: auth_code,
            redirect_uri: "https://www.workato.com/oauth/callback"
          ).
          request_format_www_form_urlencoded

        [response, nil, nil]
      end,

      apply: lambda { |_connection, access_token|
        headers("Authorization": "Bearer #{access_token}")
      }
    }
  },

  object_definitions: {
    get_forms: {
      fields: lambda do
        [
          {
            name: "workspace_id",
            label: "Workspace",
            hint: "Workspace that form belongs to",
            type: "string",
            control_type: "select",
            pick_list: "workspace_id"
          },
          {
            name: "search",
            label: "Form Name",
            hint: "Whole or partial form name to search for",
            type: "string"
          }
        ]
      end
    },

    forms: {
      fields: lambda do
        [
          { name: "id" },
          { name: "title" },
          { name: "last_updated_at", type: "timestamp" },
          {
            name: "self",
            type: "object",
            properties: [
              { name: "href" }
            ]
          },
          {
            name: "theme",
            type: "object",
            properties: [
              { name: "href" }
            ]
          },
          {
            name: "_links",
            type: "object",
            properties: [
              { name: "display" }
            ]
          }
        ]
      end
    }
  },

  actions: {
    search_forms: {
      subtitle: "Search forms",
      description: "Search <span class='provider'>forms</span> in " \
        "<span class='provider'>Typeform</span>",
      help: "Search will return a list of forms that matches " \
        "the search criteria.",
      input_fields: lambda do |object_definitions|
        object_definitions["get_forms"]
      end,

      execute: lambda do |_connection, input|
        response = get("https://api.typeform.com/forms").
                   params(search: input["search"],
                          page_size: 200,
                          workspace_id: input["workspace_id"])

        {
          forms: response["items"]
        }
      end,

      output_fields: lambda do |object_definitions|
        [
          {
            name: "forms",
            type: "array",
            of: "object",
            properties: object_definitions["forms"]
          }
        ]
      end
    }
  },

  triggers: {
    new_form: {
      # Results are listed in descending order based on the modified date.
      type: :paging_desc,

      description: "New <span class='provider'>Form</span> " \
        "in <span class='provider'>Typeform</span>",
      subtitle: "New form in Typeform",

      input_fields: lambda do
      end,

      poll: lambda do |_connection, _input, closure|
        closure ||= 1
        per_page = 100

        forms = get("https://api.typeform.com/forms").
                params(page_size: per_page,
                       page: closure)

        {
          events: forms["items"] || [],
          next_page: forms.length >= per_page ? closure + 1 : nil
        }
      end,

      dedup: lambda do |forms|
        if forms.present?
          forms["id"]
        else
          []
        end
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["forms"]
      end
    }
  },

  pick_lists: {
    workspace_id: lambda do |_connection|
      get("https://api.typeform.com/workspaces")["items"].
        map { |workspace_id| [workspace_id["name"], workspace_id["id"]] }
    end
  }
}
