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
      },
      {
        name: "siterelativeurl", label: "Site relative URL",
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
    },
    base_uri: lambda do |connection|
      if connection["siterelativeurl"].blank?
        "https://#{connection['subdomain']}.sharepoint.com"
      else
        "https://#{connection['subdomain']}.sharepoint.com/" +
        connection["siterelativeurl"]
      end
    end
  },

  test: lambda do |connection|
    get("/_api/web/title")
  end,

  object_definitions: {
    list_create: {
      fields: lambda do |connection, config|
        get("/_api/web/" \
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
        get("/_api/web/" \
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
        get("/_api/web/" \
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
          { name: "ListId" },
          { name: "ETag" },
          { name: "Exists",
            type: "boolean" },
          { name: "IrmEnabled",
            type: "boolean" },
          { name: "Length" },
          { name: "Level",
            type: "integer" },
          { name: "LinkingUri" },
          { name: "LinkingUrl" },
          { name: "MajorVersion",
            type: "integer" },
          { name: "MinorVersion",
            type: "integer" },
          { name: "Name" },
          { name: "PageRenderType",
            type: "integer" },
          { name: "ServerRelativePath" },
          { name: "ServerRelativeUrl" },
          { name: "SiteId" },
          { name: "TimeCreated",
            type: "date_time",
            control_type: "date_time" },
          { name: "TimeLastModified",
            type: "date_time",
            control_type: "date_time" },
          { name: "Title" },
          { name: "UIVersion",
            type: "integer" },
          { name: "UIVersionLabel",
            type: "integer" },
          { name: "UniqueId" },
          { name: "WebId" },
          { name: "ActivityCapabilities",
            type: "object",
            properties: [
              { name: "enabled", type: "boolean" },
              { name: "revisionSetEnabled", type: "boolean" }
          ] },
          { name: "Author", type: "object", properties: [
              { name: "__deferred", type: "object",
                properties: [
                  {  name: "uri" }
              ] }
          ] },
          { name: "CheckedOutByUser", type: "object", properties: [
              { name: "__deferred", type: "object", properties: [
                  {  name: "uri" }
              ] }
          ] },
          { name: "EffectiveInformationRightsManagementSettings", type: "object", properties: [
              { name: "__deferred", type: "object", properties: [
                  {  name: "uri" }
              ] }
          ] },
          { name: "InformationRightsManagementSettings", type: "object", properties: [
              { name: "__deferred", type: "object", properties: [
                  {  name: "uri" }
              ] }
          ] },
          { name: "ListItemAllFields", type: "object", properties: [
              { name: "__deferred", type: "object", properties: [
                  {  name: "uri" }
              ] }
          ] },
          { name: "LockedByUser", type: "object", properties: [
              { name: "__deferred", type: "object", properties: [
                  {  name: "uri" }
              ] }
          ] },
          { name: "ModifiedBy", type: "object", properties: [
              { name: "__deferred", type: "object", properties: [
                  {  name: "uri" }
              ] }
          ] },
          { name: "Properties", type: "object", properties: [
              { name: "__deferred", type: "object", properties: [
                  {  name: "uri" }
              ] }
          ] },
          { name: "VersionEvents", type: "object", properties: [
              { name: "__deferred", type: "object", properties: [
                  {  name: "uri" }
              ] }
          ] },
          { name: "Versions", type: "object", properties: [
              { name: "__deferred", type: "object", properties: [
                  {  name: "uri" }
              ] }
          ] }

        ]
      end
    }
  },

  methods: {
    digest: lambda do |variable|
      post("/_api/contextinfo")&.[]("FormDigestValue")
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
        post("/_api/web/" \
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
        get("/_api/web/" \
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
        post("/_api/web/" \
          "lists(guid%27#{input['list_id']}%27)/items(#{input['item_id']})/" \
          "AttachmentFiles/add(FileName='" + input["file_name"].gsub(/\s/, "%20").
          to_param  + "')", input).
          headers("X-RequestDigest": call("digest",{})).
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
        get("/_api/web/" \
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
          "content": get("/_api/web/lists(guid%27#{input['list_id']}%27)/" \
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
            toggle_hint: "Select folder"},
          { name: "file_name", label: "File name", optional: false },
          { name: "content", optional: false }
        ]
      end,

      execute: lambda do |connection, input|
        document = post("/_api/web/" \
          "GetFolderByServerRelativeUrl('" + input['serverRelativeUrl'].
          gsub(/\s/, "%20") + "')/Files/Add(url='" +
          input["file_name"].gsub(/\s/, "%20").to_param + "',overwrite=true)").
        headers("X-RequestDigest": call("digest",{}),
                "Content-Type": "application/json;odata=verbose").
        request_body(input["content"])
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
          { name: "serverRelativeUrl", label: "Parent folder",
            control_type: 'tree',
            hint: "Select parent folder to create new file in",
            tree_options: { selectable_folder: true },
            pick_list: :folders,
            optional: false,
            toggle_field: { name: "serverRelativeUrl",
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
        document = post("/_api/web/GetFileByServerRelativeUrl('" +
          input['serverRelativeUrl'].
          gsub(/\s/, "%20") + "/" + input["file_name"].
          gsub(/\s/, "%20").to_param + "')/$value").
        headers("X-RequestDigest": call("digest",{}),
                "X-HTTP-Method": "PUT",
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
            control_type: 'tree',
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
        document = get("/_api/web/GetFolderByServerRelativeUrl('" +
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
      description: "Get <span class='provider'>file</span> in " \
      "<span class='provider'>Microsoft Sharepoint</span> library",
      title_hint: "Get file in Microsoft Sharepoint library",
      help: "Get file in Microsoft Sharepoint library",

      input_fields: lambda do
        [
          { name: "serverRelativeUrl", label: "Parent folder",
            control_type: 'tree',
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
          "content": get("/_api/web/GetFolderByServerRelativeUrl('" +
            input['serverRelativeUrl'].gsub(/\s/, "%20") + "')/" +
            "Files('" + input['file_name'].gsub(/\s/, "%20").to_param +
            "')/$value").response_format_raw
        }

      end,

      output_fields: lambda do |object_definitions|
        [
          { name: "content" }
        ]
      end
    },

    update_list_item_metadata: {
      description: "Update List <span class='provider'>item</span> in " \
      "<span class='provider'> metadata in Microsoft Sharepoint</span> library",
      title_hint: "Update List item metadata in Microsoft Sharepoint library",
      help: "Update List item metadata in Microsoft Sharepoint library",

      input_fields: lambda do |object_defintions|
        [
          {
            name: "list_name",
            control_type: :select,
            pick_list: :name_list,
            label: "List",
            optional: false
          },
          {
            name: "item_id", optional: false
          },
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
        document = post("/_api/web/lists/GetByTitle('" + input.delete('list_name').
          gsub(/\s/, "%20") + "')/" + "items(" +
          input.delete("item_id") + ")" ).
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
          items = get("/_api/web/lists(guid%27#{input['list_id']}%27)/items").
            params("$filter": "Created ge " \
                    "datetime" \
                    "%27#{input['since'].to_time.utc.iso8601}%27",
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

      sample_output: lambda do |_connection, input|
        get("/_api/web/" \
        "lists(guid%27#{input['list_id']}%27)/items").
          params("$top": 1)["value"]&.first || {}
      end
    },

    deleted_row_in_sharepoint_list: {
      description: "Deleted <span class='provider'>row</span> in " \
      "<span class='provider'>Microsoft Sharepoint</span> list",
      title_hint: "Triggers when a row is deleted in Sharepoint list",
      help: "Each row deleted will be processed as a single trigger event.",

      input_fields: lambda do
        [
          { name: "list_name", control_type: :select,
            pick_list: :name_list, label: "List", optional: false },
          { name: "since", type: :date_time,
            label: "From", optional: false,
            hint: "Fetch deleted row from specified time" }
        ]
      end,

      poll: lambda do |connection, input, link|
        if link.present?
          item = get(link)
        else
          item = get("/_api/web/RecycleBin").
            params("$filter": "((DirName eq 'Lists/#{input['list_name']}') " \
                   "and (DeletedDate ge " \
                   "datetime'#{input['since'].to_time.utc.iso8601}'))",
                   "$orderby": "DeletedDate asc",
                   "$top": 100)
          next_link = item["@odata.nextLink"]
        end

        {
          events: item["value"],
          next_poll: next_link,
          can_poll_more: next_link.present?
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
            type: :object, properties: [{ name: "DecodedUrl",
                                          label: "Decoded url" }] },
          { name: "Id" },
          { name: "ItemState", type: :integer, label: "Item state" },
          { name: "ItemType", type: :integer, label: "Item type" },
          { name: "LeafName", label: "Leaf name" },
          { name: "LeafNamePath", label: "Leaf name path",
            type: :object, properties: [{ name: "DecodedUrl",
                                          label: "Decoded url" }] },
          { name: "Size" },
          { name: "Title" },
        ]
      end,

      sample_output: lambda do |_connection, input|
        get("/_api/web/RecycleBin").
          params("$filter": "DirName eq 'Lists/#{input['list_name']}'",
                 "$top": 1)["value"]&.first || {}
      end
    }
  },

  pick_lists: {
    list: lambda do
      get("/_api/web/lists").
        params("$select": "Title,Id,BaseType")["value"].
      select { |f| f["BaseType"] == 0 }.
        map do |i|
          [i["Title"], i["Id"]]
        end
    end,

    name_list: lambda do
      get("/_api/web/lists").
        params("$select": "Title,BaseType")["value"].
      select { |f| f["BaseType"] == 0 }.
        map do |i|
          [i["Title"], i["Title"]]
        end
    end,

    folders_list: lambda do
      get("/_api/web/Folders").
      params("$select": "Id,ServerRelativeUrl,Name")["value"].map do |field|
        [field["Name"], field["ServerRelativeUrl"]]
      end
    end,

    folders: lambda do |_connection, **args|
      if parentId = args&.[](:__parent_id).presence
        get("/_api/web/" \
          "GetFolderByServerRelativePath(decodedurl='#{parentId}')/Folders").
        params("$select": "Id,ServerRelativeUrl,Name,Title")["value"].
        map do |field|
          [field["Name"].labelize, field["ServerRelativeUrl"].
            gsub(/\s/, "%20"), field["ServerRelativeUrl"], true]
        end
      else
        # "GetFolderByServerRelativeUrl('/Shared%20Documents')/Folders").
        get("/_api/web/GetFolderByServerRelativeUrl('/Shared%20Documents')/" \
          "Folders").
          params("$select": "Id,ServerRelativeUrl,Name,Title")["value"].
          map do |field|
            [field["Name"].labelize, field["ServerRelativeUrl"].
              gsub(/\s/, "%20"), field["ServerRelativeUrl"], true]
          end
      end
    end
  }
}
