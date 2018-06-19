{
  title: 'Intercom SDK',

  connection: {
    fields: [
      {
        name: 'client_id',
        label: 'Client ID',
        hint: 'You can find your client ID in the settings page.',
        optional: false
      },
      {
        name: 'client_secret',
        label: 'Client Secret',
        control_type: 'password',
        hint: 'You can find your client ID in the settings page.',
        optional: false
      }
    ],

    authorization: {
      type: 'oauth2',

      authorization_url: lambda { |connection|
        "https://app.intercom.io/oauth?client_id=#{connection["client_id"]}"
      },

      token_url: lambda { |connection|
        "https://api.intercom.io/auth/eagle/token?" \
          "client_id=#{connection['client_id']}&" \
          "client_secret=#{connection['client_secret']}"
      },

      apply: lambda { |_connection, access_token|
        headers("Authorization": "Bearer #{access_token}")
      }
    }

  },

  test: ->(_connection) { get("https://api.intercom.io/users/") },#.params(email: "kohro.shimizu@workato.com").request_format_www_form_urlencoded },

  object_definitions: {
    user: {
      fields: lambda do
        [
          { name: 'type' },
          { name:'id'},
          { name:'user_id'},
          { name:'email', control_type: 'email'},
          { name:'name'},
          { name:'app_id' },
          { name:'last_seen_ip'},
          { name:'unsubscribed_from_emails', type: :boolean},
          { name:'created_at', type: :integer },
          { name:'last_request_at', type: :integer },
          { name:'remote_created_at', type: :integer },
          { name:'signed_up_at', type: :integer },
          { name:'updated_at', type: :integer },
          { name:'session_count', type: :integer },
          { name:'user_agent_data'},
          { name:'referrer', control_type: 'url' },
          { name:'utm_campaign', label: "UTM Campaign" },
          { name:'utm_source', label: "UTM Source" },
          { name:'utm_content', label: "UTM Content" },
          { name:'utm_term', label: "UTM Term" },
          { name:'utm_medium', label: "UTM Medium" },
          { name: 'custom_attributes', type: :object, properties:
            [
              { name: 'phone', control_type: 'phone'},
              { name: 'job_role'},
              { name: 'company_size'},
              { name: 'mixpanel_id'},
              { name: 'precreated_app_id'},
              { name: 'invitation_id', type: :integer},
              { name: 'account_id', type: :integer},
              { name:'mobile_app_signup', type: :boolean},
              { name: 'type'},
              { name: 'confirmed_at', type: :integer},
              { name: 'sign_in_count', type: :integer},
              { name: 'handle'},
              { name: 'time_zone'},
              { name: 'company_name'},
              { name: 'twitter_url'},
              { name: 'linkedin_url'},
              { name: 'website_url'},
              { name: 'applications'},
              { name: 'connectors_names'},
              { name: 'apps_connected'},
              { name: 'connectors_count', type: :integer},
              { name: 'connectors_used', type: :integer},
              { name: 'app_ids'},
              { name: 'recipe_tour_completed', type: :boolean},
              { name: 'plan'},
              { name: 'in_trial', type: :boolean},
              { name: 'stripe_id'},
              { name: 'stripe_plan'},
              { name: 'stripe_plan_price', type: :integer},
              { name: 'stripe_delinquent', type: :boolean},
              { name: 'stripe_account_balance', type: :integer},
              { name: 'stripe_plan_interval'},
              { name: 'stripe_subscription_status'},
              { name: 'stripe_card_brand'},
              { name: 'stripe_subscription_period_start_at', type: :integer},
              { name: 'stripe_card_expires_at', type: :integer},
              { name: 'stripe_last_charge_amount', type: :integer},
              { name: 'stripe_last_charge_at', type: :integer},
              { name: 'recipe_count', type: :integer},
              { name: 'active_recipe_count', type: :integer},
              { name: 'start_failed_count', type: :integer},
              { name: 'start_succeeded_count', type: :integer},
              { name: 'jobs_all_success_count', type: :integer},
              { name: 'jobs_all_failure_count', type: :integer},
              { name: 'jobs_month_success_count', type: :integer},
              { name: 'jobs_month_failure_count', type: :integer},
              { name: 'jobs_month_total_count', type: :integer},
              { name: 'total_unread_count', type: :integer},
              { name: 'xapp_0_instance_id', type: :integer},
              { name: 'xapp_0_name'},
              { name: 'xapp_0_installed_at', type: :integer},
              { name: 'xapp_1_instance_id', type: :integer},
              { name: 'xapp_1_name'},
              { name: 'xapp_1_installed_at', type: :integer},
              { name: 'utm_source'},
              { name: 'nps_sent'},
              { name: 'nps_latest_sent_date_at'},
              { name: 'nps_complete'},
              { name: 'salesforce_record_id'}
            ]
          },
          { name: 'avatar', type: :object, properties:
            [
              { name: 'type'},
              { name: 'image_url', control_type: 'url'}
            ]
          },
          { name: 'location_data', type: :object, properties:
            [
              { name: 'type'},
              { name: 'city_name'},
              { name: 'continent_code'},
              { name: 'country_code'},
              { name: 'country_name'},
              { name: 'latitude', type: :decimal},
              { name: 'longitude', type: :decimal},
              { name: 'postal_code'},
              { name: 'region_name'},
              { name: 'timezone'}
            ]
          },
          { name: 'social_profiles', type: :object, properties:
            [
              { name: 'type'},
              { name: 'social_profiles', type: :array, properties:
                [
                  { name: 'name'},
                  { name: 'id'},
                  { name: 'username'},
                  { name: 'url', control_type: 'url'}
                ]
              }
            ]
          },
          { name: 'companies', type: :object, properties:
            [
              { name: 'type'},
              { name: 'companies', type: :array, properties:
                [
                  { name: 'id'},
                  { name: 'company_id'},
                  { name: 'name'}
                ]
              }
            ]
          },
          { name: 'segments', type: :object, properties:
            [
              { name: 'type'},
              { name: 'segments', type: :array, properties:
                [
                  { name: 'type'},
                  { name: 'id'}
                ]
              }
            ]
          },
          { name: 'tags', type: :object, properties:
            [
              { name: 'type'},
              { name: 'tags', type: :array, properties:
                [
                  { name: 'type'},
                  { name: 'name'},
                  { name: 'id'}
                ]
              }
            ]
          }
        ]
      end
    },
    
    user_2: {
      fields: lambda do
        [
          { name: 'type' },
          { name:'id'},
          { name:'user_id'},
          { name:'email', control_type: 'email'},
          { name:'name'},
          { name:'app_id' },
          { name:'last_seen_ip'},
          { name:'unsubscribed_from_emails', type: :boolean},
          { name:'created_at', type: :date_time },
          { name:'last_request_at', type: :date_time },
          { name:'remote_created_at', type: :date_time },
          { name:'signed_up_at', type: :date_time },
          { name:'updated_at', type: :date_time },
          { name:'session_count', type: :integer },
          { name:'user_agent_data'},
          { name:'referrer', control_type: 'url' },
          { name:'utm_campaign', label: "UTM Campaign" },
          { name:'utm_source', label: "UTM Source" },
          { name:'utm_content', label: "UTM Content" },
          { name:'utm_term', label: "UTM Term" },
          { name:'utm_medium', label: "UTM Medium" },
          { name: 'custom_attributes', type: :object, properties:
            [
              { name: 'phone', control_type: 'phone'},
              { name: 'job_role'},
              { name: 'company_size'},
              { name: 'mixpanel_id'},
              { name: 'precreated_app_id'},
              { name: 'invitation_id', type: :integer},
              { name: 'account_id', type: :integer},
              { name:'mobile_app_signup', type: :boolean},
              { name: 'type'},
              { name: 'confirmed_at', type: :date_time},
              { name: 'sign_in_count', type: :integer},
              { name: 'handle'},
              { name: 'time_zone'},
              { name: 'company_name'},
              { name: 'twitter_url'},
              { name: 'linkedin_url'},
              { name: 'website_url'},
              { name: 'applications'},
              { name: 'connectors_names'},
              { name: 'apps_connected'},
              { name: 'connectors_count', type: :integer},
              { name: 'connectors_used', type: :integer},
              { name: 'app_ids'},
              { name: 'recipe_tour_completed', type: :boolean},
              { name: 'plan'},
              { name: 'in_trial', type: :boolean},
              { name: 'stripe_id'},
              { name: 'stripe_plan'},
              { name: 'stripe_plan_price', type: :integer},
              { name: 'stripe_delinquent', type: :boolean},
              { name: 'stripe_account_balance', type: :integer},
              { name: 'stripe_plan_interval'},
              { name: 'stripe_subscription_status'},
              { name: 'stripe_card_brand'},
              { name: 'stripe_subscription_period_start_at', type: :integer},
              { name: 'stripe_card_expires_at', type: :date_time},
              { name: 'stripe_last_charge_amount', type: :integer},
              { name: 'stripe_last_charge_at', type: :date_time},
              { name: 'recipe_count', type: :integer},
              { name: 'active_recipe_count', type: :integer},
              { name: 'start_failed_count', type: :integer},
              { name: 'start_succeeded_count', type: :integer},
              { name: 'jobs_all_success_count', type: :integer},
              { name: 'jobs_all_failure_count', type: :integer},
              { name: 'jobs_month_success_count', type: :integer},
              { name: 'jobs_month_failure_count', type: :integer},
              { name: 'jobs_month_total_count', type: :integer},
              { name: 'total_unread_count', type: :integer},
              { name: 'xapp_0_instance_id', type: :integer},
              { name: 'xapp_0_name'},
              { name: 'xapp_0_installed_at', type: :date_time},
              { name: 'xapp_1_instance_id', type: :integer},
              { name: 'xapp_1_name'},
              { name: 'xapp_1_installed_at', type: :date_time},
              { name: 'utm_source'},
              { name: 'nps_sent'},
              { name: 'nps_latest_sent_date_at', type: :date_time},
              { name: 'nps_complete'},
              { name: 'salesforce_record_id'}
            ]
          },
          { name: 'avatar', type: :object, properties:
            [
              { name: 'type'},
              { name: 'image_url', control_type: 'url'}
            ]
          },
          { name: 'location_data', type: :object, properties:
            [
              { name: 'type'},
              { name: 'city_name'},
              { name: 'continent_code'},
              { name: 'country_code'},
              { name: 'country_name'},
              { name: 'latitude', type: :decimal},
              { name: 'longitude', type: :decimal},
              { name: 'postal_code'},
              { name: 'region_name'},
              { name: 'timezone'}
            ]
          },
          { name: 'social_profiles', type: :object, properties:
            [
              { name: 'type'},
              { name: 'social_profiles', type: :array, properties:
                [
                  { name: 'name'},
                  { name: 'id'},
                  { name: 'username'},
                  { name: 'url', control_type: 'url'}
                ]
              }
            ]
          },
          { name: 'companies', type: :object, properties:
            [
              { name: 'type'},
              { name: 'companies', type: :array, properties:
                [
                  { name: 'id'},
                  { name: 'company_id'},
                  { name: 'name'}
                ]
              }
            ]
          },
          { name: 'segments', type: :object, properties:
            [
              { name: 'type'},
              { name: 'segments', type: :array, properties:
                [
                  { name: 'type'},
                  { name: 'id'}
                ]
              }
            ]
          },
          { name: 'tags', type: :object, properties:
            [
              { name: 'type'},
              { name: 'tags', type: :array, properties:
                [
                  { name: 'type'},
                  { name: 'name'},
                  { name: 'id'}
                ]
              }
            ]
          }
        ]
      end
    },

    company: {
      fields: lambda do
        [
          { name: 'id'},
          { name: 'company_id'},
          { name: 'created_at', type: "integer" },
          { name: 'updated_at', type: "integer" },
          { name: 'monthly_spend', type: "integer" },
          { name: 'name'},
          { name: 'plan'}
        ]
      end
    },

    admin: {
      fields: lambda do
        [
         { name: 'id'},
         { name: 'type'},
         { name: 'email', control_type: 'email'},
         { name: 'name'}
        ]
      end
    },

    user_tag: {
      fields: lambda do
        [
            { name: 'name'},
            { name: 'id'}
        ]
      end
    },

    segment: {
      fields: lambda do
        [
            { name: 'id'},
            { name: 'name'},
            { name: 'created_at', type: 'integer'},
            { name: 'updated_at', type: 'integer'}
        ]
      end
    },

    conversation: {
      fields: lambda do
        [
          { name: 'id'},
          { name: 'created_at', type: 'integer'},
          { name: 'updated_at', type: 'integer'},
          { name: 'conversation_message', type: 'object', properties:
            [
              { name: 'body' },
              { name: 'author', type: 'object', properties:
                [
                  { name: 'id' }

                ]
              },
            ]
          },
          { name: 'user', type: 'object', properties:
            [
              { name: 'id' }
            ]
          },
          { name: 'assignee', type: 'object', properties:
            [
              { name: 'id' }
            ]
          },
          { name: 'open', type: 'boolean' },
          { name: 'read', type: 'boolean' }
        ]
      end
    },

    event: {
      fields: lambda do
        [
          {
            control_type: "text",
            label: "Type",
            type: "string",
            name: "type"
          },
          {
            control_type: "text",
            label: "ID",
            type: "string",
            name: "id"
          },
          {
            control_type: "text",
            label: "Intercom ID",
            type: "string",
            name: "intercom_user_id"
          },
          {
            control_type: "email",
            label: "Email",
            type: "string",
            name: "email"
          },
          {
            control_type: "text",
            label: "Event name",
            type: "string",
            name: "event_name"
          },
          {
            control_type: "integer",
            label: "Created at",
            parse_output: "integer_conversion",
            type: "integer",
            name: "created_at"
          },
          {
            control_type: "text",
            label: "User ID",
            type: "string",
            name: "user_id"
          },
          {
            controL_type: "text",
            label: "Metadata",
            type: "string",
            name: "metadata"
          }
        ]
      end
    },
    
    event_summary: {
      fields: lambda do
        [
          {
            control_type: "text",
            label: "Intercom ID",
            type: "string",
            name: "intercom_user_id"
          },
          {
            control_type: "email",
            label: "Email",
            type: "string",
            name: "email"
          },
          {
            control_type: "text",
            label: "User ID",
            type: "string",
            name: "user_id"
          },
          {
            name: "events",
            type: "array",
            of: "object",
            properties: [
              { name: "name" },
              { 
                name: "first", type: "date_time", control_type: "date_time", 
                render_input: "date_time_conversion", parse_output: "date_time_conversion"
              },
              { 
                name: "last", type: "date_time", control_type: "date_time", 
                render_input: "date_time_conversion", parse_output: "date_time_conversion"
              },
              { 
                name: "count", type: "integer", control_type: "integer", 
                render_input: "integer_conversion", parse_output: "integer_conversion"
              },
              { name: "description" }
            ]
          }
        ]
      end
    }
  },

  actions: {
    # search_user: {
      # description: 'Search <span class="provider">User</span> in <span class="provider">Intercom</span>',
      # help: "Search for a user in Intercom using either ID, user ID or email address.",

      # input_fields: lambda do
        # [
          # {
            # name: 'id',
            # hint: 'Intercom internal ID'
          # },
          # {
            # name: 'user_id',
            # type: 'integer',
            # control_type:'number',
            # hint: 'Workato User ID'
          # },
          # {
            # name: 'email',
            # control_type: 'email',
            # hint: 'Email Address'
          # }
        # ]
      # end,

      # execute: lambda do |connection, input|
        # if input['id'].present?
          # response = get("https://api.intercom.io/users/#{input['id']}")
        # elsif input['user_id'].present?
           # response = get("https://api.intercom.io/users?user_id=" + input['user_id'])
        # else
          # response = get("https://api.intercom.io/users?", email: input['email'])
        # end
      # end,

      # output_fields: lambda do |object_definitions|
        # object_definitions['user']
      # end
    # },

    create_update_user: {
      description: "Create/Update <span class=\"provider\">User</span> in <span class=\"provider\">Intercom</span>",
      subtitle: "Create/Update user in Intercom",
      help: "Creates a user if user ID doesn't exist in Intercom, and updates if it does.",

      input_fields: lambda do |object_definitions|
        object_definitions["user"].
          ignored("id","created_at","updated_at","user_id","email").
          concat(
            [
              {
                name: "email", label: "Email", type: "string", control_type: "email", toggle_hint: "Enter email", optional: false,
                toggle_field: {
                  label: "User ID", control_type: "text", toggle_hint: "Enter user ID", hint: "Enter a user ID from Intercom.",
                  type: "string", name: "user_id", optional: false
                }
              }
            ]
          )
      end,

      execute: lambda do |connection, input|
        data = input.reject{ |k,v| v == nil }
        post("https://api.intercom.io/users").
          payload(data)
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["user"].only("id")
      end
    },

    get_admin_by_id: {
      description: "Get <span class=\"provider\">Admin</span> by ID in <span class=\"provider\">Intercom</span>",
      subtitle: "Get admin by ID in Intercom",
      help: "Retrieves an admin in Intercom using the internal admin ID.",

      input_fields: lambda do
        { name: 'admin_id', optional: false }
      end,

      execute: lambda do |connection, input|
        admins = get("https://api.intercom.io/admins/#{input['admin_id']}")
      end,

      output_fields: lambda do |object_definitions|
        object_definitions['admin']
      end
    },

    reply_to_conversation_as_admin: {
      input_fields: lambda do
        [
          { name: 'conversation_id', type: 'integer' },
          {
            control_type: "select", pick_list: "admins", label: "Admin", hint: "Select an admin in Intercom.",
            toggle_hint: "Select from list", type: "string", name: "admin_id", optional: false,
            toggle_field: {
              label: "Admin ID", control_type: "text", toggle_hint: "Enter assignee ID", hint: "Enter an admin ID from Intercom.",
              type: "string", name: "admin_id", optional: false
            }
          },
          { name: 'body' }
        ]
      end,

      execute: lambda do |connection, input|
        payload = {
          'type': 'admin',
          'message_type': 'comment',
          'admin_id': input['admin_id'],
          'body': input['body']
        }
        post("https://api.intercom.io/conversations/#{input['conversation_id']}/reply", payload)
      end,

      output_fields: lambda do |object_definitions|
        object_definitions['conversation']
      end
    },

    tag_user: {
      input_fields: lambda do
        [
          { name: 'user_id', label: 'User ID', optional: false },
          { name: 'tag_name', label: 'Tag Name', optional: false }
        ]
      end,

      execute: lambda do |connection, input|
        payload = {
          'name': input['tag_name'],
          'users': [
            {
              'user_id': input['user_id']
            }
          ]
        }
        post("https://api.intercom.io/tags", payload)
      end,

      output_fields: lambda do |object_definitions|
        object_definitions['user_tag']
      end
    },

    assign_conversation: {
      input_fields: lambda do
        [
          { name: 'conversation_id', label: 'Conversation ID', optional: false },
          {
            control_type: "select", pick_list: "admins", label: "Assignee", hint: "Select a user to assign this conversation to.",
            toggle_hint: "Select from list", type: "string", name: "admin", optional: false,
            toggle_field: {
              label: "Assignee ID", control_type: "text", toggle_hint: "Enter assignee ID", hint: "Enter an admin ID from Intercom.",
              type: "string", name: "admin_id", optional: false
            }
          }
        ]
      end,

      execute: lambda do |connection, input|
        payload = {
          'type': 'admin',
          'message_type': 'assignment',
          'admin_id': 469054,
          'assignee_id': (input['admin_id'] || input['admin'])
        }
        post("https://api.intercom.io/conversations/#{input['conversation_id']}/reply").
          payload(payload)
      end,

      output_fields: lambda do |object_definitions|
      end
    },

    search_company: {
      input_fields: lambda do
        [
          {
            control_type: "text", label: "Company Name", toggle_hint: "Search by company name", hint: "Enter an company name to search with.",
            type: "string", name: "name", optional: false,
            toggle_field: {
              label: "Company ID", control_type: "text", toggle_hint: "Search by company ID", hint: "Enter a company ID.",
              type: "string", name: "company_id", optional: false
            }
          }
        ]
      end,

      execute: lambda do |connection, input|
        if input["name"].present?
          get("https://api.intercom.io/companies").
            params(name: input["name"])
        elsif input["company_id"].present?
          get("https://api.intercom.io/companies").
            params(company_id: input["company_id"])
        end
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["company"]
      end
    },

    create_or_update_company: {
      help: "Creates a company if Company ID doesn't exist in Intercom, and updates if it does.",

      input_fields: lambda do |object_definitions|
        object_definitions["company"].
          ignored("id","created_at","updated_at").
          required("company_id","name")
      end,

      execute: lambda do |connection, input|
        data = input.reject{ |k,v| v == nil }
        post("https://api.intercom.io/companies").
          payload(data)
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["company"]
      end
    },

    get_fields: {
      execute: lambda do |connection|
        response = get("https://api.intercom.io/data_attributes/customer")["data_attributes"]
        top_level = response.select{ |field| field["full_name"].include?(".") == false }.map{ |field|
          {
            name: field["name"],
            label: field["label"],
            hint: field["description"],
            type: (field["data_type"] == "float" ? "number" : field["data_type"]),
            control_type: (field["data_type"] == "float" ? "number" : field["data_type"])
          }
        }
        location_data = { 
          location_data: response.select{ |field| field["full_name"].include?("location_data.") }.map{ |field|
            {
              name: field["name"],
              label: field["label"],
              hint: field["description"],
              type: (field["data_type"] == "float" ? "number" : field["data_type"]),
              control_type: (field["data_type"] == "float" ? "number" : field["data_type"])
            }
          }
        }
        puts top_level.concat([location_data])
      end
    },
    
    list_admins: {
      execute: lambda do |connection|
        response = get("https://api.intercom.io/admins")
        {
          admins: response["admins"]
        }
      end,
      
      output_fields: lambda do |object_definitions|
        [
          { name: "admins", type: "array", of: "object", properties: object_definitions["admin"] }
        ]
      end
    },
    
    get_user_event_summary: {
      input_fields: lambda do
        [
          { 
            name: "user_id", label: "User ID", type: "integer", control_type: "integer", sticky: true, toggle_hint: "Enter user ID",
            toggle_field: {
              name: "email", label: "Email", type: "string", control_type: "email", sticky: true, toggle_hint: "Enter email",
            }
          },
          { name: "intercom_user_id", label: "Intercom ID", type: "string", control_type: "text", sticky: true }
        ]
      end,
      
      execute: lambda do |connection, input|
        response = get("https://api.intercom.io/events?type=user&summary=true").
          params(input)
      end,
      
      output_fields: lambda do |object_definitions|
        object_definitions["event_summary"]
      end
    },
	test: {
      input_fields: lambda do
        [
          { name: 'sort_by', label: 'Sort By', control_type: 'select', pick_list: 'sort_order', optional: false},
          {
            control_type: "select", pick_list: "segments", label: "Segment", hint: "Select a segment.",
            toggle_hint: "Select from list", type: "string", name: "segment_pick_id", optional: false,
            toggle_field: {
              label: "Segment ID", control_type: "text", toggle_hint: "Use segment ID", hint: "Enter a segment ID.",
              type: "string", name: "segment_id", optional: false
              }
            }
          ]
      end,

      execute: lambda do |connection, input|
        response = get("https://api.intercom.io/users").
          params(segment_id: input['segment_pick_id'] || input['segment_id'],
            sort: input["sort_by"],
            page: 1,
            order: "desc",
            per_page: 50)
        users = response['users']
        pages = response['pages']

        {
          events: users,
          next_page: pages['next']
          }
        puts response["users"].pluck("created_at")
      end,
      }
  },

  triggers: {
	# new_conversation: {
      # description: 'New <span class="provider">Conversation</span> in <span class="provider">Intercom</span>',
      # subtitle: "New conversation in Intercom",
      # help: "Trigger will pick up past trigger events from the specified date time when recipe is first started. Subsequently, trigger will fetch trigger events in real-time as soon as they occur. This trigger automatically creates a webhook that can be found in your Intercom developer hub.",

      # type: "paging_desc",

      # input_fields: lambda do
        # {
          # name: "from", label: "From", type: "date_time", control_type: "date_time", sticky: true,
          # hint: "Fetch trigger events from specified time. <b>Once recipe has been run or tested, value cannot be changed.</b>",
          # render_input: "date_time_conversion", parse_output: "date_time_conversion"
        # }
      # end,

      # poll: lambda do |connection, input, next_page|
        # if input["from"].present?
          # from = input["from"].to_i
          # page = next_page

          # if page.blank?
            # response = get("https://api.intercom.io/conversations").
            # params(sort: "desc", order: "created_at", per_page: 50)
          # else
            # response = get(page)
          # end
          # conversations = response['conversations'].reject{ |conversation| conversation["created_at"] > from }
          # if from <= conversations.pluck("created_at").min
            # next_url = response['pages']['next']
          # end
        # end
        # {
          # events: conversations,
          # next_page: next_url
        # }
      # end,

      # webhook_subscribe: lambda do |webhook_url, connection|
        # post("https://api.intercom.io/subscriptions").
          # payload(
             # topics: ["conversation.user.created"],
             # url: webhook_url)
      # end,

      # webhook_notification: lambda do |input, payload|
        # response = payload["data"]["item"]
        # if response["type"] != "ping"
         # response
        # end
      # end,

      # webhook_unsubscribe: lambda do |webhook|
        # delete("https://api.intercom.io/subscriptions/#{webhook['id']}")
      # end,

      # document_id: lambda do |message|
        # message["id"]
      # end,

      # sort_by: lambda do |message|
        # message["created_at"]
      # end,

      # output_fields: lambda do |object_definitions|
        # object_definitions["conversation"]
      # end
    # },

    new_or_updated_conversation: {
      description: 'New/Updated <span class="provider">Conversation</span> in <span class="provider">Intercom</span>',
      subtitle: "New/Updated conversation in Intercom",
      help: "Trigger will pick up past trigger events from the specified date time when recipe is first started. Subsequently, trigger will fetch trigger events in real-time as soon as they occur. This trigger automatically creates a webhook that can be found in your Intercom developer hub.",

      input_fields: lambda do
        {
          name: "since", label: "From", type: "date_time", control_type: "date_time", sticky: true,
          hint: "Fetch trigger events from specified time. Leave blank to retrieve since recipe start"
        }
      end,

      poll: lambda do |connection, input, next_poll|
        from = (input["since"] || Time.now).to_i
        page = next_poll

        if page.blank?
          response = get("https://api.intercom.io/conversations").
          params(order: "asc", sort: "updated_at", per_page: 50)
        else
          response = get(page)
        end
        conversations = response['conversations']
        conversations = response['conversations'].reject{ |conversation| conversation["updated_at"] < from }

        next_url = response.dig("pages","next") || nil
        {
          events: conversations,
          next_poll: next_url,
          can_poll_more: response.dig("pages","page").present? ? (response.dig("pages","page") < response.dig("pages","total_pages")) : false
        }
      end,

      webhook_subscribe: lambda do |webhook_url, connection|
        post("https://api.intercom.io/subscriptions").
          payload(
            topics: [
              "conversation.user.created",
              "conversation.user.replied",
              "conversation.admin.replied",
              "conversation.admin.single.created",
              "conversation.admin.assigned",
              "conversation.admin.noted",
              "conversation.admin.closed",
              "conversation.admin.opened"
            ],
            url: webhook_url)
      end,

      webhook_notification: lambda do |input, payload|
        response = payload["data"]["item"]
        if response["type"] != "ping"
         response
        end
      end,

      webhook_unsubscribe: lambda do |webhook|
        delete("https://api.intercom.io/subscriptions/#{webhook['id']}")
      end,

      dedup: lambda do |message|
        message["id"].to_s + "@" + message["updated_at"].to_s
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["conversation"]
      end
    },

    user_unsubscribed: {
      description: '<span class="provider">User Unsubscribed</span> in <span class="provider">Intercom</span>',
      help: "Trigger fetches trigger events in real-time as soon as they occur. This trigger automatically creates a webhook that can be found in your Intercom developer hub.",
      subtitle: "User unsubscribed in Intercom",

      input_fields: lambda do
      end,

      webhook_subscribe: lambda do |webhook_url, connection|
        post("https://api.intercom.io/subscriptions").
          payload(
             topics: ["user.unsubscribed"],
             url: webhook_url)
      end,

      webhook_notification: lambda do |input, payload|
        response = payload["data"]["item"]
        if response["type"] != "ping"
         response
        end
      end,

      webhook_unsubscribe: lambda do |webhook|
        delete("https://api.intercom.io/subscriptions/#{webhook['id']}")
      end,

      dedup: lambda do |message|
        message["id"] + "@" + message["updated_at"]
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["user"]
      end
    },

    new_updated_user_in_segment: {
      description: 'New/Updated <span class="provider">User</span> in <span class="provider">Intercom</span> segment',
      subtitle: "New/Updated user in Intercom segment",

      type: 'paging_desc',

      input_fields: lambda do
        [
          { name: 'sort_by', label: 'Sort By', control_type: 'select', pick_list: 'sort_order', optional: false},
          {
            control_type: "select", pick_list: "segments", label: "Segment", hint: "Select a segment.",
            toggle_hint: "Select from list", type: "string", name: "segment_pick_id", optional: false,
            toggle_field: {
              label: "Segment ID", control_type: "text", toggle_hint: "Use segment ID", hint: "Enter a segment ID.",
              type: "string", name: "segment_id", optional: false
            }
          }
        ]
      end,

      poll: lambda do |connection, input, next_page|
        page = next_page

        if page.blank?
          response = get("https://api.intercom.io/users").
          params(segment_id: input['segment_pick_id'] || input['segment_id'],
              sort: input["sort_by"],
              page: 1,
              order: "desc",
              per_page: 50)
        else
          response = get(page)
        end
        users = response['users']
        pages = response['pages']

        {
          events: users,
          next_page: pages['next']
        }
      end,

      document_id: lambda do |response|
          response["id"]
      end,

      # sort_by: lambda do |response|
	      # response["created_at"]
      # end,

      output_fields: lambda do |object_definitions|
          object_definitions['user']
      end
    },
    
    # new_user: {
      # description: 'New <span class="provider">User</span> in <span class="provider">Intercom</span>',
      # subtitle: "New user in Intercom",
      
      # input_fields: lambda do
        # [
          # { name: 'since', label: 'From', control_type: 'date_time', type: 'date_time', optional: true, sticky: true,
            # hint: 'Enter a date to retrieve users created after this date. Defaults to recipe start if not specified'}
        # ]
      # end,
      
      # webhook_subscribe: lambda do |webhook_url, connection|
        # post("https://api.intercom.io/subscriptions").
          # payload(
             # topics: ["user.created","contact.signed_up"],
             # url: webhook_url)
      # end,

      # webhook_notification: lambda do |input, payload|
        # response = payload
        # if response["type"] != "ping"
         # response["data"]["item"]
        # end
      # end,

      # webhook_unsubscribe: lambda do |webhook|
        # delete("https://api.intercom.io/subscriptions/#{webhook['id']}")
      # end,

      # poll: lambda do |connection, input, next_poll|
        # page = next_poll
        # since = input["since"].present? ? input["since"].to_i : Time.now.to_i
        # created_since_days = ((Time.now.to_i - since)/86400).to_i
		
        # if page.blank?
          # response = get("https://api.intercom.io/users").
          # params(
              # sort: "created_at",
              # page: 1,
              # order: "asc",
              # per_page: 60,
              # created_since: (created_since_days >= 1 ? created_since_days : 1)
            # )
        # else
          # response = get(page)
        # end
        # users = response['users']
        
        # if users.pluck("created_at").min >= since
          # next_page = response["pages"].present? ? response["pages"]['next'] : nil
        # else
          # users = users.reject{ |user| user["created_at"] < since }
          # next_page = nil
        # end
        
        # users = users.each do |u|
          # u.each do |k,v|
            # if k.ends_with?("_at") and v.present? and v.to_s.match?(/^[0-9]*$/)
              # u[k] = ("1970-01-01T00:00:00Z".to_time + v).iso8601
            # elsif k == "custom_attributes"
              # v.each do |ck,cv|
                # if ck.ends_with?("_at") and cv.present? and cv.to_s.match?(/^[0-9]*$/)
              	  # u["custom_attributes"][ck] = ("1970-01-01T00:00:00Z".to_time + cv).iso8601
                # end
              # end
            # end
          # end
        # end
        
        # {
          # events: users,
          # next_poll: next_page,
          # can_poll_more: next_page.present?
        # }
      # end,
      
      # dedup: lambda do |response|
        # response["id"].to_s + "@" + response["created_at"].to_s
      # end,

      # output_fields: lambda do |object_definitions|
        # object_definitions['user_2']
      # end
    # },

    admin_assigned_conversation: {
      description: '<span class="provider">Admin Assigned</span> in <span class="provider">Intercom</span>',
      help: "Trigger when a conversation is assigned to someone in intercom",
      subtitle: "Admin assigned to conversation in Intercom",

      input_fields: lambda do
      end,

      webhook_subscribe: lambda do |webhook_url, connection|
        post("https://api.intercom.io/subscriptions").
          payload(
             topics: ["conversation.admin.assigned"],
             url: webhook_url)
      end,

      webhook_notification: lambda do |input, payload|
        response = payload["data"]["item"]
        if response["type"] != "ping"
         response
        end
      end,

      webhook_unsubscribe: lambda do |webhook|
        delete("https://api.intercom.io/subscriptions/#{webhook['id']}")
      end,

      dedup: lambda do |message|
        message["id"]
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["conversation"]
      end
    },

    conversation_closed: {
      description: '<span class="provider">Conversation Closed</span> in <span class="provider">Intercom</span>',
      help: "Trigger when a conversation is closed in intercom",
      subtitle: "Admin closed a conversation in Intercom",

      input_fields: lambda do
      end,

      webhook_subscribe: lambda do |webhook_url, connection|
        post("https://api.intercom.io/subscriptions").
          payload(
             topics: ["conversation.admin.closed"],
             url: webhook_url)
      end,

       webhook_notification: lambda do |input, payload|
        response = payload["data"]["item"]
        if response["type"] != "ping"
         response
        end
      end,

      webhook_unsubscribe: lambda do |webhook|
        delete("https://api.intercom.io/subscriptions/#{webhook['id']}")
      end,

      dedup: lambda do |message|
        message["id"]
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["conversation"]
      end
    },

    conversation_opened: {
      description: '<span class="provider">Conversation Opened</span> in <span class="provider">Intercom</span>',
      help: "Trigger when a conversation is opened in intercom",
      subtitle: "Admin opened a conversation in Intercom",

      input_fields: lambda do
      end,

      webhook_subscribe: lambda do |webhook_url, connection|
        post("https://api.intercom.io/subscriptions").
          payload(
             topics: ["conversation.admin.opened"],
             url: webhook_url)
      end,

       webhook_notification: lambda do |input, payload|
        response = payload["data"]["item"]
        if response["type"] != "ping"
         response
        end
      end,

      webhook_unsubscribe: lambda do |webhook|
        delete("https://api.intercom.io/subscriptions/#{webhook['id']}")
      end,

      dedup: lambda do |message|
        message["id"]
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["conversation"]
      end
    },

    event_created: {
      description: '<span class="provider">Event</span> created in <span class="provider">Intercom</span>',
      help: "Trigger when an event is created in Intercom",

      input_fields: lambda do
        [
          {
            name: "event_names", type: "string", optional: false, hint: "Comma separated list of events to subscribe to."
          }
        ]
      end,

      webhook_subscribe: lambda do |webhook_url, connection, input|
        post("https://api.intercom.io/subscriptions").
          payload(
             topics: ["event.created"],
             url: webhook_url,
             metadata: {
               event_names: input["event_names"].split(",")
             }
          )
      end,

       webhook_notification: lambda do |input, payload|
        response = payload
        if response["type"] != "ping"
         response["data"]["item"]
        end
      end,

      webhook_unsubscribe: lambda do |webhook|
        delete("https://api.intercom.io/subscriptions/#{webhook['id']}")
      end,

      dedup: lambda do |message|
        message["id"]
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["event"]
      end
    }
  },

  pick_lists: {
    sort_order: lambda do
      [
        %W(#{"Created Date"} created_at),
        %W(#{"Last Request Date"} last_request_at),
		%W(#{"Sign Up Date"} signed_up_at),
        %W(#{"Updated Date"} updated_at)
      ]
    end,

    segments: lambda do |connection|
      response = get("https://api.intercom.io/segments?per_page=100")['segments'].
        map { |segment| [segment['name'], segment['id']] }
    end,

    admins: lambda do |connection|
      response = get("https://api.intercom.io/admins")['admins'].
        map { |admin| [admin['name'], admin['id']] }
    end
  },
  
  methods: {
    convert_timestamp: lambda do |user|
      response = user.each do |k,v|
        if k.ends_with?("_at")
          user[k] = v.to_time.to_i
        end
      end
    end
  }
}
