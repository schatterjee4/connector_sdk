# Adds operations missing from the standard adapter.
{
  title: "NationBuilder(custom)",
  connection: {
    fields: [
      {
        name: "sub_domain",
        label: "Nation slug",
        control_type: "subdomain",
        url: ".nationbuilder.com",
        optional: false,
        hint: "Your nation slug as found in your NationBuilder URL, e.g. " \
          "<b>votefornation</b>.nationbuilder.com"
      },
      {
        name: "client_id",
        hint: "Find it " \
          "<a href='https://workato.nationbuilder.com/admin/apps'>" \
          "here</a>",
        optional: false
      },
      {
        name: "client_secret",
        hint: "Find it " \
          "<a href='https://workato.nationbuilder.com/admin/apps'>" \
          "here</a>",
        optional: false,
        control_type: "password"
      }
    ],

    authorization: {
      type: "oauth2",

      authorization_url: lambda { |connection|
        "https://#{connection['sub_domain']}.nationbuilder.com/" \
          "oauth/authorize?response_type=code&client_id=" \
          "#{connection['client_id']}&redirect_uri=" \
          "https://www.workato.com/oauth/callback"
      },

      acquire: lambda { |connection, auth_code, redirect_uri|
        response = post("https://#{connection['sub_domain']}" \
                  ".nationbuilder.com/oauth/token") \
                   .payload(client_id: connection["client_id"],
                            redirect_uri: redirect_uri,
                            grant_type: "authorization_code",
                            client_secret: connection["client_secret"],
                            code: auth_code) \
                   .request_format_www_form_urlencoded

        [response, nil, nil]
      },

      refresh: lambda { |connection, refresh_token|
        post("https://#{connection['sub_domain']}.nationbuilder.com" \
          "/oauth/token") \
          .payload(client_id: connection["client_id"],
                   client_secret: connection["client_secret"],
                   grant_type: "refresh_token",
                   refresh_token: refresh_token) \
          .request_format_www_form_urlencoded
      },

      refresh_on: [401],

      apply: lambda { |_connection, access_token|
        headers("Authorization": "Bearer #{access_token}")
      }
    }
  },

  object_definitions: {
    person: {
      fields: lambda {
        [
          { name: "birth_date", type: "date" },
          { name: "city_district" },
          { name: "civicrm_id" },
          { name: "county_district" },
          { name: "county_file_id" },
          { name: "created_at", type: "date_time" },
          { name: "do_not_call", type: "boolean" },
          { name: "do_not_contact", type: "boolean" },
          { name: "dw_id" },
          { name: "email_opt_in", type: "boolean" },
          { name: "email", control_type: "email" },
          { name: "employer" },
          { name: "external_id" },
          { name: "federal_district" },
          { name: "fire_district" },
          { name: "first_name" },
          { name: "has_facebook", type: "boolean" },
          { name: "id" },
          { name: "is_twitter_follower", type: "boolean" },
          { name: "is_volunteer", type: "boolean" },
          { name: "judicial_district" },
          { name: "labour_region" },
          { name: "last_name" },
          { name: "linkedin_id" },
          { name: "mobile_opt_in", type: "boolean" },
          { name: "mobile", control_type: "phone" },
          { name: "nbec_guid" },
          { name: "ngp_id" },
          { name: "note" },
          { name: "occupation" },
          { name: "party" },
          { name: "pf_strat_id" },
          { name: "phone", control_type: "phone" },
          { name: "precinct_id" },
          {
            name: "primary_address",
            type: "object",
            properties: [
              { name: "address1" },
              { name: "address2" },
              { name: "address3" },
              { name: "city" },
              { name: "state" },
              { name: "zip" },
              { name: "country_code" },
              { name: "lat" },
              { name: "long" }
            ]
          },
          { name: "recruiter_id" },
          { name: "rnc_id" },
          { name: "rnc_regid" },
          { name: "school_district" },
          { name: "school_sub_district" },
          {
            name: "sex",
            control_type: "select",
            pick_list: [
              %w[Male M],
              %w[Female F],
              %w[Other O]
            ]
          },
          { name: "state_file_id" },
          { name: "state_lower_district" },
          { name: "state_upper_district" },
          { name: "support_level", type: "integer" },
          { name: "supranational_district" },
          { name: "tags", type: "array", properties: [] },
          { name: "twitter_id" },
          { name: "twitter_name" },
          { name: "updated_at", type: "date_time" },
          { name: "van_id" },
          { name: "village_district" }
        ]
      }
    },

    survey_response: {
      fields: lambda {
        [
          { name: "id", type: "integer" },
          { name: "survey_id", type: "integer" },
          { name: "person_id", type: "integer" },
          { name: "created_at", type: "date_time" },
          { name: "updated_at", type: "date_time" },
          {
            name: "question_responses",
            type: "array",
            of: "object",
            properties: [
              { name: "id", type: "integer" },
              { name: "response" },
              { name: "question_id", type: "integer" }

            ]
          }
        ]
      }
    }
  },

  test: lambda { |connection|
    get("https://#{connection['sub_domain']}.nationbuilder.com" \
      "/api/v1/people/count")
  },

  actions: {
    search_person: {
      description: "Search <span class='provider'>person</span> in " \
      "<span class='provider'>NationBuilder</span>",
      subtitle: "Search person",

      input_fields: lambda { |object_definitions|
        object_definitions["person"]
          .only("first_name", "last_name", "email", "city", "state", "sex",
                "birthdate", "updated_since", "with_mobile", "salesforce_id",
                "external_id")
      },

      execute: lambda { |connection, input|
        {
          people: get("https://#{connection['sub_domain']}.nationbuilder.com" \
            "/api/v1/people/search") \
            .params({ per_page: 100 }.merge(input)) \
            .dig("results") || []
        }
      },

      output_fields: lambda { |object_definitions|
        [
          {
            name: "people",
            type: "array",
            of: "object",
            properties: object_definitions["person"]
          }
        ]
      },

      sample_output: lambda { |connection|
        {
          people: get("https://#{connection['sub_domain']}.nationbuilder." \
            "com/api/v1/people/search") \
            .params(per_page: 1) \
            .dig("results") || []
        }
      }
    },

    get_person_by_id: {
      description: "Get <span class='provider'>person</span> by ID in " \
        "<span class='provider'>NationBuilder</span>",
      subtitle: "Get person by ID",

      input_fields: lambda { |object_definitions|
        object_definitions["person"] \
          .only("id", "external_id")
      },

      execute: lambda { |connection, input|
        get(if input["external_id"].present?
              "https://#{connection['sub_domain']}.nationbuilder." \
                "com/api/v1/people/#{input['external_id']}?id_type=external"
            else
              "https://#{connection['sub_domain']}.nationbuilder." \
                "com/api/v1/people/#{input['id']}"
            end) \
          .dig("person") || {}
      },

      output_fields: lambda { |object_definitions|
        object_definitions["person"]
      },

      sample_output: lambda { |connection|
        get("https://#{connection['sub_domain']}.nationbuilder." \
          "com/api/v1/people/search") \
          .params(per_page: 1) \
          .dig("results") \
          &.first || {}
      }
    },

    match_person: {
      description: "Match <span class='provider'>person</span> in " \
        "<span class='provider'>NationBuilder</span>",
      subtitle: "Match person",
      help: "Use this match to find person that have certain attributes.",

      input_fields: lambda { |object_definitions|
        object_definitions["person"] \
          .only("first_name", "last_name", "email", "phone", "mobile")
      },

      execute: lambda { |connection, input|
        get("https://#{connection['sub_domain']}.nationbuilder.com" \
          "/api/v1/people/match") \
          .params(input) \
          .dig("person") || {}
      },

      output_fields: lambda { |object_definitions|
        object_definitions["person"]
      },

      sample_output: lambda { |connection|
        get("https://#{connection['sub_domain']}.nationbuilder." \
          "com/api/v1/people/search") \
          .params(per_page: 1) \
          .dig("results") \
          &.first || {}
      }
    }
  },

  triggers: {
    new_or_updated_person: {
      description: "New or updated <span class='provider'>person</span> in " \
        "<span class='provider'>NationBuilder</span>",
      subtitle: "New or updated person",

      input_fields: lambda { |_connection|
        [
          {
            name: "since",
            label: "From",
            type: "date_time",
            optional: true,
            sticky: true,
            hint: "Get person created or updated since given date/time. " \
              "Leave empty to get person created or updated one hour ago"
          }
        ]
      },

      poll: lambda { |connection, input, next_page|
        response = get(if next_page.present?
                         "https://#{connection['sub_domain']}"  \
                           ".nationbuilder.com" << next_page
                       else
                         "https://#{connection['sub_domain']}."  \
                           "nationbuilder.com/api/v1/people/search"
                       end)
                   .params(per_page: 100,
                           updated_since: (input["since"].presence || 1.hour.ago)
                             .to_time.utc.iso8601)

        {
          events: (response.dig("results") || [])
            .sort_by { |person| person["updated_at"] },
          next_poll: response.dig("next").presence,
          can_poll_more: response.dig("next").present?
        }
      },

      dedup: lambda { |person|
        person["id"].to_s << "@" << person["updated_at"].to_s
      },

      output_fields: lambda { |object_definitions|
        object_definitions["person"]
      },

      sample_output: lambda { |connection|
        get("https://#{connection['sub_domain']}.nationbuilder." \
          "com/api/v1/people/search") \
          .params(per_page: 1) \
          .dig("results") \
          &.first || {}
      }
    },

    new_or_updated_survey_response: {
      description: "New or updated <span class='provider'>survey response" \
        "</span> in <span class='provider'>NationBuilder</span>",
      subtitle: "New or updated survey response",

      input_fields: lambda { |_connection|
        [
          {
            name: "start_time",
            label: "Since",
            type: "date_time",
            optional: true,
            sticky: true,
            hint: "Get survey response created or updated since given " \
              "date/time. Leave empty to get survey response created or " \
              "updated one hour ago"
          }
        ]
      },

      poll: lambda { |connection, input, next_page|
        response = get(if next_page.present?
                         "https://#{connection['sub_domain']}"  \
                           ".nationbuilder.com" << next_page
                       else
                         "https://#{connection['sub_domain']}."  \
                           "nationbuilder.com/api/v1/survey_responses"
                       end)
                   .params(per_page: 100,
                           start_time: (input["since"].presence || 1.hour.ago)
                             .to_time.to_i)

        {
          events: (response.dig("results") || [])
            .sort_by { |survey_response| survey_response["updated_at"] },
          next_poll: response.dig("next").presence,
          can_poll_more: response.dig("next").present?
        }
      },

      dedup: lambda { |survey_response|
        survey_response["id"].to_s << "@" << survey_response["updated_at"].to_s
      },

      output_fields: lambda { |object_definitions|
        object_definitions["survey_response"]
      },

      sample_output: lambda { |connection|
        get("https://#{connection['sub_domain']}.nationbuilder." \
          "com/api/v1/survey_responses") \
          .params(per_page: 1) \
          .dig("results") \
          &.first || {}
      }
    }
  }
}
