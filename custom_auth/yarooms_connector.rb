{
  title: "Yarooms",
  connection: {
    fields: [
      {
        name: "subdomain",
        control_type: "subdomain",
        url: "yarooms.com",
        optional: true,
        },

      {
        name: "user",
        control_type: "email",
        optional: true
        },

      {
        name: "password",
        control_type: "password",
        optional: true
        },
      ],

    authorization: {
      type: "custom_auth",

      acquire: lambda do |connection|
        {
          authtoken: post("https://api.yarooms.com/auth").params(
            subdomain: connection["subdomain"],
            email: connection["user"],
            password: connection["password"])["data"]["token"]
          }
      end,

      refresh_on: [
        /Invalid token/
        ],

      detect_on: [
        /Invalid credentials/, /Invalid token/
        ],

      apply: lambda do |connection|
        headers("X-Token": connection["authtoken"])
      end,
      }
    },

  object_definitions: {
    location: {
      fields: lambda do
        [
          { name: "id", type: :integer },
          { name: "name" },
          { name: "timezone" },
          { name: "created_at", type: :date_time },
          { name: "updated_at", type: :date_time },
          ]
      end
      },

    meeting: {
      fields: lambda do
        [
          { name: "id", type: :integer },
          { name: "account_id", type: :integer },
          { name: "type_id", type: :integer },
          { name: "location_id", type: :integer },
          { name: "room_id", type: :integer },
          { name: "name" },
          { name: "description" },
          { name: "start", type: :date_time },
          { name: "end", type: :date_time },
          { name: "modified_by", type: :integer },
          { name: "status", type: :integer },
          { name: "checkin", type: :integer },
          { name: "created_at", type: :date_time },
          { name: "updated_at", type: :date_time },
          { name: "recurrence", type: :object, properties: [
            { name: "type" },
            { name: "first", type: :integer },
            { name: "exclude_weekends", type: :integer },
            { name: "weekdays", type: :array, of: :integer },
            { name: "step" },
            ]},
          ]
      end
      },

    user: {
      fields: lambda do
        [
          { name: "id", type: :integer },
          { name: "location_id", type: :integer },
          { name: "group_id", type: :integer },
          { name: "first_name" },
          { name: "last_name" },
          { name: "email" },
          { name: "time_format" },
          { name: "schedule_screen" },
          { name: "fday" },
          { name: "suspended", type: :integer },
          { name: "created_at", type: :date_time },
          { name: "updated_at", type: :date_time },
          ]
      end
      }
    },

  test: lambda do |connection|
    get("https://api.yarooms.com/accounts")["data"]
  end,

  pick_lists: {
    location: lambda do |connection|
      get("https://api.yarooms.com/locations")["data"]["list"].
        map { |location| [location["name"], location["id"]] }
    end,

    group: lambda do |connection|
      get("https://api.yarooms.com/groups")["data"]["list"].
        map { |group| [group["name"], group["id"]] }
    end,

    room: lambda do |connection|
      get("https://api.yarooms.com/rooms")["data"]["list"].
        map { |room| [room["name"], room["id"]] }
    end,

    meeting_type: lambda do |connection|
      get("https://api.yarooms.com/types")["data"]["list"].
        map { |meeting_type| [meeting_type["name"], meeting_type["id"]] }
    end,
    },

  triggers: {
    new_booking: {
      type: :paging_desc,

      input_fields: lambda do
        [
          { name: "since", type: :timestamp, optional: false },
          ]
      end,

      poll: lambda do |connection, input, last_created_since|
        last_check = (last_created_since || input["since"]).strftime("%Y%m%d%H%M%S")
        meetings = get("https://api.yarooms.com/sync/#{last_check}")["data"]["data"]["new"]
        next_created_since = meetings.last["date_created"] unless meetings.blank?

        {
          events: meetings,
          next_page: next_created_since
          }
      end,

      dedup: lambda do |meeting|
        meeting["id"]
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["meeting"]
      end,
      }  
    },

  actions: { 
    create_user: {
      input_fields: lambda do
        [
          { name: "location", control_type: "select", pick_list: "location", optional: false, type: :integer },
          { name: "group", control_type: "select", pick_list: "group", optional: false, type: :integer},
          { name: "first_name", optional: false },
          { name: "last_name", optional: false },
          { name: "email", optional: false, control_type: "email" },
          { name: "password", optional: false, control_type: "password" },
          { name: "time_format", type: :string, control_type: "select",
            pick_list: [
              ["24 hours", "m"],
              ["am/pm", "a"],
              ]  
            },
          { name: "schedule_screen", type: :string, control_type: "select",
            pick_list: [
              ["default", ""],
              ["monthly", "monthly"],
              ["weekly", "weekly"],
              ["daily", "daily"],
              ]  
            },
          { name: "first_day", type: :integer, control_type: "select",
            pick_list: [
              ["default", ""],
              ["monday", 1],
              ["sunday", 7],
              ]  
            },
          { name: "suspended", type: :integer, control_type: "select",
            pick_list: [
              ["yes", 1],
              ["no", 0],
              ]  
            },
          ]
      end,

      execute: lambda do |connection, input|
        post("https://api.yarooms.com/accounts").params(
          location_id: input["location"].to_i,
          group_id: input["group"].to_i,
          first_name: input["first_name"],
          last_name: input["last_name"],
          email: input["email"],
          password: input["password"],
          time_format: input["time_format"],
          schedule_screen: input["schedule_screen"],
          fday: input["first_day"].to_i,
          suspended: input["suspended"].to_i)["data"]
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["user"]
      end,
      },

    create_booking: {
      input_fields: lambda do
        [
          { name: "room", control_type: "select", pick_list: "room", optional: false, type: :integer},
          { name: "name", optional: false },
          { name: "start", type: :date_time, optional: false },
          { name: "end", type: :date_time, optional: false },
          { name: "approved", type: :integer, control_type: "select",
            pick_list: [
              ["yes", 1],
              ["no", 0],
              ]  
            },
          { name: "description" },
          { name: "meeting_type", control_type: "select", pick_list: "meeting_type", optional: false, type: :integer },
          ]
      end,

      execute: lambda do |connection, input|
        post("https://api.yarooms.com/meetings").params(
          room_id: input["room"].to_i,
          name: input["name"],
          start: input["start"].strftime("%Y-%m-%d %H:%M:%S"),
          end: input["end"].strftime("%Y-%m-%d %H:%M:%S"),
          status: input["approved"].to_i,
          description: input["description"],
          type_id: input["meeting_type"].to_i)["data"]
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["meeting"]
      end,
      },
    }
  }
