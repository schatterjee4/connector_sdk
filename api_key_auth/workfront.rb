{
  title: "workfront",

  connection: {
    fields: [
      { name: "subdomain",
        control_type: "subdomain",
        url: ".workfront.com",
        optional: false,
        label: 'Sub domain',
        hint: "Your workfront subdomain as found in your URL" },
      { name: "apikey", control_type: :password, label: "API key", optional: false }
    ],
    authorization: {
      type: "basic",

      credentials: lambda do |connection|
        params(apiKey: "#{connection['apikey']}")
      end
    },
  },

  object_definitions: {
    project: {
      fields: lambda do |connection, config|
        get("https://#{connection['subdomain']}.workfront.com/attask/api/" \
         "v7.0/proj/metadata")["data"]["fields"].
          map do |key, value|
            if value["fieldType"] == "string" && value["enumType"].blank?
              { name: key, label: "#{value['label']}" }
            elsif value["fieldType"] == "double"
              { name: key, label: "#{value['label']}",
                type: :ineger, control_type: :number }
            elsif value["fieldType"] == "date"
              { name: key, type: :date,  label: "#{value['label']}" }
            elsif value["fieldType"] == "boolean"
              { name: key, label: "#{value['label']}", type: :boolean }
            elsif value["fieldType"] == "string" && !value["enumType"].blank?
              string_list = value["possibleValues"].map do |item|
                [item["label"], item["value"]]
              end
              { name: key, label: "#{value['label']}", control_type: :select,
                pick_list: string_list,
                toggle_hint: "Select from list",
                toggle_field: {
                  name: key,
                  label: "#{value['label']}",
                  type: :string,
                  control_type: "text",
                  optional: false,
                  toggle_hint: "Use custom value" } }
            elsif value["fieldType"] == "string[]" && !value["enumType"].blank?
              select_list = value["possibleValues"].map do |item|
                [item["label"], item["value"]]
              end
              { name: key, label: "#{value['label']}", control_type: :select,
                pick_list: select_list,
                toggle_hint: "Select from list",
                toggle_field: {
                  name: key,
                  label: "#{value['label']}",
                  type: :string,
                  control_type: "text",
                  optional: false,
                  toggle_hint: "Use custom value" } }
            elsif value["fieldType"] == "string[]" && value["enumType"].blank?
              { name: key, label: "#{value['label']}" }
            elsif value["fieldType"] == "dateTime"
              { name: key, type: :date_time, label: "#{value['label']}" }
            elsif value["fieldType"] == "int"
              { name: key, label: "#{value['label']}", type: :integer,
                control_type: :number }
            elsif value["fieldType"] == "map"
              { name: key, label: "#{value['label']}" }
            else
              { name: key, label: "#{value['label']}" }
            end
          end
      end
    },
    program: {
      fields: lambda do |connection|
        get("https://#{connection['subdomain']}.workfront.com/attask/api/" \
         "v7.0/prgm/metadata")["data"]["fields"].
          map do |key, value|
            if value["fieldType"] == "string" && value["enumType"].blank?
              { name: key, label: "#{value['label']}" }
            elsif value["fieldType"] == "double"
              { name: key, label: "#{value['label']}", type: :ineger,
                control_type: :number }
            elsif value["fieldType"] == "date"
              { name: key, type: :date,  label: "#{value['label']}" }
            elsif value["fieldType"] == "boolean"
              { name: key, label: "#{value['label']}", type: :boolean}
            elsif value["fieldType"] == "string" && !value["enumType"].blank?
              string_list = value["possibleValues"].map do |item|
                [item["label"], item["value"]]
              end
              { name: key, label: "#{value['label']}", control_type: :select,
                pick_list: string_list,
                toggle_hint: "Select from list",
                toggle_field: {
                  name: key,
                  label: "#{value['label']}",
                  type: :string,
                  control_type: "text",
                  optional: false,
                  toggle_hint: "Use custom value" } }
            elsif value["fieldType"] == "string[]" && !value["enumType"].blank?
              select_list = value["possibleValues"].map do |item|
                [item["label"], item["value"]]
              end
              { name: key, label: "#{value['label']}", control_type: :select,
                pick_list: select_list,
                toggle_hint: "Select from list",
                toggle_field: {
                  name: key,
                  label: "#{value['label']}",
                  type: :string,
                  control_type: "text",
                  optional: false,
                  toggle_hint: "Use custom value" } }
            elsif value["fieldType"] == "string[]" && value["enumType"].blank?
              { name: key, label: "#{value['label']}" }
            elsif value["fieldType"] == "dateTime"
              { name: key, type: :date_time, label: "#{value['label']}" }
            elsif value["fieldType"] == "int"
              { name: key, label: "#{value['label']}", type: :integer,
                control_type: :number}
            elsif value["fieldType"] == "map"
              { name: key, label: "#{value['label']}"}
            else
              { name: key, label: "#{value['label']}" }
            end
          end
      end
    },
    custom_object: {
      fields: lambda do |connection, config|
        if config["custom_fields"].blank?
          []
        else
          { name: "parameterValues",
            type: "object",
            properties: config["custom_fields"].split("\n").
            map do |field|
              {
                name: field,
                label: field
              }
            end
          }
        end
      end
    }
  },

  test: lambda do |connection|
    get("https://#{connection['subdomain']}.workfront.com/attask/api/v7.0/" \
     "project/search?$$LIMIT=1")
  end,

  actions: {
    get_project_details_by_id: {
      description: 'Get <span class="provider">Project</span> details by ID 
    in <span class="provider">WorkFront</span>',
      subtitle: "Get Project details in WorkFront",
      help: "Fetches the project details for the given Project ID",
      config_fields: [
        {
          name: "custom_fields",
          control_type: "text-area",
          change_on_blur: true,
          sticky: true,
          hint: "Custom fields involved in this action. One per line. " \
           "Fields with only Colon and Space are allowed." \
            " ex: <code>DE:Project Manager</code>"
        }
      ],
      input_fields: lambda do |object_definitions|
        [
          { name: "ID", type: :string, optional: false, label: "Project id" }
        ]
      end,
      execute: lambda do |connection, input|
        project = get("https://#{connection['subdomain']}.workfront.com/" \
         "attask/api/project/" + input["ID"] + "?fields=*&" \
          "fields=parameterValues")["data"]
        {
          project: project
        }
      end,
      output_fields: lambda do |object_definitions|
        properties =  object_definitions["project"]
        properties << object_definitions["custom_object"] unless
         object_definitions["custom_object"].blank?
        [
          {
            name: "project", type: :object, label: "Project", properties: properties
          }
        ]
      end,
      sample_output: lambda do |connection, object_definitions|
        {
          project: get("https://#{connection['subdomain']}.workfront.com/attask/api/" \
         "project/search?fields=*&$$LIMIT=1").dig("data", 0)
        }
      end
    },

    search_projects: {
      description: "Search <span class='provider'>Projects</span> in 
      <span class='provider'>WorkFront</span>",
      subtitle: "Search Projects with Project name in WorkFront",
      help: "Search Projects which matches the criteria from WorkFront",
      config_fields: [
        {
          name: "custom_fields",
          control_type: "text-area",
          change_on_blur: true,
          sticky: true,
          hint: "Custom fields involved in this action. One per line. " \
           "Fields with only Colon and Space are allowed." \
            " ex: <code>DE:Project Manager</code>"
        }
      ],
      input_fields: lambda do |_object_definitions|
        [
          {
            name: "name", type: :string, optional: false, label: "Project name",
            hint: "Fetch projects that contains this keyword"
          }
        ]
      end,
      execute: lambda do |connection, input|
        projects = get("https://#{connection['subdomain']}.workfront.com/" \
         "attask/api/project/search?fields=*&fields=parameterValues&" \
          "name=" + input["name"] +"&name_Mod=contains")["data"]
        {
          projects: projects
        }
      end,
      output_fields: lambda do |object_definitions|
        properties =  object_definitions["project"]
        properties << object_definitions["custom_object"] unless
         object_definitions["custom_object"].blank?
        [
          {
            name: "projects", type: :array, of: :object,
            label: "Projects", properties: properties
          }
        ]
      end,
      sample_output: lambda do |connection, _object_definitions|
        {
          projects: get("https://#{connection['subdomain']}.workfront.com/attask/api/" \
         "project/search?fields=*&$$LIMIT=1").dig("data", 0)
        }
      end
    },

    create_project: {
      description: "Create <span class='provider'>Project</span> in 
      <span class='provider'>WorkFront</span>",
      subtitle: "Create Project with details in WorkFront",
      help: "Select the feilds which are part of Project create action",
      input_fields: lambda do |object_definitions|
        object_definitions["project"].
          ignored("ID", "lastUpdateDate",
                  "lastUpdatedByID", "entryDate",
                  "enteredByID").required("name")
      end,
      execute: lambda do |connection, input|
        params = input.map do |key, value|
          if key.downcase.include?("date")
            "#{key}=" + value.to_time.in_time_zone("US/Eastern").iso8601
          else
            "#{key}=#{value}"
          end
        end.join("&")
        project = post("https://#{connection['subdomain']}.workfront.com/" \
         "attask/api/project?"+ params).params(fields: "*") ["data"]
        {
          project: project
        }
      end,
      output_fields: lambda do |object_definitions|
        [
          {
            name: "project", type: :object, label: "Project",
            properties: object_definitions["project"]
          }
        ]
      end,
      sample_output: lambda do |connection, object_definitions|
        {
          project: get("https://#{connection['subdomain']}.workfront.com/attask/api/" \
         "project/search?fields=*&$$LIMIT=1").dig("data", 0)
        }
      end
    },

    search_programs: {
      description: 'Search <span class="provider">Programs</span> in
       <span class="provider">WorkFront</span>',
      subtitle: "Search Programs in WorkFront",
      help: "Search Programs by Program name in WorkFront",
      config_fields: [
        {
          name: "custom_fields",
          control_type: "text-area",
          change_on_blur: true,
          sticky: true,
          hint: "Custom fields involved in this action. One per line. " \
           "Fields with only Colon and Space are allowed." \
            " ex: <code>DE:Project Manager</code>"
        }
      ],
      input_fields: lambda do |_object_definitions|
        [
          {
            name: "name", type: :string, optional: false, label: "Program name",
            hint: "Fetch Programs that contains this keyword"
          }
        ]
      end,
      execute: lambda do |connection, input|
        programs = get("https://#{connection['subdomain']}.workfront.com/" \
         "attask/api/program/search?fields=*&fields=parameterValues&" \
          "name=" + input["name"] + "&name_Mod=contains")["data"]
        {
          programs: programs
        }
      end,
      output_fields: lambda do |object_definitions|
        properties =  object_definitions["program"]
        properties << object_definitions["custom_object"] unless
         object_definitions["custom_object"].blank?
        [
          {
            name: "programs", type: :array, of: :object, properties: properties
          }
        ]
      end,
      sample_output: lambda do |connection, _object_definitions|
        {
          programs: get("https://#{connection['subdomain']}.workfront.com/" \
           "attask/api/program/search?fields=*&$$LIMIT=1").dig("data", 0)
        }
      end
    },

    get_program_details_by_id: {
      description: 'Get <span class="provider">Program</span> details in
       <span class="provider">WorkFront</span>',
      subtitle: "Get Program details by ID in WorkFront",
      help: "Get Program details from WorkFront",
      config_fields: [
        {
          name: "custom_fields",
          control_type: "text-area",
          change_on_blur: true,
          sticky: true,
          hint: "Custom fields involved in this action. One per line." \
           " Fields with only Colon and Space are allowed." \
            " ex: <code>DE:Project Manager</code>"
        }
      ],
      input_fields: lambda do |_object_definitions|
        [
          {
            name: "ID", type: :string, optional: false, label: "Program id",
            hint: "Get Program details with Program ID"
          }
        ]
      end,
      execute: lambda do |connection, input|
        program = get("https://#{connection['subdomain']}.workfront.com/" \
         "attask/api/program/" + input["ID"] + "?fields=*&" \
          "fields=parameterValues")["data"]
        {
          program: program
        }
      end,
      output_fields: lambda do |object_definitions|
        properties =  object_definitions["program"]
        properties << object_definitions["custom_object"] unless
         object_definitions["custom_object"].blank?
        [
          {
            name: "program", type: :object,
            label: "Program", properties: properties
          }
        ]
      end,
      sample_output: lambda do |connection, _object_definitions|
        {
          program: get("https://#{connection['subdomain']}.workfront.com/" \
           "attask/api/program/search?fields=*&$$LIMIT=1").dig("data", 0)
        }
      end
    }
  },

  triggers: {
    new_updated_project: {
      description: "New or Updated <span class='provider'>Project</span> in
       <span class='provider'>WorkFront</span>",
      subtitle: "New or Updated Project in WorkFront",
      help: "Trigger will poll based on the User plan",
      config_fields: [
        {
          name: "port_id", control_type: :select,
          pick_list: :portfolios, label: "Portfolio",
          optional: false,
          hint: "Select Portfolio to process projects belongs",
          toggle_hint: "Select from list",
          toggle_field: {
            name: "port_id",
            label: "Portfolio ID",
            type: :string,
            control_type: :text,
            optional: false,
            toggle_hint: "Use Custom Value",
            hint: "Provide the Portfolio ID for reading Projects changes"
          }
        },
        {
          name: "custom_fields",
          control_type: "text-area",
          change_on_blur: true,
          sticky: true,
          hint: "Custom fields involved in this action. One per line." \
           " Fields with only Colon and Space are allowed." \
            " ex: <code>DE:Project Manager</code>"
        }
      ],
      input_fields: lambda do |_object_definitions|
        [
          name: "since", type: :date_time, sticky: :true,
          label: "From", hint: "Fetch Projects from specified Date"
        ]
      end,
      poll: lambda do |connection, input, last_updated_time|
        last_updated_time ||= ((input["since"].presence || Time.now).
          to_time.strftime("%Y-%m-%dT%H:%M:%S %z").to_time.
          in_time_zone("US/Central"))
        projects = get("https://#{connection['subdomain']}.workfront.com/" \
         "attask/api/project/search?fields=*&fields=parameterValues").
                   params(
                    portfolioID: input["port_id"],
                    portfolioID_Mod: "eq",
                    lastUpdateDate: last_updated_time.to_time.iso8601,
                    lastUpdateDate_Mod: "gt"
                  )["data"]
        # Not sure about result order, to be on safer side, sorting explicitly
        projects.sort_by { |obj| obj["lastUpdateDate"] } unless projects.blank?
        last_modfied_time = projects.last["lastUpdateDate"] unless
         projects.blank?
        {
          events: projects,
          next_poll: last_modfied_time,
          can_poll_more: projects.size > 0
        }
      end,
      dedup: lambda do |project|
        project["ID"] + "@" + project["lastUpdateDate"]
      end,
      output_fields: lambda do |object_definitions|
        properties =  object_definitions["project"]
        properties << object_definitions["custom_object"] unless
         object_definitions["custom_object"].blank?
        properties
      end,
      sample_output: lambda do |connection, _object_definitions|
        get("https://#{connection['subdomain']}.workfront.com/attask/api/" \
         "project/search?fields=*&$$LIMIT=1").dig("data", 0)
      end
    }
  },
  pick_lists: {
    programs: lambda do |connection|
      get("https://#{connection['subdomain']}.workfront.com/attask/api/v7.0/" \
       "program/search")["data"].map do |program|
        [program["name"], program["ID"]]
      end
    end,
    portfolios: lambda do |connection|
      get("https://#{connection['subdomain']}.workfront.com/attask/api/v7.0/" \
       "port/search")["data"].map do |port|
        [port["name"], port["ID"]]
      end
    end
  }
}
