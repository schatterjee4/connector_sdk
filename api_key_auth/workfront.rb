{
  title: "workfront",

  connection: {
    fields: [
      { name: "subdomain",
        control_type: "subdomain",
        url: ".workfront.com",
        optional: false,
        label: "Subdomain",
        hint: "Your workfront subdomain as found in your URL" },
      { name: "apikey", control_type: :password,
        label: "API key", optional: false },
      { name: "version", label: "API version",
        optional: false, hint: "Version from Workfront API e.g. v8.0" }

    ],
    authorization: {
      type: "api_key",

      credentials: lambda do |connection|
        params(apiKey: connection['apikey'])
      end
    },
    base_uri: lambda do |connection|
      "https://#{connection['subdomain']}.workfront.com"
    end
  },

  object_definitions: {
    project: {
      fields: lambda do |connection, config|
        get("/attask/api/#{connection['version']}/proj/metadata")["data"]["fields"].
        map do |key, value|
          case value["fieldType"]
          when "string"
            if value["enumType"].blank?
              { name: key, label: "#{value['label']}".labelize }
            else
              string_list = value["possibleValues"].map do |item|
                [item["label"], item["value"]]
              end
              { name: key, label: "#{value['label']}".labelize, control_type: :select,
                pick_list: string_list,
                toggle_hint: "Select from list",
                toggle_field: {
                  name: key,
                  label: "#{value['label']}".labelize,
                  type: :string,
                  control_type: "text",
                  optional: false,
                  toggle_hint: "Use custom value" } }
            end
          when "double"
            { name: key, label: "#{value['label']}".labelize,
                type: :ineger, control_type: :number }
          when "date"
            { name: key, type: :date,  label: "#{value['label']}".labelize,
                control_type: :date_time }
          when "boolean"
            { name: key, label: "#{value['label']}".labelize, type: :boolean,
                control_type: :checkbox,
                toggle_hint: "Select from list",
                toggle_field: {
                  name: key,
                  label: "#{value['label']}".labelize,
                  type: :string,
                  control_type: "text",
                  optional: false,
                  toggle_hint: "Use custom value" } }
          when "string[]"
            if value["enumType"].blank?
              { name: key, label: "#{value['label']}".labelize }
            else
              select_list = value["possibleValues"].map do |item|
                [item["label"], item["value"]]
              end
              { name: key, label: "#{value['label']}".labelize, control_type: :select,
                pick_list: select_list,
                toggle_hint: "Select from list",
                toggle_field: {
                  name: key,
                  label: "#{value['label']}".labelize,
                  type: :string,
                  control_type: "text",
                  optional: false,
                  toggle_hint: "Use custom value" } }
            end
          when "dateTime"
            { name: key, type: :date_time, label: "#{value['label']}".labelize }
          when "int"
            if value["enumType"].blank?
              { name: key, label: "#{value['label']}".labelize, type: :integer,
                control_type: :number }
            else
              int_list = value["possibleValues"].map do |item|
                [item["label"], item["value"]]
              end
              { name: key, label: "#{value['label']}".labelize, control_type: :select,
                pick_list: int_list,
                toggle_hint: "Select from list",
                toggle_field: {
                  name: key,
                  label: "#{value['label']}".labelize,
                  type: :integer,
                  control_type: "number",
                  optional: false,
                  toggle_hint: "Use custom value" } }
            end
          when "map"
            { name: key, label: "#{value['label']}".labelize }
          else
            { name: key, label: "#{value['label']}".labelize }
          end
        end
      end
    },
    program: {
      fields: lambda do |connection, config|
        get("/attask/api/#{connection['version']}/prgm/metadata")["data"]["fields"].
        map do |key, value|
          case value["fieldType"]
          when "string"
            if value["enumType"].blank?
              { name: key, label: "#{value['label']}".labelize }
            else
              string_list = value["possibleValues"].map do |item|
                [item["label"], item["value"]]
              end
              { name: key, label: "#{value['label']}".labelize, control_type: :select,
                pick_list: string_list,
                toggle_hint: "Select from list",
                toggle_field: {
                  name: key,
                  label: "#{value['label']}".labelize,
                  type: :string,
                  control_type: "text",
                  optional: false,
                  toggle_hint: "Use custom value" } }
            end
          when "double"
            { name: key, label: "#{value['label']}".labelize,
                type: :ineger, control_type: :number }
          when "date"
            { name: key, type: :date,  label: "#{value['label']}".labelize,
                control_type: :date_time }
          when "boolean"
            { name: key, label: "#{value['label']}".labelize, type: :boolean,
                control_type: :checkbox,
                toggle_hint: "Select from list",
                toggle_field: {
                  name: key,
                  label: "#{value['label']}".labelize,
                  type: :string,
                  control_type: "text",
                  optional: false,
                  toggle_hint: "Use custom value" } }
          when "string[]"
            if value["enumType"].blank?
              { name: key, label: "#{value['label']}".labelize }
            else
              select_list = value["possibleValues"].map do |item|
                [item["label"], item["value"]]
              end
              { name: key, label: "#{value['label']}".labelize, control_type: :select,
                pick_list: select_list,
                toggle_hint: "Select from list",
                toggle_field: {
                  name: key,
                  label: "#{value['label']}".labelize,
                  type: :string,
                  control_type: "text",
                  optional: false,
                  toggle_hint: "Use custom value" } }
            end
          when "dateTime"
            { name: key, type: :date_time, label: "#{value['label']}".labelize }
          when "int"
            if value["enumType"].blank?
              { name: key, label: "#{value['label']}".labelize, type: :integer,
                control_type: :number }
            else
              int_list = value["possibleValues"].map do |item|
                [item["label"], item["value"]]
              end
              { name: key, label: "#{value['label']}".labelize, control_type: :select,
                pick_list: int_list,
                toggle_hint: "Select from list",
                toggle_field: {
                  name: key,
                  label: "#{value['label']}".labelize,
                  type: :integer,
                  control_type: "number",
                  optional: false,
                  toggle_hint: "Use custom value" } }
            end
          when "map"
            { name: key, label: "#{value['label']}".labelize }
          else
            { name: key, label: "#{value['label']}".labelize }
          end
        end
      end
    },
    issue: {
      fields: lambda do |connection, config|
        get("/attask/api/#{connection['version']}/optask/metadata")["data"]["fields"].
        map do |key, value|
          case value["fieldType"]
          when "string"
            if value["enumType"].blank?
              { name: key, label: "#{value['label']}".labelize }
            else
              string_list = value["possibleValues"].map do |item|
                [item["label"], item["value"]]
              end
              { name: key, label: "#{value['label']}".labelize, control_type: :select,
                pick_list: string_list,
                toggle_hint: "Select from list",
                toggle_field: {
                  name: key,
                  label: "#{value['label']}".labelize,
                  type: :string,
                  control_type: "text",
                  optional: false,
                  toggle_hint: "Use custom value" } }
            end
          when "double"
            { name: key, label: "#{value['label']}".labelize,
                type: :ineger, control_type: :number }
          when "date"
            { name: key, type: :date,  label: "#{value['label']}".labelize,
                control_type: :date_time }
          when "boolean"
            { name: key, label: "#{value['label']}".labelize, type: :boolean,
                control_type: :checkbox,
                toggle_hint: "Select from list",
                toggle_field: {
                  name: key,
                  label: "#{value['label']}".labelize,
                  type: :string,
                  control_type: "text",
                  optional: false,
                  toggle_hint: "Use custom value" } }
          when "string[]"
            if value["enumType"].blank?
              { name: key, label: "#{value['label']}".labelize }
            else
              select_list = value["possibleValues"].map do |item|
                [item["label"], item["value"]]
              end
              { name: key, label: "#{value['label']}".labelize, control_type: :select,
                pick_list: select_list,
                toggle_hint: "Select from list",
                toggle_field: {
                  name: key,
                  label: "#{value['label']}".labelize,
                  type: :string,
                  control_type: "text",
                  optional: false,
                  toggle_hint: "Use custom value" } }
            end
          when "dateTime"
            { name: key, type: :date_time, label: "#{value['label']}".labelize }
          when "int"
            if value["enumType"].blank?
              { name: key, label: "#{value['label']}".labelize, type: :integer,
                control_type: :number }
            else
              int_list = value["possibleValues"].map do |item|
                [item["label"], item["value"]]
              end
              { name: key, label: "#{value['label']}".labelize, control_type: :select,
                pick_list: int_list,
                toggle_hint: "Select from list",
                toggle_field: {
                  name: key,
                  label: "#{value['label']}".labelize,
                  type: :integer,
                  control_type: "number",
                  optional: false,
                  toggle_hint: "Use custom value" } }
            end
          when "map"
            { name: key, label: "#{value['label']}".labelize }
          else
            { name: key, label: "#{value['label']}".labelize }
          end
        end
      end
    },
    object_output: {
      fields: lambda do |connection, config|
        get("/attask/api/#{connection['version']}/#{config['objCode']}/metadata")["data"]["fields"].
        map do |key, value|
          case value["fieldType"]
          when "string"
            if value["enumType"].blank?
              { name: key, label: "#{value['label']}".labelize }
            else
              string_list = value["possibleValues"].map do |item|
                [item["label"], item["value"]]
              end
              { name: key, label: "#{value['label']}".labelize, control_type: :select,
                pick_list: string_list,
                toggle_hint: "Select from list",
                toggle_field: {
                  name: key,
                  label: "#{value['label']}".labelize,
                  type: :string,
                  control_type: "text",
                  optional: false,
                  toggle_hint: "Use custom value" } }
            end
          when "double"
            { name: key, label: "#{value['label']}".labelize,
                type: :ineger, control_type: :number }
          when "date"
            { name: key, type: :date,  label: "#{value['label']}".labelize,
                control_type: :date_time }
          when "boolean"
            { name: key, label: "#{value['label']}".labelize, type: :boolean,
                control_type: :checkbox,
                toggle_hint: "Select from list",
                toggle_field: {
                  name: key,
                  label: "#{value['label']}".labelize,
                  type: :string,
                  control_type: "text",
                  optional: false,
                  toggle_hint: "Use custom value" } }
          when "string[]"
            if value["enumType"].blank?
              { name: key, label: "#{value['label']}".labelize }
            else
              select_list = value["possibleValues"].map do |item|
                [item["label"], item["value"]]
              end
              { name: key, label: "#{value['label']}".labelize, control_type: :select,
                pick_list: select_list,
                toggle_hint: "Select from list",
                toggle_field: {
                  name: key,
                  label: "#{value['label']}".labelize,
                  type: :string,
                  control_type: "text",
                  optional: false,
                  toggle_hint: "Use custom value" } }
            end
          when "dateTime"
            { name: key, type: :date_time, label: "#{value['label']}".labelize }
          when "int"
            if value["enumType"].blank?
              { name: key, label: "#{value['label']}".labelize, type: :integer,
                control_type: :number }
            else
              int_list = value["possibleValues"].map do |item|
                [item["label"], item["value"]]
              end
              { name: key, label: "#{value['label']}".labelize, control_type: :select,
                pick_list: int_list,
                toggle_hint: "Select from list",
                toggle_field: {
                  name: key,
                  label: "#{value['label']}".labelize,
                  type: :integer,
                  control_type: "number",
                  optional: false,
                  toggle_hint: "Use custom value" } }
            end
          when "map"
            { name: key, label: "#{value['label']}".labelize }
          else
            { name: key, label: "#{value['label']}".labelize }
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
              end }
        end
      end },
    custom_fields_input: {
      fields: lambda do |connection, config|
        char_mapping = {
          " " => "_space_",
          ":" => "_colon_"
        }

        if config["custom_fields"].blank?
          []
        else
         config["custom_fields"].split("\n").
            map do |field|
              {
                name: field.gsub(/[:\s]/, char_mapping),
                label: field,
                sticky: true
              }
            end
          
        end
      end
    }
  },

  test: lambda do |connection|
    get("/attask/api/#{connection['version']}/project/search?$$LIMIT=1")
  end,

  actions: {
    get_project_details_by_id: {
      description: 'Get <span class="provider">project</span> details by ID 
      in <span class="provider">Workfront</span>',
      subtitle: "Get project details in Workfront",
      help: "Fetches the project details for the given Project ID",
      config_fields: [
        {
          name: "custom_fields",
          control_type: "text-area",
          change_on_blur: true,
          hint: "Custom fields involved in this action. one per line. " \
           "fields with only colon and space are allowed." \
            " e.g. <code>DE:Project Manager</code>"
        }
      ],
      input_fields: lambda do
        [
          { name: "ID", type: :string, optional: false, label: "Project ID" }
        ]
      end,
      execute: lambda do |connection, input|
        project = get("/attask/api/#{connection['version']}/project/" + \
          input["ID"] + "?fields=*&fields=parameterValues")["data"]
      end,
      output_fields: lambda do |object_definitions|
        properties =  object_definitions["project"]
        properties << object_definitions["custom_object"] unless
         object_definitions["custom_object"].blank?
      end,
      sample_output: lambda do |connection|
        get("https://#{connection['subdomain']}.workfront.com/attask/api/" \
         "project/search?fields=*&$$LIMIT=1").dig("data", 0) || {}
      end
    },

    search_projects: {
      description: "Search <span class='provider'>projects</span> in 
      <span class='provider'>Workfront</span>",
      subtitle: "Search projects with project name in Workfront",
      help: "Search projects which matches the criteria from Workfront",
      config_fields: [
        {
          name: "custom_fields",
          control_type: "text-area",
          change_on_blur: true,
          hint: "Custom fields involved in this action. one per line. " \
           "fields with only colon and space are allowed." \
            " e.g. <code>DE:Project Manager</code>"
        }
      ],
      input_fields: lambda do |_object_definitions|
        [
          {
            name: "name", type: :string, optional: false,
            label: "Project name",
            hint: "Fetch projects that contains this keyword"
          }
        ]
      end,
      execute: lambda do |connection, input|
        projects = get("/attask/api/#{connection['version']}/project/search?" \
          "fields=*&fields=parameterValues&" \
          "name=" + input["name"] + "&name_Mod=contains")["data"]
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
          projects: get("/attask/api/#{connection['version']}/project/" \
            "search?fields=*&$$LIMIT=1").dig("data", 0) || {}
        }
      end
    },

    create_project: {
      description: "Create <span class='provider'>project</span> in 
      <span class='provider'>Workfront</span>",
      subtitle: "Create project with details in Workfront",
      help: "Select the feilds which are part of Project creation",
      config_fields: [
        {
          name: "custom_fields",
          control_type: "text-area",
          change_on_blur: true,
          sticky: true,
          hint: "Custom fields involved in this action. one per line." \
           " fields with only colon and space are allowed." \
            " e.g. <code>DE:Project Manager</code>"
        }
      ],
      input_fields: lambda do |object_definitions|
        object_definitions["project"].
          ignored("ID", "lastUpdateDate", "lastUpdatedByID",
                  "entryDate", "enteredByID").
          required("name").
          concat(object_definitions["custom_fields_input"])
      end,
      execute: lambda do |connection, input|
        input.delete("custom_fields")
        parameters = input.map do |key, value|
          if key.downcase.include?("date")
            { key => value.to_time.in_time_zone("US/Eastern").iso8601 }
          else
            { key.gsub("_space_", " ").gsub("_colon_", ":") => value }
          end
        end.inject(:merge)
        post("/attask/api/#{connection['version']}/project", parameters).
          params(fields: "*", fields: "parameterValues") ["data"]
      end,
      output_fields: lambda do |object_definitions|
        object_definitions["project"]
      end,
      sample_output: lambda do |connection|
        get("/attask/api/#{connection['version']}/project/search?" \
          "fields=*&$$LIMIT=1").dig("data", 0) || {}
      end
    },

    search_programs: {
      description: 'Search <span class="provider">programs</span> in
       <span class="provider">Workfront</span>',
      subtitle: "Search programs in Workfront",
      help: "Search programs by program name in Workfront",
      config_fields: [
        {
          name: "custom_fields",
          control_type: "text-area",
          change_on_blur: true,
          sticky: true,
          hint: "Custom fields involved in this action. one per line. " \
           "fields with only folon and space are allowed." \
            " e.g. <code>DE:Project Manager</code>"
        }
      ],
      input_fields: lambda do
        [
          {
            name: "name", type: :string, optional: false,
            label: "Program name",
            hint: "Fetch Programs that contains this keyword"
          }
        ]
      end,
      execute: lambda do |connection, input|
        programs = get("/attask/api/#{connection['version']}/program/" \
          "search?fields=*&fields=parameterValues&" \
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
      sample_output: lambda do |connection|
        {
          programs: get("/attask/api/#{connection['version']}/program/" \
            "search?fields=*&$$LIMIT=1").dig("data", 0) || {}
        }
      end
    },

    get_program_details_by_id: {
      description: 'Get <span class="provider">Program</span> details in
       <span class="provider">Workfront</span>',
      subtitle: "Get program details by ID in Workfront",
      help: "Get program details from Workfront",
      config_fields: [
        {
          name: "custom_fields",
          control_type: "text-area",
          change_on_blur: true,
          sticky: true,
          hint: "Custom fields involved in this action. one per line." \
           " fields with only colon and space are allowed." \
            " e.g. <code>DE:Project Manager</code>"
        }
      ],
      input_fields: lambda do
        [
          {
            name: "ID", type: :string, optional: false, label: "Program ID",
            hint: "Get Program details with Program ID"
          }
        ]
      end,
      execute: lambda do |connection, input|
        get("/attask/api/#{connection['version']}/program/" + \
          input["ID"] + "?fields=*&fields=parameterValues")["data"]
      end,
      output_fields: lambda do |object_definitions|
        properties =  object_definitions["program"]
        properties << object_definitions["custom_object"] unless
         object_definitions["custom_object"].blank?
      end,
      sample_output: lambda do |connection|
        get("/attask/api/#{connection['version']}/program/search?" \
          "fields=*&$$LIMIT=1").dig("data", 0) || {}
      end
    },
    get_issue_details_by_id: {
      description: 'Get <span class="provider">issue</span> details in
       <span class="provider">Workfront</span>',
      subtitle: "Get issue details by ID in Workfront",
      help: "Get issue details from Workfront",
      config_fields: [
        {
          name: "custom_fields",
          control_type: "text-area",
          change_on_blur: true,
          sticky: true,
          hint: "Custom fields involved in this action. one per line." \
           " fields with only colon and space are allowed." \
            " e.g. <code>DE:Project Manager</code>"
        }
      ],
      input_fields: lambda do
        [
          {
            name: "ID", type: :string, optional: false, label: "Issue ID",
            hint: "Get issue details with Issue ID"
          }
        ]
      end,
      execute: lambda do |connection, input|
        get("/attask/api/#{connection['version']}/optask/" \
        + input["ID"] + "?fields=*&fields=parameterValues")["data"]
      end,
      output_fields: lambda do |object_definitions|
        properties =  object_definitions["issue"]
        properties << object_definitions["custom_object"] unless
         object_definitions["custom_object"].blank?
      end,
      sample_output: lambda do |connection, _object_definitions|
        get("/attask/api/#{connection['version']}/optask/search?" \
          "fields=*&$$LIMIT=1").dig("data", 0) || {}
      end
    },
    create_issue: {
      description: "Create <span class='provider'>issue</span> in
       <span class='provider'>Workfront</span>",
      subtitle: "Create issue with details in Workfront",
      help: "Select the feilds which are part of Issue creation",
      config_fields: [
        {
          name: "custom_fields",
          control_type: "text-area",
          change_on_blur: true,
          sticky: true,
          hint: "Custom fields involved in this action. one per line." \
           " fields with only colon and space are allowed." \
            " e.g. <code>DE:Project Manager</code>"
        }
      ],
      input_fields: lambda do |object_definitions|
        [
          { name: "projectID", label: "Project Name", control_type: :select,
            pick_list: "projects",
            sticky: true,
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: "projectID",
              label: "projectID".labelize,
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use custom value" } },
          { name: "categoryID", label: "categoryID".labelize, sticky: true,
            hint: "Category ID is required if Custom fields are used." }
        ].
          concat(object_definitions["issue"].
            ignored("ID", "lastUpdateDate",
                    "lastUpdatedByID", "entryDate",
                    "enteredByID", "projectID", "categoryID")).
          required("projectID", "name").
          concat(object_definitions["custom_fields_input"])
      end,

      execute: lambda do |connection, input|
        input.delete("custom_fields")
        parameters = input.map do |key, value|
          if key.downcase.include?("date")
            { key => value.to_time.in_time_zone("US/Eastern").iso8601 }
          else
            { key.gsub("_space_", " ").gsub("_colon_", ":") => "#{value}" }
          end
        end.inject(:merge)
        post("/attask/api/#{connection['version']}/issue?fields=*").
          params(parameters) ["data"]
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["issue"]
      end,

      sample_output: lambda do |connection|
        get("/attask/api/#{connection['version']}/optask/search?" \
          "fields=*&$$LIMIT=1").dig("data", 0) || {}
      end
    },
    upload_document: {
      description: "Upload <span class='provider'>document</span> in
       <span class='provider'> to Object in Workfront</span>",
      subtitle: "Upload document to Object e.g. Project, Issue in Workfront",
      hint: "Upload supports only with Project, Issue objects",
      input_fields: lambda do
        [
          { name: "name", optional: false, label: "Document name",
            hint: "File name with extension" },
          { name: "docObjCode", optional: false, label: "Document object code",
            hint: "e.g. PROJ for Project" },
          { name: "objID", optional: false, label: "Object ID",
            hint: "e.g. Project ID for Project Object" },
          { name: "fileName", optional: false, label: "File name" },
          { name: "file", type: :file, optional: false, label: "File content" },
          { name: "version", type: :file, optional: false,
            label: "File version", hint: "only numbers allowed e.g. 1.0" }
        ]
      end,

      execute: lambda do |connection, input|
        handle = post("/attask/api/#{connection['version']}/upload").
          request_format_multipart_form.
          payload(uploadedFile: input["file"]) ["data"]["handle"]
        if handle.present?
          post("/attask/api/#{connection['version']}/document").
            payload(name: input["name"],
                    handle: handle,
                    docObjCode: input["docObjCode"],
                    objID: input["objID"],
                    currentVersion: { "version": input["version"],
                                      "fileName": input["fileName"] }) ["data"]
        end
      end,
      output_fields: lambda do
        [
          { name: "ID" },
          { name: "name" },
          { name: "objCode" },
          { name: "description" },
          { name: "lastUpdateDate", type: "date_time" }
        ]
      end,
      sample_output: lambda do
        {
          "ID": "58e7e2730050aa5fa78d2976b6d",
          "name": "Test",
          "objCode": "PROJ",
          "description": "Updated by lorem ipsum",
          "lastUpdateDate": "2017-04-21T21:27:38:155+0530"
        }
      end
    }
  },

  triggers: {
    new_updated_project: {
      description: "New or updated <span class='provider'>project</span> in
       <span class='provider'>Workfront</span>",
      subtitle: "New or updated project in Workfront",
      help: "Trigger polling time interval is based on user subscription.",
      config_fields: [
        {
          name: "port_id", control_type: :select,
          pick_list: :portfolios, label: "Portfolio",
          optional: false,
          hint: "Select portfolio to process projects belongs",
          toggle_hint: "Select from list",
          toggle_field: {
            name: "port_id",
            label: "Portfolio ID",
            type: :string,
            control_type: :text,
            optional: false,
            toggle_hint: "Use custom value",
            hint: "Provide the Portfolio ID for reading projects changes"
          }
        },
        {
          name: "custom_fields",
          control_type: "text-area",
          change_on_blur: true,
          hint: "Custom fields involved in this action. one per line." \
           " fields with only colon and space are allowed." \
            " e.g. <code>DE:Project Manager</code>"
        }
      ],
      input_fields: lambda do
        [
          name: "since", type: :date_time, sticky: true,
          label: "From", hint: "Fetch projects from specified Date"
        ]
      end,

      poll: lambda do |connection, input, last_updated_time|
        last_updated_time ||= (input["since"].presence || Time.now).to_time.
          in_time_zone("US/Central").iso8601
        projects = get("/attask/api/#{connection['version']}/project/" \
          "search?fields=*&fields=parameterValues").
          params(portfolioID: input["port_id"],
                portfolioID_Mod: "eq",
                lastUpdateDate: last_updated_time,
                lastUpdateDate_Mod: "gt",
                lastUpdateDate_Sort: "asc")["data"]
        last_updated_time = projects.last["lastUpdateDate"] unless
         projects.blank?
        {
          events: projects,
          next_poll: last_updated_time,
          can_poll_more: !projects.blank?
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
        get("/attask/api/#{connection['version']}/project/search?" \
          "fields=*&$$LIMIT=1").dig("data", 0)
      end
    },

    new_updated_issue: {
      description: "New or updated <span class='provider'>issue</span> in
       <span class='provider'>Workfront</span>",
      subtitle: "New or updated issue in Workfront",
      help: "Trigger polling time interval is based on user subscription.",
      config_fields: [
        {
          name: "custom_fields",
          control_type: "text-area",
          change_on_blur: true,
          sticky: true,
          hint: "Custom fields involved in this action. one per line." \
           " fields with only colon and space are allowed." \
            " e.g. <code>DE:Project Manager</code>"
        }
      ],
      input_fields: lambda do |_object_definitions|
        [
          name: "since", type: :date_time, sticky: true,
          label: "From", hint: "Fetch projects from specified Date"
        ]
      end,
      poll: lambda do |connection, input, last_updated_time|
        last_updated_time ||= (input["since"].presence || Time.now).to_time.
          in_time_zone("US/Central").iso8601
        issues = get("/attask/api/#{connection['version']}/optask/search?" \
          "fields=*&fields=parameterValues").
          params(lastUpdateDate: last_updated_time,
                lastUpdateDate_Mod: "gt",
                lastUpdateDate_Sort: "asc")["data"]
        last_updated_time = issues.last["lastUpdateDate"] unless
         issues.blank?
        {
          events: issues,
          next_poll: last_updated_time,
          can_poll_more: !issues.blank?
        }
      end,

      dedup: lambda do |issue|
        issue["ID"] + "@" + issue["lastUpdateDate"]
      end,

      output_fields: lambda do |object_definitions|
        properties =  object_definitions["issue"]
        properties << object_definitions["custom_object"] unless
         object_definitions["custom_object"].blank?
        properties
      end,

      sample_output: lambda do |connection, _object_definitions|
        get("/attask/api/#{connection['version']}/optask/search?" \
          "fields=*&$$LIMIT=1").dig("data", 0) || {}
      end
    },
    new_updated_object: {
      description: "New or updated <span class='provider'>Object</span> in
       <span class='provider'>Workfront</span>",
      subtitle: "New or updated Object in Workfront",
      help: "Trigger polling time interval is based on user subscription.",
      config_fields: [
        {
          name: "objCode", control_type: :select,
          pick_list: :objects, label: "Object",
          optional: false,
          hint: "Select Object",
          toggle_hint: "Select from list",
          toggle_field: {
            name: "objCode",
            label: "Object Code",
            type: :string,
            control_type: :text,
            optional: false,
            toggle_hint: "Use custom value",
            hint: "Provide the Object code"
          }
        },
        {
          name: "custom_fields",
          control_type: "text-area",
          change_on_blur: true,
          sticky: true,
          hint: "Custom fields involved in this action. one per line." \
           " fields with only colon and space are allowed." \
            " e.g. <code>DE:Project Manager</code>"
        }
      ],
      input_fields: lambda do
        [
          name: "since", type: :date_time, sticky: true,
          label: "From", hint: "Fetch objects from specified Date"
        ]
      end,

      poll: lambda do |connection, input, last_updated_time|
        last_updated_time ||= (input["since"].presence || Time.now).to_time.
          in_time_zone("US/Central").iso8601
        objects = get("/attask/api/#{connection['version']}/" \
          "#{input['objCode']}/search?fields=*&fields=parameterValues").
          params(lastUpdateDate: last_updated_time,
                lastUpdateDate_Mod: "gt",
                lastUpdateDate_Sort: "asc")["data"]
        last_updated_time = objects.last["lastUpdateDate"] unless
         objects.blank?
         {
          events: objects,
          next_poll: last_updated_time,
          can_poll_more: !objects.blank?
          }
      end,

      dedup: lambda do |object|
        object["ID"] + "@" + object["lastUpdateDate"]
      end,

      output_fields: lambda do |object_definitions|
        properties =  object_definitions["object_output"]
        properties << object_definitions["custom_object"] unless
         object_definitions["custom_object"].blank?
        properties
      end,

      sample_output: lambda do |connection, input|
        get("/attask/api/#{connection['version']}/#{input['objCode']}/search?" \
          "fields=*&$$LIMIT=1").dig("data", 0) || {}
      end

    }
  },
  pick_lists: {
    programs: lambda do |connection|
      get("/attask/api/#{connection['version']}/program/search?" \
        "fields=name,ID&$$LIMIT=500")["data"].pluck("name", "ID")
    end,
    portfolios: lambda do |connection|
      get("/attask/api/#{connection['version']}/port/search?" \
         "fields=name,ID&$$LIMIT=500")["data"].pluck("name", "ID")
    end,
    projects: lambda do |connection|
      get("/attask/api/#{connection['version']}/project/search?" \
        "fields=name,ID&$$LIMIT=500")["data"].pluck("name", "ID")
    end,
    objects: lambda do |connection|
      objects = get("/attask/api/#{connection['version']}/metadata").
      dig("data", "objects").
      map do |_, val|
          [val["name"], val["objCode"]]
        end
    end
  }
}
