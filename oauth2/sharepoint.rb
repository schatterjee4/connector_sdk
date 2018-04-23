{
  title: "Microsoft Sharepoint",

  secure_tunnel: true,

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
      },
      {
        name: "client_secret",
        optional: false,
        control_type: "password"
      },
      {
        name: "siteurl", label: "Site relative URL",
        hint: "site relative url copy url between <code>`*.sharepoint.com/`</code>"\
        " and <code>`/_api`</code> from the sharepoint Rest API url"
      }
    ],

    authorization: {
      type: "oauth2",
      authorization_url: lambda do |connection|
        "https://login.windows.net/common/oauth2/authorize?resource=
        https://#{connection['subdomain']}.sharepoint.com&response_type=code&
        prompt=login&client_id=#{connection['client_id']}"
      end,

      acquire: lambda do |connection, auth_code, redirect_url|
        post("https://login.windows.net/common/oauth2/token").
          payload(client_id: connection["client_id"],
                  client_secret: connection['client_secret'],
                  grant_type: :authorization_code,
                  code: auth_code,
                  redirect_uri: redirect_url).
          request_format_www_form_urlencoded
      end,

      refresh: lambda do |connection, refresh_token|
        post("https://login.windows.net/common/oauth2/token").
          payload(client_id: connection["client_id"],
                  client_secret: connection['client_secret'],
                  grant_type: :refresh_token,
                  refresh_token: refresh_token).
          request_format_www_form_urlencoded
      end,

      credentials: lambda do |_connection, access_token|
        headers("Authorization": "Bearer #{access_token}")
      end
    },
    base_uri: lambda do |connection|
      "https://#{connection['subdomain']}.sharepoint.com"
    end
  },

  test: lambda do |connection|
    get("/_api/web/title")
  end,

  object_definitions: {
    list_create: {
      fields: lambda do |connection, config|
        get(call("url", { siteurl: connection["siteurl"] }) +  \
        "lists(guid%27#{config['list_id']}%27)/Fields").
          params("$select": "odata.type,EntityPropertyName,Hidden,Required,
          ReadOnlyField,Title,TypeAsString,
          Choices,IsDependentLookup")["value"].
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
          elsif f["odata.type"] == "SP.FieldLookup" &&
              f["IsDependentLookup"] == false
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
        get(call("url", { siteurl: connection["siteurl"] }) + \
        "lists(guid%27#{config['list_id']}%27)/Fields").
          params("$select": "odata.type,Title,TypeAsString,
            EntityPropertyName,IsDependentLookup")["value"].
        map do |f|
          if f["odata.type"] == "SP.FieldNumber" ||
              f["TypeAsString"] == "Counter"
            {
              name: f["EntityPropertyName"],
              label: "#{f['Title']} (#{f['EntityPropertyName']})",
              type: :integer
            }
          elsif f["odata.type"] == "SP.Field"
            {
              name: f["EntityPropertyName"],
              label: "#{f['Title']} (#{f['EntityPropertyName']})",
              type: :boolean
            }
          elsif f["odata.type"] == "SP.FieldDateTime"
            {
              name: f["EntityPropertyName"],
              label: "#{f['Title']} (#{f['EntityPropertyName']})",
              type: :date_time
            }
          elsif f["odata.type"] == "SP.FieldUser"
            {
              name: "#{f['EntityPropertyName']}Id",
              label: "#{f['Title']} (#{f['EntityPropertyName']})",
              type: :integer
            }
          elsif f["odata.type"] == "SP.FieldLookup" &&
              f["IsDependentLookup"] == false
            {
              name: "#{f['EntityPropertyName']}Id",
              label: "#{f['Title']} (#{f['EntityPropertyName']})",
              type: :integer
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
    },
    list_item: {
      fields: lambda do |connection, config|
        get(call("url", { siteurl: connection["siteurl"] }) + \
        "lists(guid%27#{config['list_id']}%27)/Fields").
          params("$select": "odata.type,EntityPropertyName,Hidden,Required,
          ReadOnlyField,Title,TypeAsString,
          Choices,IsDependentLookup")["value"].
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
          elsif f["odata.type"] == "SP.FieldLookup" &&
              f["IsDependentLookup"] == false
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
    document: {
      fields: lambda do |connection, config|
        [
          { name: "odata_metadata",
            label: "File Metadata",
            control_type: "url" },
          { name: "odata_type",
            label: "Entity type full name" },
          { name: "odata_id",
            label: "ID" },
          { name: "__metadata",
            type: "object",
            properties: [
              { name: "type" },
              { name: "id" },
              { name: "uri" },
          ] },
          { name: "odata_editLink",
            label: "Edit link" },
          { name: "CheckInComment" },
          { name: "CheckOutType",
            type: "integer" },
          { name: "ContentTag" },
          { name: "CustomizedPageStatus",
            type: "integer" },
          { name: "ETag" },
          { name: "Exists",
            type: "boolean" },
          { name: "Length" },
          { name: "Level",
            type: "integer" },
          { name: "MajorVersion",
            type: "integer" },
          { name: "MinorVersion",
            type: "integer" },
          { name: "Name" },
          { name: "LinkingUri" },
          { name: "LinkingUrl" },
          { name: "ServerRelativeUrl" },
          { name: "TimeCreated",
            type: "date_time",
            control_type: "date_time" },
          { name: "TimeLastModified",
            type: "date_time",
            control_type: "date_time" },
          { name: "Title" },
          { name: "UIVersion",
            type: "integer" },
          { name: "UIVersionLabel" },
          { name: "UniqueId" }
        ]
      end
    },
    file_item_fields: {
      fields: lambda do
        [
          { name: "__metadata", type: "object", properties: [
              { name: "id" },
              { name: "uri" },
              { name: "etag" },
              { name: "type" }
            ]},
          { name: "FileSystemObjectType" },
          { name: "ID", type: "integer" },
          { name: "ContentTypeId" },
          { name: "Created", type: "date_time", control_type: "date_time" },
          { name: "AuthorId", type: "integer" },
          { name: "Modified", type: "date_time", control_type: "date_time" },
          { name: "EditorId", type: "integer" },
          { name: "OData__CopySource" },
          { name: "CheckoutUserId" },
          { name: "OData__UIVersionString" },
          { name: "GUID" },
          { name: "ComplianceAssetId" },
          { name: "Title" },

        ]
      end
    },
    file: {
      fields: lambda do
        [
          { name: "CheckInComment" },
          { name: "CheckOutType", type: "integer", control_type: "number" },
          { name: "ContentTag" },
          { name: "CustomizedPageStatus", type: "integer", control_type: "number" },
          { name: "ETag" },
          { name: "Exists", type: "boolean", control_type: "checkbox" },
          { name: "Length", type: "integer", control_type: "number" },
          { name: "Level", type: "integer", control_type: "integer" },
          { name: "MajorVersion", type: "integer", control_type: "integer" },
          { name: "MinorVersion", type: "integer", control_type: "integer" },
          { name: "Name" },
          { name: "ServerRelativeUrl" },
          { name: "TimeCreated", type: "date_time", control_type: "date_time" },
          { name: "TimeLastModified", type: "date_time", control_type: "date_time" },
          { name: "Title" },
          { name: "UiVersion" },
          { name: "UiVersionLabel" },
          { name: "UniqueId" }
        ]
      end
    }
  },

  methods: {
    digest: lambda do |var|
      post("/_api/contextinfo")&.[]("FormDigestValue")
    end,

    url: lambda do |input|
      if input[:siteurl].blank?
        "/_api/web/"
      else
        "/" + input[:siteurl] + "/_api/web/"
      end
    end
  },
  
  actions: {
    add_row_in_sharepoint_list: {
      description: "Add <span class='provider'>row</span> in " \
      "<span class='provider'>Microsoft Sharepoint</span> list",
      title_hint: "Add a row in Microsoft Sharepoint list",
      help: "Add a row item. select the specific list to add a row," \
      " then provide the data.",

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
        post( call("url", { siteurl: connection["siteurl"] }) +
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
        get(call("url", { siteurl: connection["siteurl"] }) +
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
        file_name = input["file_name"].gsub(/\s/, "%20").to_param
        form_digest = post("https://#{connection['subdomain']}.sharepoint.com/" \
          "_api/contextinfo")&.[]('FormDigestValue')
        post( call("url", { siteurl: connection["siteurl"] }) + 
          "lists(guid%27#{input['list_id']}%27)/items(#{input['item_id']})/" +
              "AttachmentFiles/add(FileName='" + file_name + "')", input).
        headers("X-RequestDigest": form_digest).request_body(input["content"])
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
        get(call("url", { siteurl: connection["siteurl"] }) +
             "lists(guid%27#{input['list_id']}%27)/items(#{input['item_id']})/" \
            "AttachmentFiles('" + input["file_name"].gsub(/\s/, "%20").
              to_param + "')") || {}
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
        {
          "content": get(call("url", { siteurl: connection["siteurl"] }) +
            "lists(guid%27#{input['list_id']}%27)/" \
            "items(#{input['item_id']})/AttachmentFiles('" +
            input["file_name"].gsub(/\s/, "%20").to_param + "')/$value").
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
    },

    upload_file_in_library: {
      description: "Upload <span class='provider'>file</span> in " \
      "<span class='provider'>Microsoft Sharepoint</span> library",
      title_hint: "Upload file in Microsoft Sharepoint library",
      help: "Upload file in Microsoft Sharepoint library",

      input_fields: lambda do
        [
          { name: "serverRelativeUrl", label: "Parent folder", control_type: 'tree',
            hint: "Select parent folder to create new file in",
            tree_options: { selectable_folder: true }, pick_list: :folders,
            optional: false,
            toggle_field: { name: "serverRelativeUrl",
              type: "string", control_type: "text",
              label: "Server relative URL", toggle_hint: "Use folder realtive Path",
              hint: "Relative URL of the folder to upload file in" },
            toggle_hint: "Select folder" },
          { name: "file_name", label: "File name", optional: false },
          { name: "content", optional: false }
        ]
      end,

      execute: lambda do |connection, input|
        post(call("url", { siteurl: connection["siteurl"] }) +
          "GetFolderByServerRelativeUrl('" + input['serverRelativeUrl'].
          gsub(/\s/, "%20") + "')/Files/Add(url='" +
          input["file_name"].gsub(/\s/, "%20").to_param + "',overwrite=true)").
          headers("X-RequestDigest": call("digest",{}),
                  "Accept": "application/json;odata=verbose",
                  "Content-Type": "application/json;odata=verbose").
          request_body(input["content"])["d"]
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["document"]
      end
    },

    update_file_in_library: {
      description: "Update <span class='provider'>file</span> in " \
      "<span class='provider'>Microsoft Sharepoint</span> library",
      title_hint: "Update file in Microsoft Sharepoint library",
      help: "Update file in Microsoft Sharepoint library",

      input_fields: lambda do
        [
          { name: "serverRelativeUrl",
            label: "Parent folder",
            control_type: "tree",
            hint: "Select parent folder to create new file in",
            tree_options: { selectable_folder: true },
            pick_list: :folders,
            optional: false,
            toggle_field: { 
              name: "serverRelativeUrl",
              type: "string", control_type: "text",
              label: "Server relative URL",
              toggle_hint: "Use folder realtive Path",
              hint: "Relative URL of the folder to upload file in" },
            toggle_hint: "Select folder"},
          { name: "file_name", label: "File name", optional: false },
          { name: "content", optional: false }
        ]
      end,

      execute: lambda do |connection, input|
        post(call("url", { siteurl: connection["siteurl"] }) +
          "GetFileByServerRelativeUrl('" + input['serverRelativeUrl'].
          gsub(/\s/, "%20") + "/" + input["file_name"].
          gsub(/\s/, "%20").to_param + "')/$value").
        headers("X-RequestDigest": call("digest",{}),
          "X-HTTP-Method": "PUT",
          "Accept": "application/json;odata=verbose",
          "Content-Type": "application/json;odata=verbose").
        request_body(input["content"])
      end,

      output_fields: lambda do
        [
          { name: "error", type: "object", properties: [
              { name: "code" },
              { name: "message", type: "object", properties: [
                  { name: "lang" },
                  { name: "value" }
              ] }
          ]}
        ]
      end
    },

    get_file_list_item_fields: {
      description: "Get all item<span class='provider'>fields</span> in " \
      "<span class='provider'>Microsoft Sharepoint</span> library",
      title_hint: "Get all item fields in Microsoft Sharepoint library",
      help: "Get all item fields in Microsoft Sharepoint library",

      input_fields: lambda do
        [
          { name: "serverRelativeUrl",
            label: "Parent folder",
            control_type: "tree",
            hint: "Select parent folder to create new file in",
            tree_options: { selectable_folder: true },
            pick_list: :folders,
            optional: false,
            toggle_field: { name: "serverRelativeUrl",
              type: "string", control_type: "text",
              label: "Server relative URL",
              toggle_hint: "Use folder realtive Path",
              hint: "Relative URL of the folder to upload file in" },
            toggle_hint: "Select folder" },
          { name: "file_name", label: "File name", optional: false }
        ]
      end,

      execute: lambda do |connection, input|
        document = get(call("url", { siteurl: connection["siteurl"] }) +
          "GetFolderByServerRelativeUrl('" +
          input['serverRelativeUrl'].gsub(/\s/, "%20") +
          "')/Files('"+ input['file_name'].gsub(/\s/, "%20").to_param +
          "')/ListItemAllFields").
        headers("Content-Type": "application/json;odata=verbose").
        map do |key, value|
          { "#{key}".gsub(".", "_") => "#{value}" }
        end.inject(:merge)
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["document"]
      end
    },

    download_file_from_library: {
      description: "Download <span class='provider'>file</span> from " \
      "<span class='provider'>Microsoft Sharepoint</span> library",
      title_hint: "Download file from Microsoft Sharepoint library",
      help: "Download file from Microsoft Sharepoint library",

      input_fields: lambda do
        [
          { name: "serverRelativeUrl", label: "Parent folder",
            control_type: "tree",
            hint: "Select parent folder to create new file in",
            tree_options: { selectable_folder: true },
            pick_list: :folders,
            optional: false,
            toggle_field: { name: "serverRelativeUrl",
              type: "string", control_type: "text",
              label: "Server relative URL",
              toggle_hint: "Use folder realtive Path",
              hint: "Relative URL of the folder to upload file in" },
            toggle_hint: "Select folder" },
          { name: "file_name", label: "File name", optional: false }
        ]
      end,

      execute: lambda do |connection, input|
        {
          "content":get(call("url", { siteurl: connection["siteurl"] }) +
            "GetFolderByServerRelativeUrl('" +
            input['serverRelativeUrl'].gsub(/\s/, "%20") + "')/" +
            "Files('" + input['file_name'].gsub(/\s/, "%20").to_param +
            "')/$value").response_format_raw
        }

      end,

      output_fields: lambda do |object_definitions|
        [
          { name: "content" }
        ]
      end,
      
      sample_output: lambda do
        { "content": "test" }
      end
    },

    update_list_item_metadata: {
      description: "Update List <span class='provider'>item metadata</span> in " \
      "<span class='provider'> in Microsoft Sharepoint</span> library",
      title_hint: "Update List item metadata in Microsoft Sharepoint library",
      help: "Update List item metadata in Microsoft Sharepoint library",

      config_fields: [
        {
            name: "list_id",
            control_type: :select,
            pick_list: :list,
            label: "List",
            optional: false,
            toggle_field: { name: "list_id",
              type: "string", control_type: "text",
              label: "List",
              toggle_hint: "Use the list id",
              hint: "List id of the file located" },
            toggle_hint: "Select list"
          },
          {
            name: "item_id"
          }
      ],

      input_fields: lambda do |object_defintions|
        [
          {
            name: "__metadata",
            label: "Item Type",
            type: "object",
            optional: false,
            properties: [
              { name: "type" }
            ]
          },
          {
            name: "Title"
          }
        ]
      end,

      execute: lambda do |connection, input|
        document = post(call("url", { siteurl: connection["siteurl"] }) +
          "lists(guid%27" + input.delete('list_id').gsub(/\s/, "%20") +
          "%27)/items(" + input.delete("item_id") + ")" ).
          headers("X-RequestDigest": call("digest",{}),
            "X-HTTP-Method": "MERGE",
            "IF-MATCH": "*",
            "Accept": "application/json;odata=verbose",
            "Content-Type": "application/json;odata=verbose").
          payload(input)
      end,

      output_fields: lambda do |object_definitions|
        [
          { name: "error", type: "object", properties: [
              { name: "code" },
              { name: "message", type: "object", properties: [
                  { name: "lang" },
                  { name: "value" }
              ] }
          ]}
        ]
      end
    },
    search_users: {
      description: "Search <span class='provider'>Users</span> in " \
      "<span class='provider'> in Microsoft Sharepoint</span>",
      title_hint: "Search users in Microsoft Sharepoint",
      help: "Search users in Microsoft Sharepoint",

      input_fields: lambda do
        [
          {  name: "usermail",
             label: "User email's",
             type: :text,
             control_type: :text,
             optional: false,
             hint: "Enter user email's separated with comma" }
        ]
      end,

      execute: lambda do |connection, input|
        filter_string = ""
        emails = input["usermail"].split(",")
        filter_mails = []
        emails.map do |email|
          filter_mails << (filter_string + "Email eq '" +
           email + "'") unless email.blank?
        end
        filter_string = filter_mails.smart_join(" or ")
        {
          users: get(call("url", { siteurl: connection["siteurl"] }) +
           "/siteusers?$filter=" +
            filter_string ).
          headers("Content-Type": "application/json;odata=verbose")["value"]
        }
      end,

      output_fields: lambda do
        [
          {
            name: "users", type: "array", of: "object",
              properties: [
               { name: "Id" },
               { name: "Title" },
               { name: "Email" },
               { name: "UserId", type: "object", properties: [
                   { name: "NameId" },
                   {  name: "NameIdIssuer" }
                   ]}
              ]
          }
        ]
      end
    },

    search_products: {
      description: "Search <span class='provider'>Products</span> in " \
      "<span class='provider'> in Microsoft Sharepoint</span>",
      title_hint: "Search products in Microsoft Sharepoint",
      help: "Search products in Microsoft Sharepoint",

      input_fields: lambda do
        [
          {  name: "product_name",
             label: "Product Name's",
             type: :text,
             control_type: :text,
             optional: false,
             hint: "Enter product names with comma separated values " \
             "e.g. `Product_1,Product2`" }
        ]
      end,

      execute: lambda do |connection, input|
        filter_string = ""
        products = input["product_name"].split(",")
        filter_products = []
        products.map do |product|
          filter_products << (filter_string + "Product eq '" +
           product + "'") unless product.blank?
        end
        filter_string = filter_products.smart_join(" or ")
        {
          products: get(call("url", { siteurl: connection["siteurl"] }) +
            "/lists/getbytitle('Products')/items?$filter=" + filter_string).
          headers("Content-Type": "application/json;odata=verbose")["value"]
        }
      end,

      output_fields: lambda do
        [ { name: "products", type: "array", of: "object",
            properties: [
              { name: "Id", type: "integer" },
              { name: "Title" },
              { name: "Product" },
              { name: "ContentTypeId" },
              { name: "GUID" },
              { name: "Created", type: "date_time"},
          { name: "Modified", type: "date_time"} ] }
          ]
      end
    },

    search_countries: {
      description: "Search <span class='provider'>Countries</span> in " \
      "<span class='provider'> in Microsoft Sharepoint</span>",
      title_hint: "Search countries in Microsoft Sharepoint",
      help: "Search countries in Microsoft Sharepoint",

      input_fields: lambda do
        [
          {  name: "country_name",
             label: "Country Name's",
             type: :text,
             control_type: :text,
             optional: false,
             hint: "Enter Country names with comma separated values"\
             " e.g. `Vietnam,Japan`" }
        ]
      end,

      execute: lambda do |connection, input|
        filter_string = ""
        countries = input["country_name"].split(",")
        filter_countries = []
        countries.map do |country|
          filter_countries << (filter_string + "Country eq '" +
           country + "'") unless country.blank?
        end
        filter_string = filter_countries.smart_join(" or ")
        {
          countries: get(call("url", { siteurl: connection["siteurl"] }) + 
            "/lists/getbytitle('Countries')/items?$filter=" + filter_string ).
          headers("Content-Type": "application/json;odata=verbose")["value"]
        }
      end,

      output_fields: lambda do
        [ { name: "countries", type: "array", of: "object",
            properties: [
              { name: "Id", type: "integer" },
              { name: "Title" },
              { name: "Region" },
              { name: "Subregion" },
              { name: "Country" },
              { name: "Created", type: "date_time"},
          { name: "Modified", type: "date_time"} ] }
          ]
      end
    },

    search_subregions: {
      description: "Search <span class='provider'>SubRegion's</span> in " \
      "<span class='provider'> in Microsoft Sharepoint</span>",
      title_hint: "Search subregion's in Microsoft Sharepoint",
      help: "Search subregion's in Microsoft Sharepoint",

      input_fields: lambda do
        [
          {  name: "subregion_name",
             label: "Subregion name's",
             type: :text,
             control_type: :text,
             optional: false,
             hint: "Enter Subregion names with comma separated values" \
             " e.g. `ASUG,ASAP`" }
        ]
      end,

      execute: lambda do |connection, input|
        filter_string = ""
        subregions = input["subregion_name"].split(",")
        filter_subregions = []
        subregions.map do |subr|
          filter_subregions << (filter_string + "Subregion eq '" +
           subr + "'") unless subr.blank?
        end
        filter_string = filter_subregions.smart_join(" or ")
        {
          subregions: get(call("url", { siteurl: connection["siteurl"] }) +
           "/lists/getbytitle('Subregions')/items?$filter=" + filter_string ).
          headers("Content-Type": "application/json;odata=verbose")["value"]
        }
      end,

      output_fields: lambda do
        [ { name: "subregions", type: "array", of: "object",
            properties: [
              { name: "Id", type: "integer" },
              { name: "Title" },
              { name: "Region" },
              { name: "Subregion" },
              { name: "Created", type: "date_time"},
          { name: "Modified", type: "date_time"} ] }
          ]
      end
    },

    search_regions: {
      description: "Search <span class='provider'>Region's</span> in " \
      "<span class='provider'> in Microsoft Sharepoint</span>",
      title_hint: "Search region's in Microsoft Sharepoint",
      help: "Search region's in Microsoft Sharepoint",

      input_fields: lambda do
        [
          {  name: "region_name",
             label: "Region name's",
             type: :text,
             control_type: :text,
             optional: false,
             hint: "Enter Region names with comma separated values" \
             " e.g. `AP,SMEA`" }
        ]
      end,

      execute: lambda do |connection, input|
        filter_string = ""
        regions = input["region_name"].split(",")
        filter_regions = []
        regions.map do |reg|
          filter_regions << (filter_string + "Region eq '" +
           reg + "'") unless reg.blank?
        end
        filter_string = filter_regions.smart_join(" or ")
        {
          regions: get(call("url", { siteurl: connection["siteurl"] }) + 
            "/lists/getbytitle('Regions')/items?$filter=" + filter_string ).
          headers("Content-Type": "application/json;odata=verbose")["value"]
        }
      end,

      output_fields: lambda do
        [ { name: "regions", type: "array", of: "object",
            properties: [
              { name: "Id", type: "integer" },
              { name: "Title" },
              { name: "Region" },
              { name: "Created", type: "date_time"},
          { name: "Modified", type: "date_time"}] }

          ]
      end
    },

    search_folder_by_name: {
      description: "Search <span class='provider'>Folder</span> " \
      "<span class='provider'> by name in Microsoft Sharepoint</span> library",
      title_hint: "Searches folder by name in Selected folder.",
      help: "Search folder by name selected folder in " \
      "Microsoft Sharepoint library",

      input_fields: lambda do
        [
          { name: "serverRelativeUrl", label: "Parent folder",
            control_type: "tree",
            hint: "Select parent folder to create new file in",
            tree_options: { selectable_folder: true },
            pick_list: :folders,
            optional: false,
            toggle_field: { name: "serverRelativeUrl",
              type: "string",
              control_type: "text",
              label: "Server relative URL",
              toggle_hint: "Use folder realtive Path",
              hint: "Relative URL of the folder to upload file in" },
            toggle_hint: "Select folder" },
          {  name: "folder_name",
             label: "Folder name",
             type: :text,
             control_type: :text,
             optional: false,
             hint: "Searches for folder with eaxact match" }
        ]
      end,

      execute: lambda do |connection, input|
        filter_string = "Name eq '" + input["folder_name"].
          gsub(/\s/, "%20") + "'"
        folders = get(call("url", { siteurl: connection["siteurl"] }) +
          "GetFolderByServerRelativeUrl('" +
          input['serverRelativeUrl'].gsub(/\s/, "%20") + "')/" +
          "Folders?$expand=Folders,Folders/Folders&$filter=" + filter_string).
          headers("Content-Type": "application/json;odata=verbose")["value"]
        {
          folders: folders
        }
      end,

      output_fields: lambda do
        [ { name: "folders", type: "array", of: "object",
            properties: [
              { name: "ItemCount", type: "integer" },
              { name: "Name" },
              { name: "Title" },
              { name: "ServerRelativeUrl" },
              { name: "TimeCreated", type: "date_time"},
              { name: "TimeLastModified", type: "date_time"},
              { name: "UniqueId" },
              { name: "ProgID" },
              { name: "Exists", type: "boolean" },
              { name: "ETag" }
            ]}
          ]
      end
    },

    create_folder: {
      description: "Create <span class='provider'>Folder</span> " \
      "<span class='provider'> by name in Microsoft Sharepoint</span> library",
      title_hint: "Create Folder in Microsoft Sharepoint library",
      help: "Create Folder in Microsoft Sharepoint library",

      input_fields: lambda do
        [
          { name: "serverRelativeUrl", label: "Parent folder",
            control_type: "tree",
            hint: "Select parent folder to create folder",
            tree_options: { selectable_folder: true },
            pick_list: :folders,
            optional: false,
            toggle_field: { name: "serverRelativeUrl",
              type: "string",
              control_type: "text",
              label: "Server relative URL",
              toggle_hint: "Use folder realtive Path",
              hint: "Relative URL of the folder to create folder" },
            toggle_hint: "Select folder" },
          {  name: "folder_name",
             label: "Folder name",
             type: :text,
             control_type: :text,
             optional: false,
             hint: "Name of folder" }
        ]
      end,

      execute: lambda do |connection, input|
        filter_string = "Name eq '" + input["folder_name"].
          gsub(/\s/, "%20") + "'"
        folders = post(call("url", { siteurl: connection["siteurl"] }) +
          "GetFolderByServerRelativeUrl('" +
          input['serverRelativeUrl'].gsub(/\s/, "%20") + "')/" +
          "Folders").
          payload("__metadata": { "type": "SP.Folder" },
            ServerRelativeUrl: input["folder_name"].gsub(/\s/, "%20")).
            headers("Accept": "application/json;odata=verbose",
              "Content-Type": "application/json;odata=verbose")["d"]
      end,

      output_fields: lambda do
        [
          { name: "ItemCount", type: "integer" },
          { name: "Name" },
          { name: "Title" },
          { name: "ServerRelativeUrl" },
          { name: "TimeCreated", type: "date_time"},
          { name: "TimeLastModified", type: "date_time"},
          { name: "UniqueId" },
          { name: "ProgID" },
          { name: "Exists", type: "boolean" },
          { name: "ETag" }
        ]
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
        response = if link.present?
          get(link)
        else
          get( call("url", { siteurl: connection["siteurl"] }) +
            "lists(guid%27#{input['list_id']}%27)/items?" +
            "$filter=Created ge datetime%27" \
            "#{input['since'].to_time.utc.iso8601}%27" \
            "&$orderby=Created asc&$top=100&$expand=AttachmentFiles")
        end
        {
          events: response["value"],
          next_poll: response["@odata.nextLink"],
          can_poll_more: response["@odata.nextLink"].present?
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
            type: :object,
            properties: [
              { name: "FileName", label: "File name" },
              { name: "FileNameAsPath", label: "File name as path",
                type: :object,
                properties: [
                  {
                    name: "DecodedUrl", label: "Decoded url"
                  }
              ] },
              { name: "ServerRelativePath", label: "Server relative path",
                type: :object,
                properties: [
                  {
                    name: "DecodedUrl", label: "Decoded url"
                  }
              ] },
              { name: "ServerRelativeUrl", label: "Server relative url" }
          ] }
        ].concat(object_definitions["list_output"])
      end,

      sample_output: lambda do |connection, input|
        get(call("url", { siteurl: connection["siteurl"] }) +
        "lists(guid%27#{input['list_id']}%27)/items").
          params("$top": 1)["value"]&.first || {}
      end
    },

    new_updated_file_in_sharepoint_library: {
      description: "New or Updated <span class='provider'>file</span> in " \
      "<span class='provider'>Microsoft Sharepoint</span> folder",
      title_hint: "Triggers when a file created or updated in" \
      " Sharepoint Folder",
      help: "Each file created or updated processed as a single event.",

      input_fields: lambda do
        [
          { name: "serverRelativeUrl",
            label: "Folder",
            control_type: "tree",
            hint: "Select folder to process files",
            pick_list: :folders,
            optional: false,
            tree_options: { selectable_folder: true },
            toggle_field: { name: "serverRelativeUrl",
              type: "string",
              control_type: "text",
              label: "Server relative URL",
              toggle_hint: "Use folder realtive Path",
              hint: "Relative URL of the folder" },
            toggle_hint: "Select folder" },
          { name: "since", type: :date_time,
            label: "From", optional: false,
            hint: "Fetch files from specified time" }
        ]
      end,

      poll: lambda do |connection, input, last_updated_since|
        last_updated_since ||= (input["since"].presence || 1.hour.ago).
          to_time.utc.iso8601
        files = get(call("url", { siteurl: connection["siteurl"] }) +
          "GetFolderByServerRelativeUrl('" +
          input['serverRelativeUrl'].gsub(/\s/, "%20") + "')/Files").
          params("$filter": "TimeLastModified gt " + "datetime'" +
            last_updated_since + "'",
            "$orderby": "TimeLastModified ").
          headers("Accept": "application/json;odata=verbose")["d"]["results"]
        #need to fix continuous poll
        next_updated_since = files.blank? ? now.to_time.utc.
          iso8601 : files.last['TimeLastModified']
        {
          events: files,
          next_poll: next_updated_since,
          can_poll_more: files.blank?
        }
      end,
      dedup: lambda do |file|
        file["UniqueId"]
      end,

      output_fields: lambda do |object_defintions|
        object_defintions["file"]
      end
    }

  },

  pick_lists: {
    list: lambda do |connection|
      get(call("url", { siteurl: connection["siteurl"] }) + "lists").
        params("$select": "Title,Id,BaseType")["value"].
        select { |f| f["BaseType"] == 0 }.
        map do |i|
          [i["Title"], i["Id"]]
        end
    end,

    name_list: lambda do |connection|
      get(call("url", { siteurl: connection["siteurl"] }) + "lists").
        params("$select": "Title,BaseType")["value"].
        select { |f| f["BaseType"] == 0 }.
      map do |i|
        [i["Title"], i["Title"]]
      end
    end,

    folders_list: lambda do |connection|
      get(call("url", { siteurl: connection["siteurl"] }) + "Folders").
        params("$select": "Id,ServerRelativeUrl,Name")["value"].map do |field|
          [field["Name"], field["ServerRelativeUrl"]]
        end
    end,

    folders: lambda do |connection, **args|
      if parentId = args&.[](:__parent_id).presence
        get(call("url", { siteurl: connection["siteurl"] }) +  \
        "GetFolderByServerRelativePath(decodedurl='#{parentId}')/Folders").
          params("$select": "Id,ServerRelativeUrl,Name,Title")["value"].
        map do |field|
          [field["Name"].labelize, field["ServerRelativeUrl"].
           gsub(/\s/, "%20"), field["ServerRelativeUrl"], true]
        end
      else
      # "GetFolderByServerRelativeUrl('/Shared%20Documents')/Folders") - change if necessary
       site_url = connection["siteurl"].blank? ? "" : "/" + connection["siteurl"]
        get(call("url", { siteurl: connection["siteurl"] }) +
        "GetFolderByServerRelativeUrl('" + site_url + "/Shared%20Documents')/Folders").
          params("$select": "Id,ServerRelativeUrl,Name,Title")["value"].
        map do |field|
          [field["Name"].labelize, field["ServerRelativeUrl"].
           gsub(/\s/, "%20"), field["ServerRelativeUrl"], true]
        end
      end
    end
  }
}
