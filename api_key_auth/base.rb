{
  title: "BaseCRM",

  connection: {
    fields: [
      {
        name: "api_key",
        control_type: "password",
        optional: false,
        label: "API key"
      }
    ],
    authorization: {
      type: "api_key",

      credentials: lambda do |connection|
        headers("Authorization": "Bearer " + connection["api_key"])
      end
    }
  },

  object_definitions: {
    lead: {
      fields: lambda do
        [
          { name: "id", type: :integer, label: "Lead id",
            control_type: :number },
          { name: "creator_id", type: :integer, label: "Created by(User ID)",
            control_type: :number },
          { name: "owner_id", type: :integer, label: "Owner id",
            control_type: :number },
          { name: "first_name" },
          { name: "last_name" },
          { name: "organization_name" },
          { name: "title" },
          { name: "description" },
          { name: "industry" },
          { name: "website", type: :string, control_type: :url },
          { name: "email", type: :string, control_type: :email },
          { name: "phone", type: :string, control_type: :phone },
          { name: "mobile", type: :string, control_type: :phone },
          { name: "fax", type: :string, control_type: :phone },
          { name: "twitter" },
          { name: "facebook" },
          { name: "linkedin" },
          { name: "skype" },
          { name: "address", type: :object, properties: [
            { name: "line1" },
            { name: "city" },
            { name: "postal_code" },
            { name: "state" },
            { name: "country" }
          ]},
          { name: "created_at", type: :date_time, control_type: :timestamp },
          { name: "updated_at", type: :date_time, control_type: :timestamp }
        ]
      end
    },

  },

  test: ->(connection) {
    get("https://api.getbase.com/v2/users/self")
  },

  actions: {
    search_leads: {
      description: 'Search <span class="provider">Leads</span> in
        <span class="provider">Base CRM</span>',
      subtitle: "Search leads in Base CRM",
      help: "Search will only return leads matching all inputs",
      input_fields: lambda do |object_definitions|
        [
          { name: "ids", type: :string, control_type: :text, label: "Id's",
            hint: "Comma-separated list of lead IDs." },
          { name: "address[city]", type: :string, control_type: :text,
            label: "City name" },
          { name: "address[postal_code]", type: :string, control_type: :text,
            label: "Zip/postal code" },
          { name: "address[state]", type: :string, control_type: :text,
            label: "State/region name" },
          { name: "address[country]", type: :string, control_type: :text,
            label: "Country name" }
        ].concat(object_definitions["lead"].only("creator_id", "owner_id",
          "source_id", "first_name", "last_name", "organization_name",
          "status", "email", "phone", "mobile"))
      end,
      execute: lambda do |connection, input|
        params = input.map do |key, value|
          "#{key}=#{value}"
        end.join("&")
        result = get("https://api.getbase.com/v2/leads?" + params)["items"]
        leads = result.pluck("data")
        {
          leads: leads
        }
      end,
      output_fields: ->(object_definitions) {
        [
          { name: "leads", type: :array, of: :object,
            properties: object_definitions["lead"] }
        ]
      },
      sample_output: lambda do
        {
          leads:
          [ get("https://api.getbase.com/v2/leads")["items"].dig(0, "data") ]
        }
      end
    },
    create_lead: {
      description:
       'Create <span class="provider">Lead</span> in <span class="provider">Base CRM</span>',
      subtitle: "Create lead in Base CRM",
      input_fields: lambda do |object_definitions|
        object_definitions["lead"].required("last_name", "organization_name").
          ignored("id", "creator_id", "created_at", "updated_at", "owner_id")
      end,
      execute: lambda do |connection, input|
        url = "https://api.getbase.com/v2/leads"
        lead = post(url).payload(data: input)["data"]
        {
          lead: lead
        }
      end,
      output_fields: ->(object_definitions) {
        [
          {
            name: "lead", type: :object, label: "Lead",
            properties: object_definitions["lead"]
          }
        ]
      },
      sample_output: lambda do
        {
          lead:
          get("https://api.getbase.com/v2/leads", per_page: 1)["items"].
            dig(0, "data") || {}
        }
      end
    }
  }

}
