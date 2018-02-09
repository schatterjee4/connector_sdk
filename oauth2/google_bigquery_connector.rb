{
  title: "Google BigQuery",

  connection: {
    fields: [
      {
        name: "client_id",
        hint: "Find client ID " \
          "<a href='https://console.cloud.google.com/apis/credentials' " \
          "target='_blank'>here</a>",
        optional: false,
      },
      {
        name: "client_secret",
        hint: "Find client secret " \
          "<a href='https://console.cloud.google.com/apis/credentials' " \
          "target='_blank'>here</a>",
        optional: false,
        control_type: "password",
      }
    ],

    authorization: {
      type: "oauth2",

      authorization_url: lambda do |connection|
        scopes = [
          "https://www.googleapis.com/auth/bigquery",
          "https://www.googleapis.com/auth/bigquery.insertdata",
          "https://www.googleapis.com/auth/cloud-platform",
          "https://www.googleapis.com/auth/cloud-platform.read-only",
          "https://www.googleapis.com/auth/devstorage.full_control",
          "https://www.googleapis.com/auth/devstorage.read_only",
          "https://www.googleapis.com/auth/devstorage.read_write",
        ].join(" ")

        "https://accounts.google.com/o/oauth2/auth?client_id="            \
          "#{connection['client_id']}&response_type=code&scope=#{scopes}" \
          "&access_type=offline&include_granted_scopes=true&prompt=consent"
      end,

      acquire: lambda do |connection, auth_code, redirect_uri|
        response = post("https://accounts.google.com/o/oauth2/token").
                    payload(client_id: connection["client_id"],
                            client_secret: connection["client_secret"],
                            grant_type: "authorization_code",
                            code: auth_code,
                            redirect_uri: redirect_uri).
                    request_format_www_form_urlencoded

        [response, nil, nil]
      end,

      refresh: lambda do |connection, refresh_token|
        post("https://accounts.google.com/o/oauth2/token").
          payload(client_id: connection["client_id"],
                  client_secret: connection["client_secret"],
                  grant_type: "refresh_token",
                  refresh_token: refresh_token).
          request_format_www_form_urlencoded
      end,

      refresh_on: [401],

      detect_on: [/"errors"\:\s*\[/],

      apply: lambda do |_connection, access_token|
        headers(Authorization: "Bearer #{access_token}")
      end,
    },

    base_uri: ->(_connection) { "https://www.googleapis.com" }
  },

  test: ->(_connection) { get("/bigquery/v2/projects").params(maxResults: 1) },

  object_definitions: {
    table_schema: {
      fields: lambda do |_connection, config_fields|
        project_id = config_fields["project"]
        dataset_id = config_fields["dataset"]
        table_id = config_fields["table"]
        type_map = {
          "BYTES" => "string",
          "INTEGER" => "integer", "INT64" => "integer",
          "FLOAT" => "number", "FLOAT64" => "number",
          "BOOLEAN" => "boolean", "BOOL" => "boolean",
          "TIMESTAMP" => "timestamp",
          "DATE" => "date",
          "TIME" => "date_time",
          "DATETIME" => "date_time",
          "RECORD" => "object", "STRUCT" => "object"
        }
        control_type_map = {
          "BYTES" => "text-area",
          "INTEGER" => "number", "INT64" => "number",
          "FLOAT" => "number", "FLOAT64" => "number",
          "BOOLEAN" => "checkbox", "BOOL" => "checkbox",
          "TIMESTAMP" => "date_time",
          "DATE" => "date",
          "TIME" => "date_time",
          "DATETIME" => "date_time",
          "RECORD" => "", "STRUCT" => ""
        }

        build_schema_field = lambda do |field|
          field_type = type_map[field["type"]]

          {
            name: field["name"],
            label: field["name"],
            hint: field["description"],
            optional: (field["mode"] != "REQUIRED"),
            control_type: control_type_map[field["type"]],
            type: field_type,
            properties: if field_type == "object"
                          field["fields"].map do |inner_field|
                            build_schema_field[inner_field]
                          end
                        end
          }
        end

        [
          name: "rows",
          optional: false,
          type: "array",
          of: "object",
          properties: [
            {
              name: "insertId",
              hint: "A unique ID for each row. Google BigQuery uses this " \
               "property to detect duplicate insertion requests on a "     \
               "best-effort basis. Find more information <a "              \
               "href='https://cloud.google.com/bigquery/streaming-data-"   \
               "into-bigquery#dataconsistency' target='_blank'>here</a>.",
            }
          ].concat((if project_id && dataset_id && table_id
                      get("/bigquery/v2/projects/#{project_id}/datasets/"  \
                        "#{dataset_id}/tables/#{table_id}").
                        dig("schema", "fields")
                    else
                      []
                    end).map { |table_field| build_schema_field[table_field] })
        ]
      end
    }
  },

  actions: {
    add_rows: {
      subtitle: "Add data rows",
      description: "Add <span class='provider'>rows</span> to dataset" \
        " in <span class='provider'>Google BigQuery</span>",
      help: "Streams data into a table of Google BigQuery.",

      config_fields: [
        {
          name: "project",
          hint: "Select the appropriate project to insert data",
          optional: false,
          control_type: "select",
          pick_list: "projects"
        },
        {
          name: "dataset",
          control_type: "select",
          pick_list: "datasets",
          pick_list_params: { project_id: "project" },
          optional: false,
          hint: "Select a dataset to view list of tables"
        },
        {
          name: "table",
          control_type: "select",
          pick_list: "tables",
          pick_list_params: { project_id: "project", dataset_id: "dataset" },
          optional: false,
          hint: "Select a table to stream data"
        },
      ],

      input_fields: lambda do |object_definitions|
        object_definitions["table_schema"]
      end,

      execute: lambda do |_connection, input|
        rows = input["rows"]
        table_schema = get("/bigquery/v2/projects/#{input['project']}"  \
                         "/datasets/#{input['dataset']}"  \
                         "/tables/#{input['table']}").
                       dig("schema", "fields")

        build_processed_row = lambda do |row, schema_info|
          schema_info.map do |table_field|
            if row[table_field["name"]].present?
              row[table_field["name"]] = case table_field["type"]
                                         when "TIME"
                                           row[table_field["name"]].
                                         to_time.
                                         strftime("%H:%M:%S.%6N")
                                         when "DATETIME"
                                           row[table_field["name"]].
                                         to_time.
                                         strftime("%Y-%m-%dT%H:%M:%S.%6N")
                                         when "RECORD", "STRUCT"
                                           build_processed_row[
                                             row[table_field["name"]],
                                             table_field["fields"]
                                           ]
                                         else
                                           row[table_field["name"]]
                                         end
            end
          end

          row
        end

        post("/bigquery/v2/projects/#{input['project']}/datasets/" \
          "#{input['dataset']}/tables/#{input['table']}/insertAll").
          params(fields: "kind,insertErrors").
          payload(rows: rows.map do |row|
                          row = build_processed_row[row, table_schema]
                          { insertId: row.delete("insertId") || "", json: row }
                        end)
      end,

      output_fields: ->(_object_definitions) { [{ name: "kind" }] },

      sample_output: -> { { kind: "bigquery#tableDataInsertAllResponse" } }
    }
  },

  pick_lists: {
    projects: lambda do |_connection|
      get("/bigquery/v2/projects").dig("projects").pluck("friendlyName", "id")
    end,

    datasets: lambda do |_connection, project_id:|
      get("/bigquery/v2/projects/#{project_id}/datasets").
        dig("datasets").
        map do |dataset|
          [dataset["datasetReference"]["datasetId"],
           dataset["datasetReference"]["datasetId"]]
        end
    end,

    tables: lambda do |_connection, project_id:, dataset_id:|
      get("/bigquery/v2/projects/#{project_id}/datasets/#{dataset_id}/tables").
        dig("tables").
        map do |table|
          [table["tableReference"]["tableId"],
           table["tableReference"]["tableId"]]
        end
    end
  }
}
