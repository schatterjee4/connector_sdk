{
  title: "Calendly",

  connection: {
    fields: [
      {
        name: "api_key",
    hint: "You can find your API key " \
          "<a href='https://calendly.com/integrations' " \
          "target='_blank'>here</a>"
      }
    ],

    authorization: {
      type: "custom_auth",

      # Calendly uses header auth (X-Token: <api key>)
      credentials: lambda do |connection|
        headers("X-Token": connection["api_key"])
      end
    }
  },

  object_definitions: {
    user: {
      fields: lambda do
        [
          { name: "id" },
          {
            name: "attributes",
            type: "object",
            properties: [
              { name: "name" },
              { name: "slug" },
              { name: "email", control_type: "email" },
              { name: "url", control_type: "url" },
              {
                name: "avatar",
                type: "object",
                properties: [
                  { name: "url", control_type:"url" }
                ]
              },
              { name: "created_at", type: "date_time" },
              { name: "updated_at", type: "date_time" }
            ]
          }
        ]
      end
    },

    event: {
      fields: lambda do
        [
          { name: "event" },
          { name: "time", type: "date_time" },
          {
            name: "payload", type: "object", properties: [
              {
                name: "event_type", type: "object", properties: [
                  { name: "kind" },
                  { name: "slug" },
                  { name: "name" },
                  { name: "duration", type: "integer" }
                ]
              },
              {
                name: "event", type: "object", properties: [
                  { name: "uuid" },
                  { name: "assigned_to", type: "array" },
                  {
                    name: "extended_assigned_to", type: "array", properties: [
                      { name: "name" },
                      { name: "email" },
                      { name: "primary", type: "boolean" }
                    ]
                  },
                  { name: "start_time", type: "date_time" },
                  { name: "start_time_pretty" },
                  { name: "invitee_start_time", type: "date_time" },
                  { name: "invitee_start_time_pretty" },
                  { name: "end_time", type: "date_time" },
                  { name: "end_time_pretty" },
                  { name: "invitee_end_time", type: "date_time" },
                  { name: "invitee_end_time_pretty" },
                  { name: "created_at", type: "date_time" },
                  { name: "location" },
                  { name: "canceled", type: "boolean" },
                  { name: "canceler_name" },
                  { name: "cancel_reason" },
                  { name: "canceled_at", type: "date_time" }
                ]
              },
              {
                name: "invitee", type: "object", properties: [
                  { name: "uuid" },
                  { name: "first_name" },
                  { name: "last_name" },
                  { name: "name" },
                  { name: "email", control_type: "email" },
                  { name: "timezone" },
                  { name: "created_at", type: "date_time" },
                  { name: "location" },
                  { name: "canceled", type: "boolean" },
                  { name: "canceler_name" },
                  { name: "cancel_reason" },
                  { name: "canceled_at", type: "date_time" }
                ]
              },
              {
                name: "questions_and_answers", type: "array", properties: [
                  { name: "question" },
                  { name: "answer" }
                ]
              },
              {
                name: "questions_and_responses", type: "object", properties: [
                  { name: "1_question" },
                  { name: "1_response" },
                  { name: "2_question" },
                  { name: "2_response" },
                  { name: "3_question" },
                  { name: "3_response" },
                  { name: "4_question" },
                  { name: "4_response" }
                ]
              },
              {
                name: "tracking", type: "object", properties: [
                  { name: "utm_campaign" },
                  { name: "utm_source" },
                  { name: "utm_medium" },
                  { name: "utm_content" },
                  { name: "utm_term" },
                  { name: "salesforce_uuid" }
                ]
              }
            ]
          }
        ]
      end
    },

    event_types: {
      fields: lambda do
        [
          {
            name: "data",
            type: "array",
            of: "object",
            properties: [
              { name: "type" },
              { name: "id" },
              {
                name: "attributes",
                type: "object",
                properties: [
                  { name: "name" },
                  { name: "description" },
                  { name: "duration", type: "number" },
                  { name: "slug" },
                  { name: "color" },
                  { name: "active", type: "boolean" },
                  { name: "created_at", type: "date_time" },
                  { name: "updated_at", type: "date_time" },
                  { name: "url", control_type: "url" }
                ]
              },
              {
                name: "relationships",
                type: "object",
                properties: [
                  {
                    name: "owner",
                    type: "object",
                    properties: [
                      {
                        name: "data",
                        type: "object",
                        properties: [
                          { name: "type" },
                          { name: "id" }
                        ]
                      }
                    ]
                  }
                ]
              }
            ]
          },
          {
            name: "included",
            type: "array",
            of: "object",
            properties: [
              { name: "type" },
              { name: "id" },
              {
                name: "attributes",
                type: "object",
                properties: [
                  { name: "slug" },
                  { name: "name" },
                  { name: "email" },
                  { name: "url" },
                  { name: "timezone" },
                  {
                    name: "avatar",
                    type: "object",
                    properties: [
                      { name: "url" }
                    ]
                  },
                  { name: "created_at", type: "date_time" },
                  { name: "updated_at", type: "date_time" }
                ]
              }
            ]
          }
        ]
      end
    }
  },

  test: lambda do |_connection|
    get("https://calendly.com/api/v1/echo")
  end,

  actions: {
    get_event_types: {
      description: "Get <span class='provider'>event types</span> " \
        "in <span class='provider'>Calendly</span>",

      input_fields: lambda do |_object_definitions|
      end,

      execute: lambda do |_connection, _input|
        get("https://calendly.com/api/v1/users/me/event_types?include=owner")
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["event_types"]
      end
    }
  },

  triggers: {
    new_event: {
      description: "New <span class='provider'>event</span> " \
        "in <span class='provider'>Calendly</span>",
      input_fields: lambda do |_object_definitions|
        {
          name: "event",
          control_type: "select",
          pick_list: "event_type",
          optional: false
        }
      end,

      webhook_subscribe: lambda do |webhook_url, _connection, input|
        case input["event_type"]
        when "invitee.created"
          event_type = ["invitee.created"]
        when "invitee.canceled"
          event_type = ["invitee.canceled"]
        else
          event_type = ["invitee.created", "invitee.canceled"]
        end

        post("https://calendly.com/api/v1/hooks").
          payload(url: webhook_url, events: event_type)
      end,

      webhook_notification: lambda do |_input, payload|
        payload
      end,

      webhook_unsubscribe: lambda do |webhook|
        delete("https://calendly.com/api/v1/hooks/#{webhook['id']}")
      end,

      dedup: lambda do |event|
        event["event"] + "@" + event["payload"]["event"]["uuid"]
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["event"]
      end
    }
  },

  pick_lists: {
    event_type: lambda do
      [
        # Display name, value
        %W[Event\ Created invitee.created],
        %W[Event\ Canceled invitee.canceled],
        %W[All\ Events all]
      ]
    end
  }
}
