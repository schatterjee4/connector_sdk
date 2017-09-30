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

      authorization_url: lambda do |connection|
        params = {
          response_type: "code",
          client_id: connection["client_id"],
          redirect_uri: "https://www.workato.com/oauth/callback",
        }.to_param
        "https://#{connection["company"]}.namely.com/api/v1/oauth2/authorize?" + params
      end,

      acquire: lambda do |connection, auth_code|
        response = post("https://#{connection["company"]}.namely.com/api/v1/oauth2/token").
                     payload(
                       grant_type: "authorization_code",
                       client_id: connection["client_id"],
                       client_secret: connection["client_secret"],
                       code: auth_code).
                     request_format_www_form_urlencoded
        [ response, nil, nil ]
      end,

      refresh_on: [401, 403],

      refresh: lambda do |connection, refresh_token|
        post("https://#{connection["company"]}.namely.com/api/v1/oauth2/token").
          payload(
            grant_type: "refresh_token",
            client_id: connection["client_id"],
            client_secret: connection["client_secret"],
            refresh_token: refresh_token,
            redirect_uri: "https://www.workato.com/oauth/callback").
          request_format_www_form_urlencoded
      end,

      apply: lambda do |connection, access_token|
        headers("Authorization": "Bearer #{access_token}")
      end
    }
  },

  object_definitions: {
    profile: {
      fields: ->() {
        [
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
        ]
      },
    },
  },

  test: lambda do |connection|
    get("https://#{connection["company"]}.namely.com/api/v1/profiles/me")
  end,

  actions: {
    update_employee_profile: {
      description: 'Update <span class="provider">employee profile</span> '\
                   'in <span class="provider">Namely</span>',
      subtitle: "Update employee profile in Namely",

      input_fields: lambda do
        [
          { name: "profile_id", label: "Profile ID", optional: false },
          { name: "email", label: "Company email", optional: true },
          { name: "first_name", optional: true },
          { name: "last_name", optional: true },
          { name: "status", optional: true, control_type: :select,
            pick_list: "employee_status", toggle_hint: "Select from list",
            toggle_field: {
              name: "status", type: :string, control_type: :text,
              label: "Status (Custom)", toggle_hint: "Use custom value"
            } },
          { name: "start_date", type: :date, optional: true },
          { name: "personal_email", optional: true,
            hint: "Required if Namely profile user status is pending" },
          { name: "reports_to", optional: true,
            hint: "ID of employee profile whom employee reports to" },
          { name: "job_title", optional: true,
            hint: "ID of job title, or the name of the title as defined in your Namely instance" },
        ]
      end,

      execute: lambda do |connection, input|
        profile = put("https://#{connection["company"]}.namely.com/api/v1/profiles/#{input["profile_id"]}").
                    params(
                      profiles: {
                        email: input["email"],
                        first_name: input["first_name"],
                        last_name: input["last_name"],
                        user_status: input["status"],
                        start_date: input["start_date"],
                        personal_email: input["personal_email"],
#                         reports_to: input["reports_to"],
#                         job_title: input["job_title"]
                      }
                    )["profiles"]
          { profile: profile }
      end,

      output_fields: lambda do |object_definitions|
        [
          { name: "profile", type: :object, properties: object_definitions["profile"] }
        ]
      end,

      sample_output: lambda do |connection|
        {
          "profile":
            get("https://#{connection["company"]}.namely.com/api/v1/profiles.json").
              params(
                page: 1,
                per_page: 1
              )["profiles"]
        }
      end
    },

    search_employee_profiles: {
      description: 'Search <span class="provider">employee profiles</span> '\
                   'in <span class="provider">Namely</span>',
      subtitle: "Search employee profiles in Namely",
      hint: "Use the input fields to add filters to employee profile results. "\
            "Leave input fields blank to return all employee profiles.",

      input_fields: lambda do
        [
          { name: "first_name", optional: true, sticky: true },
          { name: "last_name", optional: true, sticky: true },
          { name: "email", label: "Company email", optional: true, sticky: true },
          { name: "personal_email", optional: true },
          { name: "job_title", optional: true,
            hint: "ID of job title, or the name of the title as defined in your Namely instance" },
          { name: "reports_to", optional: true,
            hint: "ID of employee profile whom employee reports to" },
          { name: "status", optional: true, control_type: :select,
            pick_list: "employee_status", toggle_hint: "Select from list",
            toggle_field: {
              name: "status", type: :string, control_type: :text,
              label: "Status (Custom)", toggle_hint: "Use custom value"
            } },
          { name: "start_date", type: :date, optional: true }
        ]
      end,

      execute: lambda do |connection, input|
        params = (input["first_name"].present? ? "&filter[first_name]=#{input["first_name"]}" : "") +
                 (input["last_name"].present? ? "&filter[last_name]=#{input["last_name"]}" : "") +
                 (input["email"].present? ? "&filter[email]=#{input["email"]}" : "") +
                 (input["personal_email"].present? ? "&filter[personal_email]=#{input["personal_email"]}" : "") +
                 (input["job_title"].present? ? "&filter[job_title]=#{input["job_title"]}" : "") +
                 (input["reports_to"].present? ? "&filter[reports_to]=#{input["reports_to"]}" : "") +
                 (input["status"].present? ? "&filter[user_status]=#{input["user_status"]}" : "")
        employees = []
        page = 1
        count = 1
        while count != 0
          response = get("https://#{connection["company"]}.namely.com/api/v1/profiles.json?" +
                    params, page: page, per_page: 50)
          count = response["meta"]["count"]
          employees.concat(response["profiles"])
          page = page+1
        end
        employees = employees.to_a
        if input["start_date"].present?
          employees = employees.where("start_date" => input["start_date"].to_s)
        end
        { "profiles": employees }
      end,

      output_fields: lambda do |object_definitions|
        [
          { name: "profiles", type: :array, of: :object,
            properties: object_definitions["profile"] }
        ]
      end,

      sample_output: lambda do |connection|
        {
          "profiles": get("https://#{connection["company"]}.namely.com/api/v1/profiles.json").
                        params(
                          page: 1,
                          per_page: 1
                        )["profiles"]
        }
      end
    }
  },

  triggers: {},

  pick_lists: {
    employee_status: ->() {
      [
        ["Active", "active"],
        ["Inactive", "inactive"],
        ["Pending", "pending"]
      ]
    },

    event_type: ->() {
      [
        ["Birthday", "birthday"],
        ["Announcement", "announcement"],
        ["Recent arrival", "recent_arrival"],
        ["Anniversary", "anniversary"],
        ["All", "all"]
      ]
    }
  }
}
