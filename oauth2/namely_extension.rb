{
  title: "Namely extension",

  connection: {
    fields: [
      { name: "company", control_type: :subdomain, url: ".namely.com", optional: false,
        hint: "If your Namely URL is https://acme.namely.com then use acme as value." },
      { name: "client_id", label: "Client ID", control_type: :password, optional: false },
      { name: "client_secret", control_type: :password, optional: false }
    ],

    authorization: {
      type: "oauth2",

      authorization_url: ->(connection) {
        params = {
          response_type: "code",
          client_id: connection["client_id"],
          redirect_uri: "https://www.workato.com/oauth/callback",
        }.to_param
        "https://#{connection["company"]}.namely.com/api/v1/oauth2/authorize?" + params
      },

      acquire: ->(connection, auth_code) {
        response = post("https://#{connection["company"]}.namely.com/api/v1/oauth2/token").
        payload(
          grant_type: "authorization_code",
          client_id: connection["client_id"],
          client_secret: connection["client_secret"],
          code: auth_code
        ).request_format_www_form_urlencoded
        [ { access_token: response["access_token"], refresh_token: response["refresh_token"] }, nil, nil ]
      },

      refresh_on: [401, 403],

      refresh: ->(connection, refresh_token) {
        post("https://#{connection["company"]}.namely.com/api/v1/oauth2/token").
        payload(
          grant_type: "refresh_token",
          client_id: connection["client_id"],
          client_secret: connection["client_secret"],
          refresh_token: refresh_token,
          redirect_uri: "https://www.workato.com/oauth/callback"
        ).request_format_www_form_urlencoded
      },

      apply: ->(connection, access_token) {
        headers("Authorization": "Bearer #{access_token}")
      }
    }
  },

  object_definitions: {
    profile: {
      fields: ->() {
        [
          { name: "profiles", type: :array, of: :object, properties: [
            { name: "id", label: "ID" },
            { name: "email" },
            { name: "first_name" },
            { name: "last_name" },
            { name: "user_status" },
            { name: "updated_at", type: :integer },
            { name: "created_at" },
            { name: "preferred_name" },
            { name: "full_name" },
            { name: "job_title", type: :object, properties: [
              { name: "id", label: "ID" },
              { name: "title" }
            ]},
            { name: "reports_to", type: :object, properties: [
              { name: "id", label: "ID" },
              { name: "first_name" },
              { name: "last_name" },
              { name: "email" }
            ]},
            { name: "employee_type", type: :object, properties: [
              { name: "title" }
            ]},
            { name: "access_role" },
            { name: "ethnicity" },
            { name: "middle_name" },
            { name: "gender" },
            { name: "job_change_reason" },
            { name: "start_date" },
            { name: "departure_date" },
            { name: "employee_id", label: "Employee ID" },
            { name: "personal_email" },
            { name: "dob", label: "Date of birth"},
            { name: "ssn", label: "SSN" },
            { name: "marital_status" },
            { name: "bio" },
            { name: "asset_management" },
            { name: "laptop_asset_number" },
            { name: "corporate_card_number" },
            { name: "key_tag_number" },
            { name: "linkedin_url" },
            { name: "office_main_number" },
            { name: "office_direct_dial" },
            { name: "office_phone" },
            { name: "office_fax" },
            { name: "office_company_mobile" },
            { name: "home_phone" },
            { name: "mobile_phone" },
            { name: "home", type: :object, properties: [
              { name: "address1" },
              { name: "address2" },
              { name: "city" },
              { name: "state_id", label: "State ID" },
              { name: "country_id", label: "Country ID" },
              { name: "zip" }
            ]},
            { name: "office", type: :object, properties: [
              { name: "address1" },
              { name: "address2" },
              { name: "city" },
              { name: "state_id", label: "State ID" },
              { name: "country_id", label: "Country ID"},
              { name: "zip" },
              { name: "phone" }
            ]},
            { name: "emergency_contact" },
            { name: "emergency_contact_phone" },
            { name: "resume" },
            { name: "current_job_description" },
            { name: "job_description" },
            { name: "salary", type: :object, properties: [
              { name: "currency_type" },
              { name: "date" },
              { name: "guid", label: "GUID" },
              { name: "pay_group_id", label: "Pay group ID", type: :integer },
              { name: "payroll_job_id", label: "Payroll job ID" },
              { name: "rate" },
              { name: "yearly_amount", type: :integer },
              { name: "is_hourly", label: "Is hourly?", type: :boolean },
              { name: "amount_raw", label: "Raw amount" } ] },
            { name: "healthcare", type: :object, properties: [
              { name: "beneficiary" },
              { name: "amount" },
              { name: "currency_type" }
            ]},
            { name: "healthcare_info" },
            { name: "dental", type: :object, properties: [
              { name: "beneficiary" },
              { name: "amount" },
              { name: "currency_type" }
            ]},
            { name: "dental_info" },
            { name: "vision_plan_info" },
            { name: "life_insurance_info" },
            { name: "namely_time_employee_role" },
            { name: "namely_time_manager_role" }
          ]},
        ]
      }
    },
    event: {
      fields: ->() {
        [
          { name: "id", label: "ID" },
          { name: "href", label: "URL" },
          { name: "type" },
          { name: "time", type: :integer },
          { name: "utc_offset", type: :integer },
          { name: "content" },
          { name: "html_content" },
          { name: "years_at_company", type: :integer },
          { name: "use_comments", label: "Use comments?", type: :boolean },
          { name: "can_comment", label: "Can comment?", type: :boolean },
          { name: "can_destroy", label: "Can destroy?", type: :boolean },
          { name: "links", type: :object, properties: [
            { name: "profile" },
            { name: "comments", type: :array, of: :string },
            { name: "file" },
            { name: "appreciations", type: :array, of: :string },
          ]},
          { name: "can_like", label: "Can like?", type: :boolean },
          { name: "likes_count", type: :integer },
          { name: "liked_by_current_profile", type: :boolean },
        ]
      }
    }
  },

  test: ->(connection) {
    get("https://#{connection["company"]}.namely.com/api/v1/profiles/me")
  },

  actions: {
    search_employee_profiles: {
      description: 'Search <span class="provider">employee profiles</span> '\
                   'in <span class="provider">Namely</span>',
      subtitle: "Search employee profiles in Namely",
      hint: "Use the input fields to add filters to employee profile results."\
            "Leave input fields blank to return all employee profiles.",

      input_fields: ->() {
        [
          { name: "email", optional: true, sticky: true },
          { name: "status", optional: true, sticky: true, control_type: :select, pick_list: "employee_status", toggle_hint: "Select from list",
            toggle_field: {
              name: "status", type: :string, control_type: :text, label: "Status (Custom)", control_type: :text, toggle_hint: "Use custom value"
            }
          },
          { name: "start_date", type: :date, optional: true, sticky: true }
        ]
      },

      execute: ->(connection, input) {
        employees = get("https://#{connection["company"]}.namely.com/api/v1/profiles.json").
        params(
          email: input["email"],
          status: input["status"]
        )["profiles"]
        if input["start_date"].present?
          employees = employees.where("start_date" => input["start_date"].to_s)
        else
          employees = employees.to_a
        end
        { "profiles": employees }
      },

      output_fields: ->(object_definitions) {
        object_definitions["profile"]
      }
    }
  },

  triggers: {
    new_event: {
      description: 'New <span class="provider">event</span> '\
                   'started in <span class="provider">Namely</span>',
      subtitle: "New event started in Namely",
      type: :paging_desc,

      input_fields: ->() {
        [
          { name: "since", type: :date, optional: false },
          { name: "type", optional: false, control_type: :select, pick_list: "event_type", toggle_hint: "Select from list",
            toggle_field: {
              name: "type", type: :string, control_type: :text, label: "Type (Custom)", toggle_hint: "Use custom value",
              hint: "Either of birthday, announcement, recent_arrival, anniversary, or all" } },
          { name: "profile_id", optional: true, sticky: true,
            hint: "ID of the profile that you wish to pull all associated events from." }
        ]
      },

      poll: ->(connection, input, page) {
        limit = 100
        page ||= 0
        since = input["since"].to_time.to_i
        response = get("https://#{connection["company"]}.namely.com/api/v1/events.json").
                   params(limit: limit,
                          type: input["type"],
                          profile: input["profile_id"])["events"]
        {
          events: response.where("time >=" => since),
          next_page: response.length >= limit ? page + 1 : nil
        }
      },

      document_id: ->(response) {
        response["id"] + "@" + response["time"]
      },

      sort_by: ->(response) {
        response["time"]
      },

      output_fields: ->(object_definitions) {
        object_definitions["event"]
      }
    }
  },

  pick_lists: {
    employee_status: ->() {
      [
        ["Active", "active"], ["Inactive", "inactive"], ["Pending", "pending"]
      ]
    },

    event_type: ->() {
      [
        ["Birthday", "birthday"], ["Announcement", "announcement"],
        ["Recent arrival", "recent_arrival"], ["Anniversary", "anniversary"],
        ["All", "all"]
      ]
    }
  }
}
