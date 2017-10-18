{
  title: "Rally",
  alias: "CA Agile Central",

  connection: {
    fields: [
      { name: "username", control_type: :username, optional: false },
      { name: "password", control_type: :password, optional: false },
    ],

    authorization: {
      type: "custom_auth",

      acquire: lambda do |connection|
        response = get("https://rally1.rallydev.com/slm/webservice/v2.0/security/authorize").
                  user(connection["username"]).
                  password(connection["password"]).
                  request_format_www_form_urlencoded
        token = response.dig("OperationResult", "SecurityToken")
        [ { access_token: token }, nil, nil ]
      end,

      apply: lambda do |connection, access_token|
        user(connection["username"])
        password(connection["password"])
        request_format_www_form_urlencoded
        params(key: access_token)
      end
    }
  },

  test: ->(connection) {
    get("https://rally1.rallydev.com/slm/webservice/v2.0/user")["User"]
  },

  object_definitions: {

    ##
    # Defect (Input)
    # Workato queries the Rally schema endpoint, then recursively fetches each
    # defect's write-supported attribute down to the second layer using its
    # AllowedValueType.
    # At the lowest level, collections and objects are excluded.
    # Workspace and Project information excluded.
    # TestCase and Result objects excluded because of associated collections.
    # NB: Duplicates are only available in the output.
    defect_input: {
      fields: lambda do |connection, config_fields|
        schema = get("https://rally1.rallydev.com/slm/schema/v2.0/project/#{config_fields["project"]}").
                  dig("QueryResult", "Results")
        type_map = {
          "DATE"=>:timestamp,
          "INTEGER"=>:integer,
          "DECIMAL"=>:number,
          "BOOLEAN"=>:boolean,
          "OBJECT"=>:object,
          "COLLECTION"=>:array
        }
        has_inner_field = ["OBJECT", "COLLECTION"]
        must_ignore = ["Workspace", "Project", "Duplicates", "TestCase", "TestCaseResult"]
        generate_schema = lambda do |object, level|
          if level <= 2
            fields = schema.where("_refObjectName" => object)
            fields = fields.
                      first.
                      dig("Attributes").
                      select { |field|
                        !field["ReadOnly"] &&
                        (!must_ignore.include? field["ElementName"]) &&
                        (level == 1 || (!has_inner_field.include? field["AttributeType"]))
                      }.
                      map do |field|
                        {
                          name: field["ElementName"],
                          type: type_map[field["AttributeType"]]?
                                 type_map[field["AttributeType"]] : :string,
                          of: (field["AttributeType"] == "COLLECTION") ?
                                :object : nil,
                          properties: (has_inner_field.include? field["AttributeType"]) ?
                                        generate_schema[field["AllowedValueType"].
                                                          dig("_refObjectName"),
                                                        level+1]
                                        : nil,
                          optional: !field["Required"]
                        }
                      end unless !fields.present?
          end
        end
        generate_schema["Defect", 1]
      end
    },

    ##
    # Defect (Output)
    # Workato queries the Rally schema endpoint, then recursively fetches each
    # defect's readwrite-supported attribute down to the second layer using
    # its AllowedValueType.
    # At the lowest level, collections and objects are excluded.
    # Subscription, Workspace information excluded.
    # TestCase and Result objects excluded because of associated collections.
    # NB: Duplicates are returned as number of duplicates
    defect_output: {
      fields: lambda do |connection, config_fields|
        schema = get("https://rally1.rallydev.com/slm/schema/v2.0/project/#{config_fields["project"]}").
                  dig("QueryResult", "Results")
        type_map = {
          "DATE"=>:timestamp,
          "INTEGER"=>:integer,
          "DECIMAL"=>:number,
          "BOOLEAN"=>:boolean,
          "OBJECT"=>:object,
          "COLLECTION"=>:array
        }
        has_inner_field = ["OBJECT", "COLLECTION"]
        must_ignore = ["Subscription", "Workspace", "TestCase", "TestCaseResult"]
        generate_schema = lambda do |object, level|
          if level <= 2
            fields = schema.where("_refObjectName" => object)
            fields = fields.
                      first.
                      dig("Attributes").
                      select { |field|
                        (!must_ignore.include? field["ElementName"]) &&
                        (level == 1 || (!has_inner_field.include? field["AttributeType"]))
                      }.
                      map do |field|
                        {
                          name: field["ElementName"],
                          type: type_map[field["AttributeType"]]?
                                 type_map[field["AttributeType"]] : :string,
                          of: (field["AttributeType"] == "COLLECTION") ?
                                :object : nil,
                          properties: (has_inner_field.include? field["AttributeType"]) ?
                                        generate_schema[field["AllowedValueType"].
                                                          dig("_refObjectName"),
                                                        level+1]
                                        : nil
                        }
                      end unless !fields.present?
          end
        end
        generate_schema["Defect", 1]
      end
    },
  },

  actions: {
    create_defect: {
      description: 'Create <span class="provider">defect</span> '\
                   'in <span class="provider">Rally</span>',
      subtitle: "Create defect in Rally",

      config_fields: [
        { name: "project", optional: false, control_type: :select,
          pick_list: "projects" }
      ],

      input_fields: lambda do |object_definitions|
        object_definitions["defect_input"]
      end,

      execute: lambda do |connection, input|
        post("https://rally1.rallydev.com/slm/webservice/v2.0/defect/create").
          params(
            project:
              "https://rally1.rallydev.com/slm/webservice/v2.0/project/#{input["project"]}"
          ).
          payload("Defect": input)["CreateResult"]
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["defect_output"]
      end,

      sample_output: lambda do |connection, input|
        get(get("https://rally1.rallydev.com/slm/webservice/v2.0/defect").
              dig("QueryResult", "Results").first.
              dig("_ref")).
          dig("Defect")
      end
    },

    get_defect_by_id: {
      description: 'Get <span class="provider">defect</span> '\
                   'by ID in <span class="provider">Rally</span>',
      subtitle: "Get defect by ID in Rally",

      config_fields: [
        { name: "project", optional: false, control_type: :select,
          pick_list: "projects" }
      ],

      input_fields: lambda do |object_definitions|
        [
          { name: "ObjectID", label: "ID", optional: false },
        ]
      end,

      execute: lambda do |connection, input|
        defect = get("https://rally1.rallydev.com/slm/webservice/v2.0/defect/#{input["ObjectID"]}").
          params(
            project:
              "https://rally1.rallydev.com/slm/webservice/v2.0/project/#{input["project"]}"
          ).
          dig("Defect")
          defect.each do |k,v|
            #TODO Streamline type checking
            if v.to_s.starts_with?("{") && v["Count"]
              defect[k] = get(v["_ref"]).dig("QueryResult", "Results")
            end
          end
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["defect_output"]
      end,

      sample_output: lambda do |connection, input|
        get("https://rally1.rallydev.com/slm/webservice/v2.0/defect/#{input["ObjectID"]}").
          dig("Defect")
      end
    },

    test_action: {
      execute: lambda do |connection, input|
        a = get("https://rally1.rallydev.com/slm/schema/v2.0/project/161272469544").
              dig("QueryResult", "Results").
              where("Name" => "Defect").first.
              dig("Attributes").
              map do |field|
                {
                  name: field["ElementName"],
                }
              end
              puts a.to_s
        { }
      end
    }
  },

  triggers: {
    new_or_updated_defect: {
      description: 'New or updated <span class="provider">defect</span> '\
                   'logged in <span class="provider">Rally</span>',
      subtitle: "New or updated defect logged in Rally",
      type: :paging_desc,

      config_fields: [
        { name: "project", optional: false, control_type: :select,
          pick_list: "projects" }
      ],

      input_fields: lambda do
        [
          { name: "from", type: :date, optional: false }
        ]
      end,

      poll: lambda do |connection, input, page|
        limit = 20
        page ||= 0
        from = input["from"].to_time.iso8601.to_s
        response = get("https://rally1.rallydev.com/slm/webservice/v2.0/defect").
          params(
            order: "LastUpdateDate desc",
            pagesize: limit,
            query: "(LastUpdateDate >= #{from})",
            project:
              "https://rally1.rallydev.com/slm/webservice/v2.0/project/#{input["project"]}")
        ref_defects = response.dig("QueryResult", "Results")
        defects = ref_defects.map do |d|
          defect = get(d["_ref"])["Defect"]
          defect.each do |k,v|
            #TODO Streamline type checking
            if v.to_s.starts_with?("{") && v["Count"]
              defect[k] = get(v["_ref"]).dig("QueryResult", "Results")
            end
          end
        end
        {
          events: defects,
          next_page: defects.length >= limit ? page + 1 : nil
        }
      end,

      document_id: lambda do |defect|
        defect["ObjectID"].to_s + "@" + defect["LastUpdateDate"]
      end,

      sort_by: lambda do |defect|
        defect["LastUpdateDate"]
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["defect_output"]
      end,

      sample_output: lambda do |connection|
        get(get("https://rally1.rallydev.com/slm/webservice/v2.0/defect").
              params(pagesize: 1, fetch: "ObjectID").
              dig("QueryResult", "Results").first["_ref"]).
          dig("Defect")
      end
    }
  },

  pick_lists: {
    projects: lambda do |connection|
      get("https://rally1.rallydev.com/slm/webservice/v2.0/project").
        params(fetch: "Name,ObjectID").
        dig("QueryResult", "Results").
        map { |project| [project["Name"], project["ObjectID"].to_s] }
    end
  }

}
