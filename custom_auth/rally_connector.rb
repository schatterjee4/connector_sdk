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
    # Preliminary
    defect: {
      fields: ->(connection, config_fields) {
        type_map = {
          "DATE"=>:datetime,
          "INTEGER"=>:integer,
          "DECIMAL"=>:number,
          "BOOLEAN"=>:boolean,
          "OBJECT"=>:object,
          "COLLECTION"=>:array
        }
        if config_fields["workspace"]
          attributes = get("https://rally1.rallydev.com/slm/schema/v2.0/workspace/#{config_fields["workspace"]}").
                         dig("QueryResult", "Results").
                         where("Name" => "Defect").first.
                         dig("Attributes")
          attributes.map do |field|
            if !field["ReadOnly"]
              {
                name: field["ElementName"],
                type: type_map["#{field["AttributeType"]}"]? type_map["#{field["AttributeType"]}"] : :string,
                of: field["AttributeType"] == "COLLECTION"? :object : nil
              }
            end
          end
        else
          [
            { name: "Name" },
            { name: "Description" },
            { name: "Notes" },
            { name: "Owner" },
            { name: "DisplayColor" },
            { name: "Expedite", label: "Expedite?", type: :boolean },
            { name: "Ready", label: "Ready?", type: :boolean },
            { name: "CreationDate", type: :datetime },
            { name: "LastUpdateDate", type: :datetime },
            { name: "ObjectID", type: :integer },
            { name: "ObjectUUID" },
            { name: "VersionId", type: :integer },
            { name: "Description" },
            { name: "Project" },
          ]
        end
      }
    }
  },

  actions: {
    create_defect: {
      description: 'Create <span class="provider">defect</span> '\
                   'in <span class="provider">Rally</span>',
      subtitle: "Create defect in Rally",

      input_fields: lambda do |object_definitions|
        object_definitions["defect"]
      end,

      execute: lambda do |connection, input|
        post("https://rally1.rallydev.com/slm/webservice/v2.0/defect/create").
          payload("Defect": input)["CreateResult"]
      end
    },

    get_defect_by_id: {
      description: 'Get <span class="provider">defect</span> '\
                   'by ID in <span class="provider">Rally</span>',
      subtitle: "Get defect by ID in Rally",

      config_fields: [
        { name: "workspace", optional: false, control_type: :select,
          pick_list: "workspaces" }
      ],

      input_fields: lambda do |object_definitions|
        [
          { name: "ObjectID", label: "ID", optional: false },
        ].concat(object_definitions["defect"])
      end,

      execute: lambda do |connection, input|
        get("https://rally1.rallydev.com/slm/webservice/v2.0/defect/#{input["ObjectID"]}").
          dig("Defect")
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["defect"]
      end,

      sample_output: lambda do |connection, input|
        get("https://rally1.rallydev.com/slm/webservice/v2.0/defect/#{input["ObjectID"]}").
          dig("Defect")
      end
    },

    test_action: {
      execute: lambda do |connection, input|
        a = get("https://rally1.rallydev.com/slm/schema/v2.0/workspace/161272469544").
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
        object_definitions["defect"]
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
    workspaces: lambda do |connection|
      get("https://rally1.rallydev.com/slm/webservice/v2.0/workspace").
        params(fetch: "Name,ObjectID").
        dig("QueryResult", "Results").
        map { |workspace| [workspace["Name"], workspace["ObjectID"].to_s] }
    end
  }

}
