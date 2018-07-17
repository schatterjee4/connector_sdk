{
  title: 'Workday REST',

  connection: {
    fields: [
      {
        name: 'tenant',
        optional: false,
        }
      ],

    authorization: {
      type: 'oauth2',

      authorization_url: ->() {
        'https://impl.workday.com/workato_pt1/authorize?response_type=code'
        },

      token_url: ->() {
        'https://wd2-impl-services1.workday.com/ccx/oauth2/workato_pt1/token'
        },

      client_id: 'NzZhOThjYzQtMjIyZC00OGVlLTllOGEtZmNlNzdmNGY2ZDc2',

      client_secret: '14mb915uqnzbugx32bjrntxc8um6kv9ijcvc0z9zqyr6z5yd7fcil0fbleudpp9h9w46rjjsuaa0vkvjvdfzyiiww3u6ina1093y',

      apply: ->(connection, access_token) {
        headers("Authorization": "Bearer #{access_token}")
        }
      },

    base_uri: ->(connection) {
      "https://wd2-impl-services1.workday.com"
      }
    },

  object_definitions: {
    worker: {
      fields: ->() {
        [
          {
            control_type: "text",
            label: "ID",
            type: "string",
            name: "id"
            },
          {
            control_type: "text",
            label: "Descriptor",
            type: "string",
            name: "descriptor"
            },
          {
            control_type: "text",
            label: "Href",
            type: "string",
            name: "href"
            },
          {
            control_type: "text",
            label: "Primary work email",
            type: "string",
            name: "primaryWorkEmail"
            },
          {
            control_type: "text",
            label: "Business title",
            type: "string",
            name: "businessTitle"
            },
          {
            properties: [
              {
                control_type: "text",
                label: "Descriptor",
                type: "string",
                name: "descriptor"
                },
              {
                control_type: "text",
                label: "ID",
                type: "string",
                name: "id"
                },
              {
                control_type: "text",
                label: "Href",
                type: "string",
                name: "href"
                }
              ],
            label: "Primary supervisory organization",
            type: "object",
            name: "primarySupervisoryOrganization"
            },
          {
            control_type: "text",
            label: "Primary work phone",
            type: "string",
            name: "primaryWorkPhone"
            },
          {
            control_type: "text",
            label: "Is manager",
            render_input: {},
            parse_output: {},
            toggle_hint: "Select from option list",
            toggle_field: {
              label: "Is manager",
              control_type: "text",
              toggle_hint: "Use custom value",
              type: "boolean",
              name: "isManager"
              },
            type: "boolean",
            name: "isManager"
            }
          ]
        }
      },

    worker_profile: {
      fields: ->() {
        [
          {
            control_type: "text",
            label: "ID",
            type: "string",
            name: "id"
            },
          {
            control_type: "text",
            label: "Descriptor",
            type: "string",
            name: "descriptor"
            },
          {
            control_type: "text",
            label: "Href",
            type: "string",
            name: "href"
            },
          {
            control_type: "text",
            label: "Is manager",
            render_input: {},
            parse_output: {},
            toggle_hint: "Select from option list",
            toggle_field: {
              label: "Is manager",
              control_type: "text",
              toggle_hint: "Use custom value",
              type: "boolean",
              name: "isManager"
              },
            type: "boolean",
            name: "isManager"
            },
          {
            control_type: "text",
            label: "Business title",
            type: "string",
            name: "businessTitle"
            },
          {
            control_type: "text",
            label: "Primary work email",
            type: "string",
            name: "primaryWorkEmail"
            },
          {
            properties: [
              {
                control_type: "text",
                label: "Descriptor",
                type: "string",
                name: "descriptor"
                },
              {
                control_type: "text",
                label: "ID",
                type: "string",
                name: "id"
                },
              {
                control_type: "text",
                label: "Href",
                type: "string",
                name: "href"
                }
              ],
            label: "Primary supervisory organization",
            type: "object",
            name: "primarySupervisoryOrganization"
            }
          ]
        }
      },

    worker_time_off_summary: {
      fields: ->() {
        [
          {
            control_type: "text",
            label: "Descriptor",
            type: "string",
            name: "descriptor"
            },
          {
            control_type: "text",
            label: "ID",
            type: "string",
            name: "id"
            },
          {
            control_type: "text",
            label: "Href",
            type: "string",
            name: "href"
            },
          {
            control_type: "text",
            label: "Total hourly balance",
            type: "string",
            name: "totalHourlyBalance"
            }
          ]
        }
      },

    inbox_task: {
      fields: ->() {
        [
          {
            control_type: "text",
            label: "Descriptor",
            type: "string",
            name: "descriptor"
            },
          {
            control_type: "text",
            label: "ID",
            type: "string",
            name: "id"
            },
          {
            control_type: "text",
            label: "Href",
            type: "string",
            name: "href"
            },
          {
            properties: [
              {
                control_type: "text",
                label: "Descriptor",
                type: "string",
                name: "descriptor"
                },
              {
                control_type: "text",
                label: "ID",
                type: "string",
                name: "id"
                },
              {
                control_type: "text",
                label: "Href",
                type: "string",
                name: "href"
                }
              ],
            label: "Subject",
            type: "object",
            name: "subject"
            },
          {
            properties: [
              {
                control_type: "text",
                label: "Descriptor",
                type: "string",
                name: "descriptor"
                },
              {
                control_type: "text",
                label: "ID",
                type: "string",
                name: "id"
                },
              {
                control_type: "text",
                label: "Href",
                type: "string",
                name: "href"
                }
              ],
            label: "Overall process",
            type: "object",
            name: "overallProcess"
            },
          {
            properties: [
              {
                control_type: "text",
                label: "Descriptor",
                type: "string",
                name: "descriptor"
                },
              {
                control_type: "text",
                label: "ID",
                type: "string",
                name: "id"
                }
              ],
            label: "Status",
            type: "object",
            name: "status"
            },
          {
            properties: [
              {
                control_type: "text",
                label: "Descriptor",
                type: "string",
                name: "descriptor"
                },
              {
                control_type: "text",
                label: "ID",
                type: "string",
                name: "id"
                }
              ],
            label: "Step type",
            type: "object",
            name: "stepType"
            },
          {
            control_type: "text",
            label: "Assigned",
            render_input: "date_time_conversion",
            parse_output: "date_time_conversion",
            type: "date_time",
            name: "assigned"
            },
          {
            control_type: "text",
            label: "Due",
            type: "string",
            name: "due"
            }
          ]
        }
      },

    time_off_entry: {
      fields: ->() {
        [
          {
            control_type: "text",
            label: "Descriptor",
            type: "string",
            name: "descriptor"
            },
          {
            control_type: "text",
            label: "ID",
            type: "string",
            name: "id"
            },
          {
            properties: [
              {
                control_type: "text",
                label: "Descriptor",
                type: "string",
                name: "descriptor"
                },
              {
                control_type: "text",
                label: "ID",
                type: "string",
                name: "id"
                },
              {
                control_type: "text",
                label: "Href",
                type: "string",
                name: "href"
                },
              {
                properties: [
                  {
                    control_type: "text",
                    label: "Descriptor",
                    type: "string",
                    name: "descriptor"
                    },
                  {
                    control_type: "text",
                    label: "ID",
                    type: "string",
                    name: "id"
                    }
                  ],
                label: "Plan",
                type: "object",
                name: "plan"
                }
              ],
            label: "Time off",
            type: "object",
            name: "timeOff"
            },
          {
            control_type: "text",
            label: "Date",
            type: "string",
            name: "date"
            },
          {
            properties: [
              {
                control_type: "text",
                label: "Descriptor",
                type: "string",
                name: "descriptor"
                },
              {
                control_type: "text",
                label: "ID",
                type: "string",
                name: "id"
                },
              {
                control_type: "text",
                label: "Href",
                type: "string",
                name: "href"
                },
              {
                control_type: "text",
                label: "Status",
                type: "string",
                name: "status"
                }
              ],
            label: "Time off request",
            type: "object",
            name: "timeOffRequest"
            },
          {
            properties: [
              {
                control_type: "text",
                label: "Descriptor",
                type: "string",
                name: "descriptor"
                },
              {
                control_type: "text",
                label: "ID",
                type: "string",
                name: "id"
                }
              ],
            label: "Unit of time",
            type: "object",
            name: "unitOfTime"
            },
          {
            properties: [
              {
                control_type: "text",
                label: "Descriptor",
                type: "string",
                name: "descriptor"
                },
              {
                control_type: "text",
                label: "ID",
                type: "string",
                name: "id"
                },
              {
                control_type: "text",
                label: "Href",
                type: "string",
                name: "href"
                }
              ],
            label: "Employee",
            type: "object",
            name: "employee"
            },
          {
            control_type: "text",
            label: "Units",
            type: "string",
            name: "units"
            }
          ]
        }
      },

    time_off_plan: {
      fields: ->() {
        [
          {
            control_type: "text",
            label: "Descriptor",
            type: "string",
            name: "descriptor"
            },
          {
            control_type: "text",
            label: "ID",
            type: "string",
            name: "id"
            },
          {
            control_type: "text",
            label: "Time off balance",
            type: "string",
            name: "timeOffBalance"
            },
          {
            properties: [
              {
                control_type: "text",
                label: "Descriptor",
                type: "string",
                name: "descriptor"
                },
              {
                control_type: "text",
                label: "ID",
                type: "string",
                name: "id"
                }
              ],
            label: "Unit of time",
            type: "object",
            name: "unitOfTime"
            }
          ]
        }
      },

    pay_slip: {
      fields: ->() {
        [
          {
            control_type: "text",
            label: "Descriptor",
            type: "string",
            name: "descriptor"
            },
          {
            control_type: "text",
            label: "ID",
            type: "string",
            name: "id"
            },
          {
            control_type: "text",
            label: "Gross",
            type: "string",
            name: "gross"
            },
          {
            properties: [
              {
                control_type: "text",
                label: "Descriptor",
                type: "string",
                name: "descriptor"
                },
              {
                control_type: "text",
                label: "ID",
                type: "string",
                name: "id"
                }
              ],
            label: "Status",
            type: "object",
            name: "status"
            },
          {
            control_type: "text",
            label: "Net",
            type: "string",
            name: "net"
            },
          {
            control_type: "text",
            label: "Date",
            type: "string",
            name: "date"
            }
          ]
        }
      },

    job_change_reason: {
      fields: ->() {
        [
          {
            control_type: "text",
            label: "Descriptor",
            type: "string",
            name: "descriptor"
            },
          {
            control_type: "text",
            label: "ID",
            type: "string",
            name: "id"
            },
          {
            control_type: "text",
            label: "Href",
            type: "string",
            name: "href"
            },
          {
            control_type: "text",
            label: "Manager reason",
            render_input: {},
            parse_output: {},
            toggle_hint: "Select from option list",
            toggle_field: {
              label: "Manager reason",
              control_type: "text",
              toggle_hint: "Use custom value",
              type: "boolean",
              name: "managerReason"
              },
            type: "boolean",
            name: "managerReason"
            },
          {
            control_type: "text",
            label: "Is for employee",
            render_input: {},
            parse_output: {},
            toggle_hint: "Select from option list",
            toggle_field: {
              label: "Is for employee",
              control_type: "text",
              toggle_hint: "Use custom value",
              type: "boolean",
              name: "isForEmployee"
              },
            type: "boolean",
            name: "isForEmployee"
            },
          {
            control_type: "text",
            label: "Is for contingent worker",
            render_input: {},
            parse_output: {},
            toggle_hint: "Select from option list",
            toggle_field: {
              label: "Is for contingent worker",
              control_type: "text",
              toggle_hint: "Use custom value",
              type: "boolean",
              name: "isForContingentWorker"
              },
            type: "boolean",
            name: "isForContingentWorker"
            }
          ]
        }
      },

    supervisory_organization: {
      fields: ->() {
        [
          {
            control_type: "text",
            label: "Descriptor",
            type: "string",
            name: "descriptor"
            },
          {
            control_type: "text",
            label: "ID",
            type: "string",
            name: "id"
            },
          {
            control_type: "text",
            label: "Href",
            type: "string",
            name: "href"
            },
          {
            control_type: "text",
            label: "Workers",
            type: "string",
            name: "workers"
            },
          {
            properties: [
              {
                control_type: "text",
                label: "Descriptor",
                type: "string",
                name: "descriptor"
                },
              {
                control_type: "text",
                label: "ID",
                type: "string",
                name: "id"
                },
              {
                control_type: "text",
                label: "Href",
                type: "string",
                name: "href"
                }
              ],
            label: "Manager",
            type: "object",
            name: "manager"
            },
          {
            control_type: "text",
            label: "Name",
            type: "string",
            name: "name"
            }
          ]
        }
      }
    },

  test: ->(connection) {
    get("/ccx/api/v1/#{connection['tenant']}/auditLogs")
    },

  actions: {
    #     test: {
    #       input_fields: ->() {[]},

    #       execute: ->(connection, input) {
    #         get("/ccx/api/v1/#{connection['tenant']}/workers/me/inboxTasks?limit=100")
    #         },

    #       output_fields: ->(object_definitions) {}
    #       },

    list_inbox_tasks_for_current_user: {
      input_fields: ->() {[]},

      execute: ->(connection, input) {
        { inbox_tasks: get("/ccx/api/v1/#{connection['tenant']}/workers/me/inboxTasks").params(
          limit: 100
          )["data"]
          }
        },

      output_fields: ->(object_definitions) {
        [
          { name: "inbox_tasks", type: "array", of: "object", properties: object_definitions["inbox_task"] }
          ]
        }
      },

    get_inbox_task: {
      input_fields: ->() {
        [
          { name: "inbox_task_id", type: "string", optional: false }
          ]
        },

      execute: ->(connection, input) {
        get("/ccx/api/v1/#{connection['tenant']}/inboxTasks/#{input["inbox_task_id"]}")
        },

      output_fields: ->(object_definitions) {}

      },

    approve_inbox_task: {
      input_fields: ->() {
        [
          { name: "inbox_task_id", type: "string", optional: false }
          ]
        },

      execute: ->(connection, input) {
        { inbox_tasks: put("/ccx/api/v1/#{connection['tenant']}/inboxTasks/#{input["inbox_task_id"]}").params(
          type: "approval"
          )["data"]
          }
        },

      output_fields: ->(object_definitions) {
        [
          { name: "inbox_tasks", type: "array", of: "object", properties: object_definitions["inbox_task"] }
          ]
        }
      },

    deny_inbox_task: {
      input_fields: ->() {
        [
          { name: "inbox_task_id", type: "string", optional: false }
          ]
        },

      execute: ->(connection, input) {
        { inbox_tasks: put("/ccx/api/v1/#{connection['tenant']}/inboxTasks/#{input["inbox_task_id"]}").params(
          type: "denial"
          )["data"]
          }
        },

      output_fields: ->(object_definitions) {
        [
          { name: "inbox_tasks", type: "array", of: "object", properties: object_definitions["inbox_task"] }
          ]
        }
      },

    list_workers: {
      input_fields: ->() {[]},

      execute: ->(connection, input) {
        { 
          workers: get("/ccx/api/v1/#{connection['tenant']}/workers").params(limit: 100)["data"]
          }
        },

      output_fields: ->(object_definitions) {
        [
          { name: "workers", type: "array", of: "object", properties: object_definitions["worker"] }
          ]
        }
      },

    get_worker: {
      input_fields: ->() {
        [
          { name: "worker_id", type: "string", optional: false }
          ]
        },

      execute: ->(connection, input) {
        { worker: get("/ccx/api/v1/#{connection['tenant']}/workers/#{input["worker_id"]}") }
        },

      output_fields: ->(object_definitions) {
        [
          { name: "worker", type: "object", properties: object_definitions["worker_profile"] }
          ]
        }
      },
    
    get_worker_direct_reports: {
      input_fields: ->() {
        [
          { name: "worker_id", type: "string", optional: false }
          ]
        },

      execute: ->(connection, input) {
        { direct_reports: get("/ccx/api/v1/#{connection['tenant']}/workers/#{input["worker_id"]}/directReports")["data"] }
        },

      output_fields: ->(object_definitions) {
        [
          { name: "direct_reports", type: "object", properties: object_definitions["worker"] }
          ]
        }
      },

    get_worker_time_off_summary: {
      input_fields: ->() {
        [
          { name: "worker_id", type: "string", optional: false }
          ]
        },

      execute: ->(connection, input) {
        { 
          worker_time_off_summary: get("/ccx/api/v1/#{connection['tenant']}/workers/#{input["worker_id"]}").params(
            view: "timeOffSummary"
            )
          }
        },

      output_fields: ->(object_definitions) {
        [
          { worker_time_off_summary: "worker", type: "object", properties: object_definitions["worker_time_off_summary"] }
          ]
        }
      },

    search_for_worker: {
      input_fields: ->() {
        [
          { name: "worker_name", type: "string", optional: false }
          ]
        },

      execute: ->(connection, input) {
        { workers: get("/ccx/api/v1/#{connection['tenant']}/workers").params(search: input["worker_name"])["data"] }
        },

      output_fields: ->(object_definitions) {
        [
          { name: "workers", type: "array", of: "object", properties: object_definitions["worker"] }
          ]
        }
      },

    list_pay_slips: {
      input_fields: ->() {
        [
          {
            name: "worker_id",
            label: "Worker",
            control_type: "select",
            pick_list: "workers",
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: "worker_id",
              label: "Worker",
              type: "string",
              control_type: "text",
              optional: false,
              toggle_hint: "Use Worker ID"
              }
            },
          ]
        },

      execute: ->(connection, input) {
        { pay_slips: get("/ccx/api/v1/#{connection['tenant']}/workers/#{input["worker_id"]}/paySlips").params(limit: 100)["data"] }
        },

      output_fields: ->(object_definitions) {
        [
          { name: "pay_slips", type: "array", of: "object", properties: object_definitions["pay_slip"] }
          ]
        }
      },

    list_inbox_tasks: {
      input_fields: ->() {
        [
          {
            name: "worker_id",
            label: "Worker",
            control_type: "select",
            pick_list: "workers",
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: "worker_id",
              label: "Worker",
              type: "string",
              control_type: "text",
              optional: false,
              toggle_hint: "Use Worker ID"
              }
            },
          ]
        },

      execute: ->(connection, input) {
        { inbox_tasks: get("/ccx/api/v1/#{connection['tenant']}/workers/#{input["worker_id"]}/inboxTasks").params(limit: 100)["data"] }
        },

      output_fields: ->(object_definitions) {
        [
          { name: "inbox_tasks", type: "array", of: "object", properties: object_definitions["inbox_task"] }
          ]
        }
      },

    list_time_off_entries: {
      input_fields: ->() {
        [
          {
            name: "worker_id",
            label: "Worker",
            control_type: "select",
            pick_list: "workers",
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: "worker_id",
              label: "Worker",
              type: "string",
              control_type: "text",
              optional: false,
              toggle_hint: "Use Worker ID"
              }
            },
          ]
        },

      execute: ->(connection, input) {
        { time_off_entries: get("/ccx/api/v1/#{connection['tenant']}/workers/#{input["worker_id"]}/timeOffEntries").params(limit: 100)["data"] }
        },

      output_fields: ->(object_definitions) {
        [
          { name: "time_off_entries", type: "array", of: "object", properties: object_definitions["time_off_entry"] }
          ]
        }
      },

    list_time_off_plans: {
      input_fields: ->() {
        [
          {
            name: "worker_id",
            label: "Worker",
            control_type: "select",
            pick_list: "workers",
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: "worker_id",
              label: "Worker",
              type: "string",
              control_type: "text",
              optional: false,
              toggle_hint: "Use Worker ID"
              }
            },
          ]
        },

      execute: ->(connection, input) {
        { time_off_plans: get("/ccx/api/v1/#{connection['tenant']}/workers/#{input["worker_id"]}/timeOffPlans").params(limit: 100)["data"] }
        },

      output_fields: ->(object_definitions) {
        [
          { name: "time_off_plans", type: "array", of: "object", properties: object_definitions["time_off_plan"] }
          ]
        }
      },

    list_organizations: {
      input_fields: ->() {
        [
          {
            name: "organization_type_id",
            label: "Organization type",
            control_type: "select",
            pick_list: "organization_types",
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: "organization_type_id",
              label: "Organization type",
              type: "string",
              control_type: "text",
              optional: false,
              toggle_hint: "Use Organization type ID"
              }
            },
          ]
        },

      execute: ->(connection, input) {
        { inbox_tasks: get("/ccx/api/v1/#{connection['tenant']}/workers/#{input["worker_id"]}/organizations").params(
          limit: 100, 
          organizationType: input["organization_type_id"]
          )["data"] }
        },

      output_fields: ->(object_definitions) {
        [
          { name: "inbox_tasks", type: "array", of: "object", properties: object_definitions["inbox_task"] }
          ]
        }
      },
    
    list_job_change_reasons: {
      input_fields: ->() {[]},

      execute: ->(connection, input) {
        { job_change_reasons: get("/ccx/api/v1/#{connection['tenant']}/jobChangeReasons")["data"] }
        },

      output_fields: ->(object_definitions) {
        [
          { name: "job_change_reasons", type: "array", of: "objects", properties: object_definitions["job_change_reason"] }
          ]
        }
      },

    get_job_change_reason: {
      input_fields: ->() {
        [
          { name: "job_change_reason_id", type: "string", optional: false }
          ]
        },

      execute: ->(connection, input) {
        { job_change_reason: get("/ccx/api/v1/#{connection['tenant']}/jobChangeReasons/#{input["job_change_reason_id"]}") }
        },

      output_fields: ->(object_definitions) {
        [
          { name: "job_change_reason", type: "object", properties: object_definitions["job_change_reason"] }
          ]
        }
      },

    list_supervisory_organizations: {
      input_fields: ->() {[]},

      execute: ->(connection, input) {
        { supervisory_organizations: get("/ccx/api/v1/#{connection['tenant']}/supervisoryOrganizations").params(limit: 100)["data"] }
        },

      output_fields: ->(object_definitions) {
        [
          { name: "supervisory_organizations", type: "array", of: "object", properties: object_definitions["supervisory_organization"] }
          ]
        }
      },
    
    get_supervisory_organization: {
      input_fields: ->() {
        [
          {
            name: "supervisory_organization_id",
            label: "Supervisory organization",
            control_type: "select",
            pick_list: "supervisory_organizations",
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: "supervisory_organization_id",
              label: "Supervisory organization",
              type: "string",
              control_type: "text",
              optional: false,
              toggle_hint: "Use Supervisory Organizaton ID"
              }
            },
          ]
        },

      execute: ->(connection, input) {
        { supervisory_organization: get("/ccx/api/v1/#{connection['tenant']}/supervisoryOrganizations/#{input["supervisory_organization_id"]}") }
        },

      output_fields: ->(object_definitions) {
        [
          { name: "supervisory_organization", type: "object", properties: object_definitions["supervisory_organization"] }
          ]
        }
      },

    list_supervisory_organizations_managed_by_user: {
      input_fields: ->() {
        [
          {
            name: "worker_id",
            label: "Worker",
            control_type: "select",
            pick_list: "workers",
            optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: "worker_id",
              label: "Worker",
              type: "string",
              control_type: "text",
              optional: false,
              toggle_hint: "Use Worker ID"
              }
            },
          ]
        },

      execute: ->(connection, input) {
        { supervisory_organizations: get("/ccx/api/v1/#{connection['tenant']}/workers/#{input["worker_id"]}/supervisoryOrganizationsManaged").params(limit: 100)["data"] }
        },

      output_fields: ->(object_definitions) {
        [
          { name: "supervisory_organizations", type: "array", of: "object", properties: object_definitions["supervisory_organization"] }
          ]
        }
      },

    },

  triggers: {
    new_worker: {
      input_fields: ->() {[]},

      poll: ->(connection, input, offset) {
        page_size = 100
        offset = offset.present? ? offset : 0
        workers = []
        workers_raw = get("/ccx/api/v1/#{connection['tenant']}/workers").
          params(
            limit: page_size,
            offset: offset
            )["data"]
        workers_raw.each do |w|
          workers << { worker: w }
        end

        next_offset = offset + page_size

        {
          events: workers,
          next_poll: next_offset,
          can_poll_more: workers.length >= page_size
          }
        },

      dedup: ->(worker) {
        worker['worker']['id']
        },

      output_fields: ->(object_definitions) {
        [
          { name: 'worker', type: 'object', properties: object_definitions['worker'] }
          ]
        }
      },
    new_job_change_reason: {
      input_fields: ->() {[]},

      poll: ->(connection, input, offset) {
        page_size = 100
        offset = offset.present? ? offset : 0
        job_change_reasons = []
        job_change_reason_raw = get("/ccx/api/v1/#{connection['tenant']}/jobChangeReasons").
          params(
            limit: page_size,
            offset: offset
            )["data"]
        job_change_reason_raw.each do |r|
          job_change_reasons << { job_change_reason: r }
        end

        next_offset = offset + page_size

        {
          events: job_change_reasons,
          next_poll: next_offset,
          can_poll_more: job_change_reasons.length >= page_size
          }
        },

      dedup: ->(reason) {
        reason['job_change_reason']['id']
        },

      output_fields: ->(object_definitions) {
        [
          { name: 'job_change_reason', type: 'object', properties: object_definitions['job_change_reason'] }
          ]
        }
      }
    },

  pick_lists: {
    workers: ->(connection) {
      get("/ccx/api/v1/#{connection['tenant']}/workers").params(limit: 100)['data'].
        map { |worker| [worker['descriptor'], worker['id']] }
      },
    organization_types: ->(connection) {
      get("/ccx/api/v1/#{connection['tenant']}/organizationTypes").params(limit: 100)['data'].
        map { |organization_type| [organization_type['descriptor'], organization_type['id']] }
      },
    supervisory_organizations: ->(connection) {
      get("/ccx/api/v1/#{connection['tenant']}/supervisoryOrganizations").params(limit: 100)['data'].
        map { |supervisory_organization| [supervisory_organization['descriptor'], supervisory_organization['id']] }
      }
    },
  }
