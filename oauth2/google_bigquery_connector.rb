{
  title: 'Google BigQuery',

  connection: {
    fields: [
      {
        name: "client_id",
        hint: "Find it " \
          "<a href='https://console.cloud.google.com/apis/credentials'>" \
          "here</a>",
        optional: false,
      },
      {
        name: "client_secret",
        hint: "Find it " \
          "<a href='https://console.cloud.google.com/apis/credentials'>" \
          "here</a>",
        optional: false,
        control_type: "password",
      }
    ],

    authorization: {
      type: 'oauth2',

      authorization_url: ->(connection) {
        scopes = [
          "https://www.googleapis.com/auth/bigquery",	# View and manage your data in Google BigQuery
          "https://www.googleapis.com/auth/bigquery.insertdata",	# Insert data into Google BigQuery
          "https://www.googleapis.com/auth/cloud-platform",		# View and manage your data across Google Cloud Platform services
          "https://www.googleapis.com/auth/cloud-platform.read-only",	# View your data across Google Cloud Platform services
          "https://www.googleapis.com/auth/devstorage.full_control",	# Manage your data and permissions in Google Cloud Storage
          "https://www.googleapis.com/auth/devstorage.read_only",	# View your data in Google Cloud Storage
          "https://www.googleapis.com/auth/devstorage.read_write",	# Manage your data in Google Cloud Storage
        ].join(" ")

        "https://accounts.google.com/o/oauth2/auth?client_id=" \
          "#{connection["client_id"] }&response_type=code&scope=#{scopes}" \
          "&access_type=offline&include_granted_scopes=true&prompt=consent"
      },

      acquire: ->(connection, auth_code, redirect_uri) {
        response = post("https://accounts.google.com/o/oauth2/token")
          .payload(
            client_id: connection["client_id"],
            client_secret: connection["client_secret"],
            grant_type: "authorization_code",
            code: auth_code,
            redirect_uri: redirect_uri,
          )
          .request_format_www_form_urlencoded

        [
          {
            access_token: response["access_token"],
            refresh_token: response["refresh_token"],
          },
          nil,
          nil,
        ]
      },

      refresh: ->(connection, refresh_token) {
        post("https://accounts.google.com/o/oauth2/token")
          .payload(
            client_id: connection["client_id"],
            client_secret: connection["client_secret"],
            grant_type: "refresh_token",
            refresh_token: refresh_token,
          )
          .request_format_www_form_urlencoded
      },

      refresh_on: [401],

      apply: ->(_connection, access_token) {
        headers(Authorization: "Bearer #{access_token}")
      },
    },
  },

  test: ->(_connection) {
    get("https://www.googleapis.com/bigquery/v2/projects")
      .params(maxResults: 1)
  },

  object_definitions: {
    table_schema: {
      fields: ->(_connection, config_fields) {
        project_id = config_fields["project"]
        dataset_id = config_fields["dataset"]
        table_id = config_fields["table"]

        table_fields = if (project_id && dataset_id && table_id)
          get("https://www.googleapis.com/bigquery/v2/projects/" \
            "#{project_id}/datasets/#{dataset_id}/tables/#{table_id}")
            .dig("schema", "fields")
        else
          []
        end

        type_map = {
          "BYTES" => "string",
          "INTEGER" => "integer", "INT64" => "integer",
          "FLOAT" => "number", "FLOAT64" => "number",
          "BOOLEAN" => "boolean", "BOOL" => "boolean",
          "TIMESTAMP" => "timestamp",
          "DATE" => "date",
          "TIME" => "string",
          "DATETIME" => "string",
          "RECORD" => "object", "STRUCT" => "object",
        }

        hint_map = {
          "STRING" => " | Variable-length character (UTF-8) data.",
          "BYTES" => " | Variable-length binary data.",
          "INTEGER" => " | 64-bit signed integer.",
          "FLOAT" => " | Double-precision floating-point format.",
          "BOOLEAN" => " | Boolean values are represented by the keywords" \
            " true and false (case insensitive). Example: true",
          "TIMESTAMP" => " | Represents an absolute point in time, with" \
            " microsecond precision. Example: 9999-12-31 23:59:59.999999 UTC",
          "DATE" => " | Represents a logical calendar date." \
            " Example: 2017-09-13",
          "TIME" => " | Represents a time, independent of a specific date." \
            " Example: 11:16:00.000000",
          "DATETIME" => " | Represents a year, month, day, hour, minute," \
            " second, and subsecond. Example: 2017-09-13T11:16:00.000000",
          "RECORD" => " | A collection of one or more other fields.", # info - https://cloud.google.com/bigquery/data-types
        }

        build_schema_field = ->(field) {
          field_name = field["name"].downcase
          field_hint = if (field["description"] && hint_map[field["type"]])
            (field["description"] + hint_map[field["type"]])
          else
            (field["description"] || hint_map[field["type"]])
          end
          field_optional = (field["mode"] != "REQUIRED")
          field_type = type_map[field["type"]]

          if %W[RECORD, STRUCT].include? field["type"]
            {
              name: field_name,
              hint: field_hint,
              optional: field_optional,
              type: field_type,
              properties: field["fields"].map do |inner_field|
                build_schema_field[inner_field]
              end
            }
          else
            {
              name: field_name,
              hint: field_hint,
              optional: field_optional,
              type: field_type,
            }
          end
        }

        table_schema_fields = [
          {
            name: "insertId",
            hint: "A unique ID for each row. BigQuery uses this property" \
              " to detect duplicate insertion requests on a best-effort basis"
          }
        ].
        concat(table_fields.map do |table_field|
          build_schema_field[table_field]
        end)

        [
          name: "rows",
          optional: false,
          hint: "A JSON object that contains a row of data. The object's" \
            " properties and values must match the destination table's schema",
          type: "array",
          of: "object",
          properties: table_schema_fields
        ]
      }
    }
  },

  actions: {
    add_rows: {
      description: "Add <span class='provider'>rows to dataset</span>" \
        " in <span class='provider'>BigQuery</span>",
      subtitle: "Add data rows",
      help: "Streams data into a table in BigQuery.",

      config_fields:
      [
        {
          name: "project",
          hint: "Select the appropriate Project to import data",
          optional: false,
          control_type: "select",
          pick_list: "projects",
        },
        {
          name: "dataset",
          control_type: "select",
          pick_list: "datasets",
          pick_list_params: { project_id: "project" },
          optional: false,
          hint: "Select a dataset to view list of tables",
        },
        {
          name: "table",
          control_type: "select",
          pick_list: "tables",
          pick_list_params: { project_id: "project", dataset_id: "dataset" },
          optional: false,
          hint: "Select a table to stream data",
        },
      ],

      input_fields: lambda do |object_definitions|
        object_definitions["table_schema"]
      end,

      execute: lambda do |_connection, input|
        project_id = input["project"]
        dataset_id = input["dataset"]
        table_id = input["table"]
        rows = input["rows"] || []

        payload = {
          "rows" =>	rows.map do |row|
            {
              "insertId": row.delete("insertId") || "",
              "json" => row
            }
          end
        }

        post("https://www.googleapis.com/bigquery/v2/projects/" \
          "#{project_id}/datasets/#{dataset_id}/tables/#{table_id}/insertAll").
          params(fields: "kind,insertErrors").
          payload(payload)
      end,

      output_fields: lambda do |_object_definitions|
        [
          { name: "kind" },
        ]
      end,

      sample_output: lambda do
        {
          kind: "bigquery#tableDataInsertAllResponse",
        }
      end
    }
  },

  pick_lists: {
    projects: lambda do |_connection|
      get("https://www.googleapis.com/bigquery/v2/projects").
        dig("projects").
        map do |project|
          [project["friendlyName"], project["id"]]
        end
    end,

    datasets: lambda do |_connection, project_id:|
      get("https://www.googleapis.com/bigquery/v2/projects/" \
        "#{project_id}/datasets").
        dig("datasets").
        map do |dataset|
          [
            dataset["datasetReference"]["datasetId"],
            dataset["datasetReference"]["datasetId"]
          ]
        end
    end,

    tables: lambda do |_connection, project_id:, dataset_id:|
      get("https://www.googleapis.com/bigquery/v2/projects/" \
        "#{project_id}/datasets/#{dataset_id}/tables").
        dig("tables").map do |table|
          [
            table["tableReference"]["tableId"],
            table["tableReference"]["tableId"]
          ]
        end
    end
  }
}
