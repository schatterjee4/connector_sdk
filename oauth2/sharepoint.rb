{
  title: "Microsoft Sharepoint",

  connection: {
    fields: [
      {
        name: "subdomain",
        control_type: "subdomain",
        url: ".sharepoint.com",
        optional: false,
        hint: "Your sharepoint subdomain found in your sharepoint URL",
      },
      {
        name: "client_id",
        optional: false
      }
    ],

    authorization: {
      type: "oauth2",
      authorization_url: ->(connection) {
        "https://login.windows.net/common/oauth2/authorize?resource=
        https://#{connection['subdomain']}.sharepoint.com&response_type=code&
        prompt=login&client_id=#{connection['client_id']}"
      },

      acquire: lambda do |connection, auth_code, redirect_url|
        post("https://login.windows.net/common/oauth2/token").
        payload(client_id: connection["client_id"],
          grant_type: :authorization_code,
          code: auth_code,
          redirect_uri: redirect_url).
        request_format_www_form_urlencoded
      end,

      refresh: lambda do |connection, refresh_token|
        post("https://login.windows.net/common/oauth2/token").
        payload(client_id: connection["client_id"],
          grant_type: :refresh_token,
          refresh_token: refresh_token).
        request_format_www_form_urlencoded
      end,

      credentials: lambda do |_connection, access_token|
        headers("Authorization": "Bearer #{access_token}")
      end
    }
  },

  test: lambda do |connection|
    get("https://#{connection['subdomain']}.sharepoint.com/_api/web/lists")
  end,

  object_definitions: {
    list_create: {
      fields: lambda do |connection, config|
        get("https://#{connection['subdomain']}.sharepoint.com/_api/web/" \
            "lists(guid%27#{config['list_id']}%27)/Fields").
          params("$select": "odata.type,EntityPropertyName,Hidden,Required,
          ReadOnlyField,Title,TypeAsString,Choices,IsDependentLookup")["value"].
          select { |f| f["ReadOnlyField"] == false &&
           f["Hidden"] == false && f["TypeAsString"] != "Attachments" &&
            f["EntityPropertyName"] != "ContentType" }.
          map do |f|
            if f["odata.type"] == "SP.Field" 
              {
               name: f["EntityPropertyName"],
               label: "#{f['Title']} (#{f['EntityPropertyName']})",
               type: :boolean, optional: !f["Required"] 
              }
            elsif f["odata.type"] == "SP.FieldNumber"
              { 
                name: f["EntityPropertyName"],
                label: "#{f['Title']} (#{f['EntityPropertyName']})",
                type: :integer, optional: !f["Required"] 
              }
            elsif f["odata.type"] == "SP.FieldDateTime"
              { 
                name: f["EntityPropertyName"],
                label: "#{f['Title']} (#{f['EntityPropertyName']})",
                type: :date_time, optional: !f["Required"] 
              }
            elsif f["odata.type"] == "SP.FieldChoice"
              { 
                name: f["EntityPropertyName"],
                label: "#{f['Title']} (#{f['EntityPropertyName']})", 
                control_type: :select,
                optional: !f["Required"],
                pick_list: f["Choices"]&.map { |choice| [choice, choice] },
                toggle_hint: "Select from list", 
                toggle_field: {
                  toggle_hint: "Enter custom value",
                  name: f["EntityPropertyName"], type: "string",
                  control_type: "text",
                  label: "#{f['Title']}(#{f['EntityPropertyName']})",
                  optional: !f["Required"]
                } 
              }
            elsif f["odata.type"] == "SP.FieldUser"
              {
                name: "#{f['EntityPropertyName']}Id",
                label: "#{f['Title']} (#{f['EntityPropertyName']})",
                type: :integer, optional: !f["Required"]
              }
            elsif f["odata.type"] == "SP.FieldLookup" && f["IsDependentLookup"] == false
              {
                name: "#{f['EntityPropertyName']}Id",
                label: "#{f['Title']} (#{f['EntityPropertyName']})",
                optional: !f["Required"], type: :integer 
              }
            elsif f["odata.type"] == "SP.FieldUrl"
              {
                name: f["EntityPropertyName"],
                label: "#{f['Title']} (#{f['EntityPropertyName']})",
                type: :object, properties: [
                  { name: "Description" },
                  { name: "Url" }
                ] 
              }
            else
              {
                name: f["EntityPropertyName"],
                label: "#{f['Title']} (#{f['EntityPropertyName']})",
                optional: !f["Required"]
              }
            end
        end
      end
    },

    list_output: {
      fields: lambda do |connection, config|
        get("https://#{connection['subdomain']}.sharepoint.com/_api/web/" \
         "lists(guid%27#{config['list_id']}%27)/Fields").
          params("$select": "odata.type,Title,TypeAsString,
            EntityPropertyName,IsDependentLookup")["value"].
          map do |f|
            if f["odata.type"] == "SP.FieldNumber" || f["TypeAsString"] == "Counter"
              {
                name: f["EntityPropertyName"],
                label: "#{f['Title']} (#{f['EntityPropertyName']})", type: :integer 
              }
            elsif f["odata.type"] == "SP.Field"
              {
                name: f["EntityPropertyName"],
                label: "#{f['Title']} (#{f['EntityPropertyName']})", type: :boolean
              }
            elsif f["odata.type"] == "SP.FieldDateTime"
              {
                name: f["EntityPropertyName"],
                label: "#{f['Title']} (#{f['EntityPropertyName']})", type: :date_time
              }
            elsif f["odata.type"] == "SP.FieldUser"
              {
                name: "#{f['EntityPropertyName']}Id",
                label: "#{f['Title']} (#{f['EntityPropertyName']})", type: :integer
              }
            elsif f["odata.type"] == "SP.FieldLookup" && f["IsDependentLookup"] == false
              {
                name: "#{f['EntityPropertyName']}Id",
                label: "#{f['Title']} (#{f['EntityPropertyName']})", type: :integer
              }
            elsif f["odata.type"] == "SP.FieldUrl"
              {
                name: f["EntityPropertyName"],
                label: "#{f['Title']} (#{f['EntityPropertyName']})",
                type: :object, properties: [
                  { name: "Description" },
                  { name: "Url" }
                ]
              }
            elsif f["odata.type"] == "SP.Taxonomy.TaxonomyField"
              {
                name: "#{f['EntityPropertyName']}Id",
                label: "#{f['Title']} (#{f['EntityPropertyName']})",
                type: :object, properties: [
                  { name: "Label" },
                  { name: "TermGuid" },
                  { name: "WssId", type: :integer, label: "Wss ID" }
                ] 
              }
            else
              {
                name: f["EntityPropertyName"],
                label: "#{f['Title']} (#{f['EntityPropertyName']})"
              }
            end
          end
      end
    }
  },

  actions: {
    add_row_in_sharepoint_list: {
      description: "Add <span class='provider'>row</span> in <span class='provider'>Microsoft Sharepoint</span> list",
      title_hint: "Add a row in Microsoft Sharepoint list",
      help: "Add a row item. select the specific list to add a row, then provide the data.",

      config_fields: [
        {
          name: "list_id", control_type: :select,
          pick_list: :list, label: "List", optional: false
        }
      ],

      input_fields: lambda do |object_definitions|
        object_definitions["list_create"]
      end,

      execute: lambda do |connection, input|
        list_id = input.delete("list_id")
        post("https://#{connection['subdomain']}.sharepoint.com/_api/web/" \
         "lists(guid%27#{list_id}%27)/items", input)
      end,

      output_fields: lambda do |object_definitions|
        [
          { name: "FileSystemObjectType", type: :integer,
            label: "File system object type" 
          }
        ].concat(object_definitions["list_output"])
      end,

      sample_output: lambda do |connection, input|
        get("https://#{connection['subdomain']}.sharepoint.com/_api/web/" \
         "lists(guid%27#{input['list_id']}%27)/items").
          params("$top": 1)["value"]&.first || {}
      end
    },

    upload_attachment: {
      description: "Upload <span class='provider'>attachment</span> in " \
       "<span class='provider'>Microsoft Sharepoint</span> list",
      title_hint: "Upload attachment in Microsoft Sharepoint list",
      help: "Upload attachment in Microsoft Sharepoint list",

      config_fields: [
        {
          name: "list_id", control_type: :select,
          pick_list: :list, label: "List", optional: false
        }
      ],

      input_fields: lambda do
        [
          { name: "item_id", optional: false, label: "Item ID" },
          { name: "file_name", optional: false, lable: "File name" },
          { name: "content", optional: false }
        ]
      end,

      execute: lambda do |connection, input|
        file_name = { "file_name" => input["file_name"] }.encode_www_form.
          gsub(/file_name\=/, "")
        form_digest = post("https://#{connection['subdomain']}.sharepoint.com/" \
         "_api/contextinfo")&.[]("FormDigestValue")
        post("https://#{connection['subdomain']}.sharepoint.com/_api/web/" \
         "lists(guid%27#{input['list_id']}%27)/items(#{input['item_id']})/" \
          "AttachmentFiles/add(FileName='#{file_name}')", input).
          headers("X-RequestDigest": "#{form_digest}").
          request_body(input["content"])
      end,

      output_fields: lambda do
        [
          { name: "FileName", label: "File name" },
          { name: "FileNameAsPath", label: "File name as path",
            type: :object, properties: [
              { name: "DecodedUrl", label: "Decoded url" }
            ] 
          },
          { name: "ServerRelativePath", label: "Server relative path",
            type: :object, properties: [
              { name: "DecodedUrl", label: "Decoded url" }
            ] 
          },
          { name: "ServerRelativeUrl", label: "Server relative url" }
        ]
      end,

      sample_output: lambda do |connection, input|
        file_name = { "file_name" => input["file_name"] }.encode_www_form.
          gsub(/file_name\=/, "")
        get("https://#{connection['subdomain']}.sharepoint.com/_api/web/" \
         "lists(guid%27#{input['list_id']}%27)/items(#{input['item_id']})/" \
          "AttachmentFiles('#{file_name}')") || {}
      end
    },

    download_attachment: {
      description: "Download <span class='provider'>attachment</span> in " \
       "<span class='provider'>Microsoft Sharepoint</span> list",
      title_hint: "Download attachment in Sharepoint list",
      help: "Download attachment in Sharepoint list",

      config_fields: [
        {
          name: "list_id", control_type: :select, 
          pick_list: :list, label: "List", optional: false
        }
      ],

      input_fields: lambda do
        [
          { name: "item_id", optional: false, label: "Item ID" },
          { name: "file_name", optional: false, lable: "File name" }
        ]
      end,

      execute: lambda do |connection, input|
        file_name = { "file_name" => input["file_name"] }.encode_www_form.
          gsub(/file_name\=/, "")
        { 
          "content": get("https://#{connection['subdomain']}.sharepoint.com/" \
           "_api/web/lists(guid%27#{input['list_id']}%27)/" \
            "items(#{input['item_id']})/AttachmentFiles('#{file_name}')/$value").
            response_format_raw
        }
      end,

      output_fields: lambda do
        [
          { name: "content" }
        ]
      end,

      sample_output: lambda do
        { "content": "test" }
      end
    }
  },

  triggers: {
    new_row_in_sharepoint_list: {
      description: "New <span class='provider'>row</span> in " \
       "<span class='provider'>Microsoft Sharepoint</span> list",
      title_hint: "Triggers when a new row is created in Microsoft" \
       " Sharepoint list",
      help: "Each new row will be processed as a single trigger event.",

      config_fields: [
        {
          name: "list_id", control_type: :select,
          pick_list: :list, label: "List", optional: false
        }
      ],

      input_fields: lambda do
        [
          {
            name: "since", type: :date_time,
            label: "From", optional: false,
            hint: "Fetch new row from specified time"
          }
        ]
      end,

      poll: lambda do |connection, input, link|
        if link.present?
          items = get(link)
        else
          items = get("https://#{connection['subdomain']}.sharepoint.com/" \
           "_api/web/lists(guid%27#{input['list_id']}%27)/items").
            params("$filter": "Created ge datetime%27#{input['since'].to_time.utc.iso8601}%27",
              "$orderby": "Created asc",
              "$top": "100",
              "$expand": "AttachmentFiles")
        end
        {
          events: items["value"],
          next_poll: items["@odata.nextLink"],
          can_poll_more: items["@odata.nextLink"].present?
        }
      end,

      dedup: lambda do |item|
        item["ID"]
      end,

      output_fields: lambda do |object_definitions|
        [
          { name: "FileSystemObjectType", type: :integer,
            label: "File system object type" },
          { name: "AuthorId", label: "Author ID", type: :integer },
          { name: "EditorId", label: "Editor ID", type: :integer },
          { name: "AttachmentFiles", label: "Attachment files",
            type: :object, properties: [
              { name: "FileName", label: "File name" },
              { name: "FileNameAsPath", label: "File name as path",
                type: :object, properties: [
                  { name: "DecodedUrl", label: "Decoded url" }
                ]
              },
              { name: "ServerRelativePath", label: "Server relative path",
                type: :object, properties: [
                  { name: "DecodedUrl", label: "Decoded url" }
                ]
              },
              { name: "ServerRelativeUrl", label: "Server relative url" }
              ]
            }
        ].concat(object_definitions["list_output"])
      end,

      sample_output: lambda do |connection, input|
        get("https://#{connection['subdomain']}.sharepoint.com/_api/web/" \
         "lists(guid%27#{input['list_id']}%27)/items").
          params("$top": 1)["value"]&.first || {}
      end
    },

    deleted_row_in_sharepoint_list: {
      description: "Deleted <span class='provider'>row</span> in " \
       "<span class='provider'>Microsoft Sharepoint</span> list",
      title_hint: "Triggers when a row is deleted in Sharepoint list",
      help: "Each row deleted will be processed as a single trigger event.",

      config_fields: [
        {
          name: "list_name", control_type: :select,
          pick_list: :name_list, label: "List", optional: false
        }
      ],

      input_fields: lambda do
        [
          {
            name: "since", type: :date_time,
            label: "From", optional: false,
            hint: "Fetch deleted row from specified time"
          }
        ]
      end,

      poll: lambda do |connection, input, link|
        if link.present?
          item = get(link)
        else
          item = get("https://#{connection['subdomain']}.sharepoint.com/" \
           "_api/web/RecycleBin").
            params("$filter": "((DirName eq 'Lists/#{input['list_name']}') and" \
             " (DeletedDate ge datetime'#{input['since'].to_time.utc.iso8601}'))",
              "$orderby": "DeletedDate asc",
              "$top": 100)
        end
        {
          events: item["value"],
          next_poll: item["@odata.nextLink"],
          can_poll_more: item["@odata.nextLink"].present?
        }
      end,

      dedup: lambda do |item|
        item["Id"]
      end,

      output_fields: lambda do
        [
          { name: "AuthorEmail", label: "Author email" },
          { name: "AuthorName", label: "Author name" },
          { name: "DeletedByEmail", label: "Deleted by email" },
          { name: "DeletedByName", label: "Deleted by name" },
          { name: "DeletedDate", label: "Deleted date", type: :date_time },
          { name: "DirName", label: "Directory name" },
          { name: "DirNamePath", label: "Directory name path",
            type: :object, properties: [
              { name: "DecodedUrl", label: "Decoded url" }
              ]
            },
          { name: "Id" },
          { name: "ItemState", type: :integer, label: "Item state" },
          { name: "ItemType", type: :integer, label: "Item type" },
          { name: "LeafName", label: "Leaf name" },
          { name: "LeafNamePath", label: "Leaf name path",
            type: :object, properties: [
              { name: "DecodedUrl", label: "Decoded url" }
              ]
            },
          { name: "Size" },
          { name: "Title" },
        ]
      end,

      sample_output: lambda do |connection, input|
        get("https://#{connection['subdomain']}.sharepoint.com/_api/web/" \
         "RecycleBin").
          params("$filter": "DirName eq 'Lists/#{input['list_name']}'",
            "$top": 1)["value"]&.first || {}
      end
    }
  },

  pick_lists: {
    list: lambda do |connection|
      get("https://#{connection['subdomain']}.sharepoint.com/_api/web/lists").
      params("$select": "Title,Id,BaseType")["value"].
      select { |f| f["BaseType"] == 0 }.map do |i|
        [i["Title"], i["Id"]]
      end
    end,

    name_list: lambda do |connection|
      get("https://#{connection['subdomain']}.sharepoint.com/_api/web/lists").
        params("$select": "Title,BaseType")["value"].
        select { |f| f["BaseType"] == 0 }.map do |i|
        [i["Title"], i["Title"]]
      end
    end
  }
}
