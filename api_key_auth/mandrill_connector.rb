{
  title: "Mandrill",

  connection: {
    fields: [
      {
        name: "api_key",
        label: "API Key",
        control_type: "password",
        hint: "You may find it " \
          "<a href='https://mandrillapp.com//settings'>here</a>",
        optional: false
      }
    ],

    authorization: {
      type: "api_key",

      acquire: lambda { |_connection|
        {}
      },

      refresh_on: [/"name"\:\s*"Invalid_Key"/],

      detect_on: [
        /"status"\:\s*"error"/,
        /"reject_reason"\:"*"/,
        /"status"\:\s*"invalid"/
      ],

      apply: lambda { |connection|
        payload(key: connection["api_key"])
      }
    }
  },

  test: lambda { |_connection|
    post("https://mandrillapp.com/api/1.0/users/ping.json")
  },

  object_definitions: {
    send_template_input: {
      fields: lambda { |_connection, config_fields|
        template_variables = if config_fields.blank?
                               []
                             else
                               post("https://mandrillapp.com/api/1.0/" \
                                 "templates/info.json")
                                 .payload(name: config_fields["template"])
                                 .dig("code")
                                 .scan(/mc:edit=\"([^\"]*)\"/)
                                 .map do |var|
                                   {
                                     name: var.first,
                                     hint: "Include html tags for better" \
                                     " formatting"
                                   }
                                 end
                             end

        [
          {
            name: "from_email",
            hint: "The default sender address for the template, if" \
              " provided - draft version",
            optional: false
          },
          {
            name: "from_name",
            hint: "The default sender from name for the template, if" \
              " provided - draft version"
          },
          {
            name: "to",
            hint: "List of email recipients, one per line.",
            optional: false
          },
          {
            name: "important",
            hint: "Whether or not this message is important, and should be" \
              " delivered ahead of non-important messages.",
            control_type: "checkbox",
            type: "boolean"
          },
          {
            name: "track_opens",
            hint: "Whether or not to turn on open tracking for the message",
            control_type: "checkbox",
            type: "boolean"
          },
          {
            name: "track_clicks",
            hint: "Whether or not to turn on click tracking for the message",
            control_type: "checkbox",
            type: "boolean"
          },
          {
            name: "send_at",
            hint: "When this message should be sent. If you specify a time " \
              "in the past, the message will be sent immediately.",
            type: "timestamp"
          }
        ].concat(if template_variables.blank?
                   []
                 else
                   [
                     {
                       name: "template_content",
                       type: "object",
                       properties: template_variables
                     }
                   ]
                 end)
      }
    }
  },

  actions: {
    send_message: {
      description: "Send <span class='provider'>message</span> from" \
        " template in <span class='provider'>Mandrill</span>",
      subtitle: "Send message",

      config_fields: [
        {
          name: "template",
          control_type: "select",
          pick_list: "templates",
          optional: false
        }
      ],

      input_fields: lambda { |object_definitions|
        object_definitions["send_template_input"]
      },

      execute: lambda { |_connection, input|
        message = {
          from_email: input["from_email"],
          from_name: input["from_name"],
          to: input["to"].split("\n").map { |to| { email: to.strip } },
          important: input["important"],
          track_opens: input["track_opens"],
          track_clicks: input["track_clicks"]
        }

        post("https://mandrillapp.com/api/1.0/messages/send-template.json") \
          .payload(template_name: input["template"],
                   template_content: (input["template_content"] || [])
                                       .map do |key, val|
                                         { name: key, content: val }
                                       end,
                   message:   message,
                   send_at: (input["send_at"] || "")
                              .utc
                              .to_s
                              .gsub(/[TZ]/, "T" => " ", "Z" => "")) \
          &.first
      },

      output_fields: lambda { |_object_definitions|
        [
          { name: "email" },
          { name: "status" },
          { name: "_id" }
        ]
      },

      sample_output: lambda {
        {
          email: "mail@workato.com",
          status: "send",
          _id: "abc123abc123abc123abc123abc123"
        }
      }
    }
  },

  pick_lists: {
    templates: lambda { |_connection|
      post("https://mandrillapp.com/api/1.0/templates/list.json") \
        .map { |template| [template["name"], template["slug"]] }
    }
  }
}
