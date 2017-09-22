{
  title: 'Base',

  connection: {
    fields: [
      {
        name: 'api_key',
        control_type: 'password',
        optional: false,
        label: 'Personal Access Token'
      }
    ],

    authorization: {
      type: "api_key",

      credentials: lambda do |connection|
        headers("Authorization": "Bearer " +connection["api_key"])
      end
    }
  },


  object_definitions: {
    lead: {
      fields: ->(){
        [
          {name: 'id', type: :integer, label: 'Lead ID', control_type: :number},
          {name: 'creator_id', type: :integer, label: 'Created By ID', control_type: :number},
          {name: 'owner_id', type: :integer, label: 'Owner ID', control_type: :number},
          {name: 'first_name', type: :string, label: 'First Name', control_type: :text},
          {name: 'last_name', type: :string, label: 'Last Name', control_type: :text},
          {name: 'organization_name', type: :string, label: 'Organization Name', control_type: :text},
          {name: 'status', type: :string, control_type: :text},
          {name: 'source_id', type: :integer, control_type: :text},
          {name: 'title', type: :string, control_type: :text},
          {name: 'description', type: :string, control_type: :text},
          {name: 'industry', type: :string, control_type: :text},
          {name: 'website', type: :string, control_type: :url},
          {name: 'email', type: :string, control_type: :email},
          {name: 'phone', type: :string, control_type: :phone},
          {name: 'mobile', type: :string, control_type: :phone},
          {name: 'fax', type: :string, control_type: :phone},
          {name: 'twitter', type: :string, control_type: :text},
          {name: 'facebook', type: :string, control_type: :text},
          {name: 'linkedin', type: :string, control_type: :text},
          {name: 'skype', type: :string, control_type: :text},
          {name: 'address', type: :object, properties: [
             {name: 'line1', type: :string, control_type: :text},
             {name: 'city', type: :string, control_type: :text},
             {name: 'postal_code', type: :string, control_type: :text},
             {name: 'state', type: :string, control_type: :text},
             {name: 'country', type: :string, control_type: :text}
          ]},
          {name: 'tags', type: :array, of: :string},
          {name: 'custom_fields', type: :object, properties: [
             {name: 'known_via', type: :string, control_type: :text}
          ]},
          {name: 'created_at', type: :date_time, control_type: :timestamp},
          {name: 'updated_at', type: :date_time, control_type: :timestamp}
        ]
      }
    },

  },

  test: ->(connection) {
    get("https://api.getbase.com/v2/users/self")
  },

  actions: {

    self: {
      input_fields: ->() {

      },
      execute: ->(connection, input) {
        get("https://api.getbase.com/v2/users/self") ['data']
      },
      output_fields: ->() {
        [ {name: 'id', type: :integer},
          {name: 'name', type: :string, label: 'Name'},
          {name: 'email', type: :string, control_type: :text},
          {name: 'created_at', type: :datetime, control_type: :timestamp},
          {name: 'updated_at', type: :datetime, control_type: :timestamp},
          {name: 'confirmed', type: :boolean},
          {name: 'role', type: :string},
          {name: 'status', type: :string}
          ]
      }
    },
    search_leads: {
      description: 'Search <span class="provider">Leads</span> in <span class="provider">BASE</span>',
      subtitle: 'Search leads in BASE',
      help: 'Selection of mutliple search fields will fetch results based on AND condition',
      input_fields: ->(object_definitions) {
        [
          {name: 'ids', type: :string, control_type: :text, label: "Id's",
           hint: 'Comma-separated list of lead IDs to be returned in a request.'},
          {name: 'creator_id', type: :integer, control_type: :number, label: 'Created By(User ID)',
           hint: 'Returns all leads created by that user.'},
          {name: 'owner_id', type: :integer, control_type: :number, label: 'Owner ID', hint: 'User ID. Returns all leads owned by that user.'},
          {name: 'source_id', type: :integer, control_type: :number, hint: "Id of the Source."},
          {name: 'first_name', type: :string, control_type: :text, label: 'First Name'},
          {name: 'last_name', type: :string, control_type: :text, label: 'Last Name'},
          {name: 'organization_name', type: :string, control_type: :text, label: 'Organization Name'},
          {name: 'status', type: :string, control_type: :text, label: 'Status of the lead'},
          {name: 'email', type: :string, control_type: :email, label: 'Email'},
          {name: 'phone', type: :string, control_type: :phone, label: 'Phone'},
          {name: 'mobile', type: :string, control_type: :phone, label: 'Mobile'},
          {name: 'address[city]', type: :string, control_type: :text, label: 'City Name'},
          {name: 'address[postal_code]', type: :string, control_type: :text, label: 'Zip/Postal Code'},
          {name: 'address[state]', type: :string, control_type: :text, label: 'State/region name'},
          {name: 'address[country]', type: :string, control_type: :text, label: 'Country name'}
        ]
      },
      execute: ->(connection, input) {
        params = input.map do |key, value|
          "#{key}=#{value}"
        end.join('&')
        leads_result = get("https://api.getbase.com/v2/leads?"+params)['items']

        leads = leads_result.map do |lead|
          lead['data']
        end unless leads_result.blank?
        {
          leads: leads
        }
      },
      output_fields: ->(object_definitions) {
        [
          {name: 'leads', type: :array, of: :object, properties: object_definitions['lead']}
        ]
      },
      sample_output: ->(connection, object_definitions){
        leads = []
        lead = get("https://api.getbase.com/v2/leads")['items']&.first['data'] || {}
        leads << lead
        {
          leads: leads
        }
      }
    },
    create_lead: {
      description: 'Create <span class="provider">Lead</span> in <span class="provider">BASE</span>',
      subtitle: 'Create lead in BASE',
      input_fields: ->(object_definitions) {
        object_definitions['lead'].required('last_name', 'organization_name').ignored('created_at', 'updated_at')
      },
      execute: ->(connection, input) {
        lead = post("https://api.getbase.com/v2/leads").payload(data: input)['data']
        {
          lead: lead
        }
      },
      output_fields: ->(object_definitions){
        [
          {name: 'lead', type: :object, label: 'Lead', properties: object_definitions['lead']}
        ]
      },
      sample_output: ->(connection, object_definitions){
        {
          lead: get("https://api.getbase.com/v2/leads")['items']&.first['data'] || {}
        }
      }
    }

  },

  triggers: {

  },

  pick_lists: {

  }
}
