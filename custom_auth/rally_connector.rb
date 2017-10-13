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
    defect_input: {
      fields: lambda do |connection, config_fields|
        schema = get("https://rally1.rallydev.com/slm/schema/v2.0/project/#{config_fields["project"]}").
                  dig("QueryResult", "Results")
        type_map = {
          "DATE"=>:datetime,
          "INTEGER"=>:integer,
          "DECIMAL"=>:number,
          "BOOLEAN"=>:boolean,
          "OBJECT"=>:object,
          "COLLECTION"=>:array
        }
        has_inner_field = ["OBJECT", "COLLECTION"]
        generate_schema = lambda do |object, level|
          if level <= 1
            fields = schema.where("Name" => object)
            fields = fields.
                      first.
                      dig("Attributes").
                      select { |field| !field["ReadOnly"] && field["ElementName"] != "Workspace" }.
                      map do |field|
                        {
                          name: field["ElementName"],
                          type: type_map["#{field["AttributeType"]}"]?
                                 type_map["#{field["AttributeType"]}"] : :string,
                          of: (field["AttributeType"] == "COLLECTION") ?
                                :object : nil,
                          properties: (has_inner_field.include? field["AttributeType"]) ?
                                        generate_schema[field["SchemaType"].gsub("Type"), level+1] : nil
                        }
                      end unless !fields.present?
          end
        end
        generate_schema["Defect", 0]
      end
    },

    # defect_output: {
    #   fields: lambda do |connection, config_fields|
    #     type_map = {
    #       "DATE"=>:datetime,
    #       "INTEGER"=>:integer,
    #       "DECIMAL"=>:number,
    #       "BOOLEAN"=>:boolean,
    #       "OBJECT"=>:object,
    #       "COLLECTION"=>:array
    #     }
    #     has_inner_field = ["OBJECT, COLLECTION"]
    #     generate_schema = lambda do |object|
    #       get("https://rally1.rallydev.com/slm/schema/v2.0/project/#{config_fields["project"]}").
    #         dig("QueryResult", "Results").
    #         where("Name" => object).first.
    #         dig("Attributes").
    #         map do |field|
    #           {
    #             name: field["ElementName"],
    #             type: type_map["#{field["AttributeType"]}"]?
    #                    type_map["#{field["AttributeType"]}"] : :string,
    #             of: (field["AttributeType"] == "COLLECTION"?
    #                   :object : nil),
    #             properties: (has_inner_field.include? field["AttributeType"] ?
    #                           generate_schema[field["ElementName"]] : nil)
    #           }
    #         end
    #     end
    #     puts generate_schema["Defect"]
    #   end
    # }
    #
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
          payload("Defect": input)["CreateResult"]
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["defect_input"]
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
        get("https://rally1.rallydev.com/slm/webservice/v2.0/defect/#{input["ObjectID"]}").
          dig("Defect")
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["defect_input"]
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
        from = input["from"].to_time
        response = get("https://rally1.rallydev.com/slm/webservice/v2.0/defect").
          params(
            order: "LastUpdateDate desc",
            pagesize: limit)
        ref_defects = response.dig("QueryResult", "Results")
        defects = ref_defects.map { |d| get(d["_ref"])["Defect"] }
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
        object_definitions["defect_input"]
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
