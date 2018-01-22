{
  title: "RightSignature",

  connection: {
    fields: [
      {
        name: "api_key",
        label: "Secure token",
        hint: "You may find the secure token <a href=" \
          "'https://rightsignature.com/oauth_clients' target='_blank'>here</a>",
        control_type: "password",
        optional: false
      }
    ],

    authorization: {
      type: "api_key",

      apply: lambda { |connection|
        headers(api_token: connection["api_key"])
      }
    },

    base_uri: lambda { |_connection|
      "https://rightsignature.com"
    }
  },

  object_definitions: {
    document: {
      fields: lambda {
        [
          { name: "guid", label: "Document ID" },
          { name: "created_at", type: "timestamp" },
          { name: "completed_at", type: "timestamp" },
          { name: "last_activity_at", type: "timestamp" },
          { name: "expires_on", type: "timestamp" },
          { name: "is_trashed" },
          { name: "size" },
          { name: "content_type" },
          { name: "original_filename" },
          { name: "signed_pdf_checksum" },
          { name: "subject" },
          { name: "message" },
          { name: "processing_state" },
          { name: "merge_state" },
          { name: "state" },
          { name: "callback_location" },
          { name: "tags" },
          {
            name: "recipients",
            type: "array",
            of: "object",
            properties: [
              { name: "name" },
              { name: "email" },
              { name: "must_sign" },
              { name: "document_role_id" },
              { name: "role_id" },
              { name: "state" },
              { name: "is_sender" },
              { name: "viewed_at" },
              { name: "completed_at" }
            ]
          },
          {
            name: "audit_trails",
            type: "array",
            of: "object",
            properties: [
              { name: "timestamp" },
              { name: "keyword" },
              { name: "message" }
            ]
          },
          {
            name: "pages",
            type: "array",
            of: "object",
            properties: [
              { name: "page_number" },
              { name: "original_template_guid" },
              { name: "original_template_filename" }
            ]
          },
          { name: "original_url" },
          { name: "pdf_url" },
          { name: "thumbnail_url" },
          { name: "large_url" },
          { name: "signed_pdf_url" }
        ]
      }
    }
  },

  test: lambda { |_connection|
    get("/api/documents.json")
  },

  actions: {
    get_document_details: {
      description: "Get <span class='provider'>document details</span>" \
        " by ID in <span class='provider'>RightSignature</span>",
      subtitle: "Get document details by ID",

      input_fields: lambda { |object_definitions|
        object_definitions["document"].only("guid").required("guid")
      },

      execute: lambda { |_connection, input|
        get("/api/documents/#{input['guid']}.json")["document"] || {}
      },

      output_fields: lambda { |object_definitions|
        object_definitions["document"]
      },

      sample_output: lambda { |_connection|
        get("/api/documents.json").
          payload(per_page: 1).
          dig("page", "documents", 0) || {}
      }
    },

    test: {
      execute: lambda {|_con, _input|
        page ||= 1
        page_size = 4
        {
          document: (get("/api/documents.json").
                       params(page: page,
                              per_page: page_size).
                       dig("page", "documents") || [])
          }
        },
#       output_fields: ->(object_definitions) { object_definitions['document'].only("guid", "created_at", "completed_at", "last_activity_at") },
      }
  },

  triggers: {
    new_signed_document: {
      subtitle: "New signed document",
      description: "New <span class='provider'>signed document</span>" \
        " in <span class='provider'>RightSignature</span>",
      type: "paging_desc",

      input_fields: lambda {
        [{
          name: "since",
          label: "From",
          type: "timestamp",
          sticky: true,
          hint: "Get documents signed since given date/time. " \
            "Leave empty to get the documents signed one hour ago"
        }]
      },

      poll: lambda { |_connection, input, page|
        page ||= 1
        page_size = 50
        documents = (get("/api/documents.json").
                       payload(page: page,
                               per_page: page_size,
                               state: "signed").
                       dig("page", "documents") || []).
                    select do |document|
                      document["completed_at"].to_time >=
                        (input["since"].presence || 1.hour.ago).to_time
                    end

        {
          events: documents,
          next_page: (documents.size >= page_size ? page + 1 : nil)
        }
      },

      document_id: ->(document) { document["guid"] },

      sort_by: ->(document) { document["completed_at"] },

      output_fields: ->(object_definitions) { object_definitions['document'] },

      sample_output: lambda { |_connection|
        get("/api/documents.json").dig("page", "documents", 0) || {}
      }
    }
  }
}
