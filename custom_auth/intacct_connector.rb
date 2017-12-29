{
  title: "Intacct (custom)",

  connection: {
    fields: [
      { name: "login_username", optional: false },
      { name: "login_password", optional: false, control_type: "password" },
      { name: "sender_id", optional: false },
      { name: "sender_password", optional: false, control_type: "password" },
      { name: "company_id", optional: false }
    ],

    authorization: {
      type: "custom_auth",

      refresh_on: [/Expired Token/],

      acquire: ->(connection){},

      detect_on: [/<status>failure<\/status>/],

      apply: lambda { |connection|
        headers("Content-Type" => "x-intacct-xml-request")
        payload do |current|
          current["control"] = {
            "senderid" => connection["sender_id"],
            "password" => connection["sender_password"],
            "controlid" => "testControlId",
            "uniqueid" => false,
            "dtdversion" => 3.0
          }
          current["operation"] = {
            "authentication" => {
              "login" => {
                "userid" => connection["login_username"],
                "companyid" => connection["company_id"],
                "password" => connection["login_password"]
              }
            }
          }
          content = current.delete("content")
          current["operation"]["content"] = content if content && content != {}
        end
        format_xml("request")
      }
    },

    base_uri: ->(_connection) { "https://api.intacct.com" }
  },

  test: ->(_connection) { post("/ia/xml/xmlgw.phtml") },

  object_definitions: {
    api_session: {
      fields: lambda { |_connection|
        [{ name: "sessionid", label: "Session ID" },
         { name: "endpoint", label: "Endpoint" }]
      }
    },

    result: {
      fields: lambda { |_connection|
        [{ name: "status", label: "Job status" },
         { name: "function", label: "Job function" },
         { name: "controlid", label: "control ID" },
         { name: "key", label: "Record Key" }]
      }
    },

    employee_create: {
      fields: lambda { |_connection|
        [{ name: "RECORDNO", label: "Record number", type: "integer" },
         {
           name: "EMPLOYEEID",
           label: "Employee ID",
           hint: "The employee ID to create. Required if company does not " \
             "use auto-numbering.",
           sticky: true
         },
         {
           name: "PERSONALINFO",
           label: "Personal info",
           type: "object",
           properties: [
             { name: "CONTACTNAME", label: "Contact name", optional: false }
           ]
         },
         {
           name: "STARTDATE",
           label: "Start date",
           hint: "Start date in format mm/dd/yyyy"
         },
         { name: "TITLE", label: "Title" },
         { name: "SSN", label: "SSN", hint: "Social security number" },
         { name: "EMPLOYEETYPE", label: "Employee type" },
         {
           name: "STATUS",
           hint: "Use active for Active otherwise use inactive for " \
            "Inactive (Default: active)",
           control_type: "select",
           pick_list: "statuses",
           toggle_hint: "Select from list",
           toggle_field: {
             name: "STATUS",
             label: "Status",
             toggle_hint: "Use custom value",
             control_type: "text",
             type: "string"
           }
         },
         {
           name: "BIRTHDATE",
           label: "Birth date",
           hint: "Birth date in format mm/dd/yyyy"
         },
         {
           name: "ENDDATE",
           label: "End date",
           hint: "End date in format mm/dd/yyyy"
         },
         {
           name: "TERMINATIONTYPE",
           label: "Termination type",
           control_type: "select",
           pick_list: "termination_types",
           toggle_hint: "Select from list",
           toggle_field: {
             name: "EMPLOYEETYPE",
             label: "Employee type",
             toggle_hint: "Use custom value",
             control_type: "text",
             type: "string"
           }
         },
         {
           name: "SUPERVISORID",
           label: "Supervisor ID",
           hint: "Manager employee ID"
         },
         {
           name: "GENDER",
           pick_list: "genders",
           toggle_hint: "Select from list",
           toggle_field: {
             name: "GENDER",
             toggle_hint: "Use custom value",
             control_type: "text",
             type: "string"
           }
         },
         { name: "DEPARTMENTID", label: "Department ID" },
         {
           name: "LOCATIONID",
           label: "Location ID",
           hint: "Location ID. Required only when an employee is created at " \
            "the top level in a multi-entity, multi-base-currency company.",
           sticky: true
         },
         { name: "CLASSID", label: "Class ID" },
         { name: "CURRENCY", hint: "Default currency code" },
         { name: "EARNINGTYPENAME", label: "Earning type name" },
         {
           name: "POSTACTUALCOST",
           label: "Post actual cost",
           hint: "Use false for No, true for Yes. (Default: false)",
           control_type: "checkbox",
           type: "boolean"
         },
         { name: "NAME1099", label: "Name 1099", hint: "Form 1099 name" },
         { name: "FORM1099TYPE", label: "Form 1099 type" },
         { name: "FORM1099BOX", label: "Form 1099 box" },
         {
           name: "SUPDOCFOLDERNAME",
           label: "SUP doc folder name",
           hint: "Attachment folder name"
         },
         {
           name: "PAYMETHODKEY",
           label: "Pay method key",
           hint: "Preferred payment method"
         },
         {
           name: "PAYMENTNOTIFY",
           label: "Payment notify",
           hint: "Send automatic payment notification (Default: false)",
           control_type: "checkbox",
           type: "boolean"
         },
         {
           name: "MERGEPAYMENTREQ",
           label: "Merge payment req",
           hint: "Merge payment requests (Default: true)",
           control_type: "checkbox",
           type: "boolean"
         },
         {
           name: "ACHENABLED",
           label: "ACH enabled",
           hint: "ACH enabled. Use false for No, true for Yes (Default: false)",
           control_type: "checkbox",
           type: "boolean"
         },
         { name: "ACHBANKROUTINGNUMBER", label: "ACH bank routing number" },
         { name: "ACHACCOUNTNUMBER", label: "ACH account number" },
         { name: "ACHACCOUNTTYPE", label: "ACH account type" },
         { name: "ACHREMITTANCETYPE", label: "ACH remittance type" },
         { name: "WHENCREATED", label: "Created date", type: "timestamp" },
         { name: "WHENMODIFIED", label: "Modified date", type: "timestamp" },
         { name: "CREATEDBY", label: "Created by" },
         { name: "MODIFIEDBY", label: "Modified by" }]
      }
    },

    employee_get: {
      fields: lambda { |_connection|
        [{ name: "RECORDNO", label: "Record number", type: "integer" },
         {
           name: "EMPLOYEEID",
           label: "Employee ID",
           hint: "The employee ID to create. Required if company does not " \
             "use auto-numbering.",
           sticky: true
         },
         {
           name: "PERSONALINFO",
           label: "Personal info",
           hint: "Contact info",
           type: "object",
           properties: [
             { name: "CONTACTNAME", hint: "Contact name to create" },
             { name: "PRINTAS" },
             { name: "COMPANYNAME" },
             {
               name: "TAXABLE",
               hint: "Taxable. Use false for No, true for Yes. " \
                "(Default: true)",
               control_type: "checkbox",
               type: "boolean"
             },
             { name: "TAXGROUP", hint: "Contact tax group name" },
             { name: "PREFIX" },
             { name: "FIRSTNAME" },
             { name: "LASTNAME" },
             { name: "INITIAL", hint: "Middle name" },
             {
               name: "PHONE1",
               hint: "Primary phone number",
               control_type: "phone"
             },
             {
               name: "PHONE2",
               hint: "Secondary phone number",
               control_type: "phone"
             },
             {
               name: "CELLPHONE",
               hint: "Cellular phone number",
               control_type: "phone"
             },
             { name: "PAGER", hint: "Pager number" },
             { name: "FAX", hint: "Fax number" },
             {
               name: "EMAIL1",
               hint: "Primary email address",
               control_type: "email"
             },
             {
               name: "EMAIL2",
               hint: "Secondary email address",
               control_type: "email"
             },
             { name: "URL1", hint: "Primary URL", control_type: "url" },
             { name: "URL2", hint: "Secondary URL", control_type: "url" },
             {
               name: "STATUS",
               hint: "Status. Use active for Active or inactivefor " \
                 "Inactive (Default: active)"
             },
             {
               name: "MAILADDRESS",
               type: "object",
               properties: [
                 { name: "ADDRESS1", hint: "Address line 1" },
                 { name: "ADDRESS2", hint: "Address line 2" },
                 { name: "CITY" },
                 { name: "STATE", hint: "State/province" },
                 { name: "ZIP", hint: "Zip/postal code" },
                 { name: "COUNTRY", hint: "Country" }
               ]
             }
           ]
         },
         {
           name: "STARTDATE",
           label: "Start date",
           hint: "Start date in format mm/dd/yyyy"
         },
         { name: "TITLE" },
         { name: "SSN", label: "SSN", hint: "Social security number" },
         { name: "EMPLOYEETYPE", label: "Employee type" },
         {
           name: "STATUS",
           hint: "Use active for Active otherwise use inactive " \
             "for Inactive (Default: active)",
           control_type: "select",
           pick_list: "statuses",
           toggle_hint: "Select from list",
           toggle_field: {
             name: "STATUS",
             label: "Status",
             toggle_hint: "Use custom value",
             control_type: "text",
             type: "string"
           }
         },
         {
           name: "BIRTHDATE",
           label: "Birth date",
           hint: "Birth date in format mm/dd/yyyy"
         },
         {
           name: "ENDDATE",
           label: "End date",
           hint: "End date in format mm/dd/yyyy"
         },
         {
           name: "TERMINATIONTYPE",
           label: "Termination type",
           control_type: "select",
           pick_list: "termination_types",
           toggle_hint: "Select from list",
           toggle_field: {
             name: "EMPLOYEETYPE",
             label: "Employee type",
             toggle_hint: "Use custom value",
             control_type: "text",
             type: "string"
           }
         },
         {
           name: "SUPERVISORID",
           label: "Supervisor ID",
           hint: "Manager employee ID"
         },
         {
           name: "GENDER",
           pick_list: "genders",
           toggle_hint: "Select from list",
           toggle_field: {
             name: "GENDER",
             label: "Gender",
             toggle_hint: "Use custom value",
             control_type: "text",
             type: "string"
           }
         },
         {
           name: "DEPARTMENTID",
           label: "Department ID"
         },
         {
           name: "LOCATIONID",
           label: "Location ID",
           hint: "Location ID. Required only when an employee is created " \
            "at the top level in a multi-entity, multi-base-currency company.",
           sticky: true
         },
         { name: "CLASSID", label: "Class ID" },
         {
           name: "CURRENCY",
           hint: "Default currency code"
         },
         { name: "EARNINGTYPENAME", label: "Earning type name" },
         {
           name: "POSTACTUALCOST",
           label: "Post actual cost",
           hint: "Use false for No, true for Yes. (Default: false)",
           control_type: "checkbox",
           type: "boolean"
         },
         { name: "NAME1099", label: "Name 1099", hint: "Form 1099 name" },
         { name: "FORM1099TYPE", label: "Form 1099 type" },
         { name: "FORM1099BOX", label: "Form 1099 box" },
         {
           name: "SUPDOCFOLDERNAME",
           label: "SUP doc folder name",
           hint: "Attachment folder name"
         },
         {
           name: "PAYMETHODKEY",
           label: "Pay method key",
           hint: "Preferred payment method"
         },
         {
           name: "PAYMENTNOTIFY",
           label: "Payment notify",
           hint: "Send automatic payment notification (Default: false)",
           control_type: "checkbox",
           type: "boolean"
         },
         {
           name: "MERGEPAYMENTREQ",
           label: "Merge payment req",
           hint: "Merge payment requests (Default: true)",
           control_type: "checkbox",
           type: "boolean"
         },
         {
           name: "ACHENABLED",
           label: "ACH enabled",
           hint: "ACH enabled. Use false for No, true for Yes (Default: false)",
           control_type: "checkbox",
           type: "boolean"
         },
         { name: "ACHBANKROUTINGNUMBER", label: "ACH bank routing number" },
         { name: "ACHACCOUNTNUMBER", label: "ACH account number" },
         { name: "ACHACCOUNTTYPE", label: "ACH account type" },
         { name: "ACHREMITTANCETYPE", label: "ACH remittance type" },
         { name: "WHENCREATED", label: "Created date", type: "timestamp" },
         { name: "WHENMODIFIED", label: "Modified date", type: "timestamp" },
         { name: "CREATEDBY", label: "Created by" },
         { name: "MODIFIEDBY", label: "Modified by" }]
      }
    },

    #  Purchase Order Transaction
    po_txn_header: {
      fields: lambda { |_connection|
        [
          { name: "@key", label: "Key", hint: "Document ID" },
          {
            name: "datecreated",
            hint: "Transaction date",
            type: "object",
            properties: [
              { name: "year", hint: "Year yyyy" },
              { name: "month", hint: "Month mm" },
              { name: "day", hint: "Day dd" }
            ]
          },
          {
            name: "dateposted",
            hint: "GL posting date",
            type: "object",
            properties: [
              { name: "year", hint: "Year yyyy" },
              { name: "month", hint: "Month mm" },
              { name: "day", hint: "Day dd" }
            ]
          },
          { name: "referenceno", hint: "Reference number" },
          { name: "vendordocno", hint: "Vendor document number" },
          { name: "termname", hint: "Payment term" },
          {
            name: "datedue",
            hint: "Due date",
            type: "object",
            properties: [
              { name: "year", hint: "Year yyyy" },
              { name: "month", hint: "Month mm" },
              { name: "day", hint: "Day dd" }
            ]
          },
          { name: "message" },
          { name: "shippingmethod" },
          {
            name: "returnto",
            hint: "Return to contact",
            type: "object",
            properties: [
              { name: "contactname", hint: "Pay to contact name" }
            ]
          },
          {
            name: "payto",
            hint: "Pay to contact",
            type: "object", properties: [
              { name: "contactname", hint: "Pay to contact name" }
            ]
          },
          { name: "supdocid", hint: "Attachments ID" },
          { name: "externalid" },
          { name: "basecurr", hint: "Base currency code" },
          { name: "currency", hint: "Transaction currency code" },
          {
            name: "exchratedate",
            hint: "Exchange rate date",
            type: "object",
            properties: [
              { name: "year", hint: "Year yyyy" },
              { name: "month", hint: "Month mm" },
              { name: "day", hint: "Day dd" }
            ]
          },
          {
            name: "exchratetype",
            hint: "Exchange rate type. Do not use if exchrate is set. " \
              "(Leave blank to use Intacct Daily Rate)"
          },
          {
            name: "exchrate",
            hint: "Exchange rate value. Do not use if exchangeratetype is set."
          },
          {
            name: "customfields",
            type: "array",
            of: "object",
            properties: [
              {
                name: "customfield",
                label: "Custom field",
                type: "array",
                of: "object",
                properties: [
                  {
                    name: "customfieldname",
                    label: "Custom field name",
                    hint: "Integration name for custom field"
                  },
                  {
                    name: "customfieldvalue",
                    label: "Custom field value",
                    hint: "Enter the value for Custom field"
                  }
                ]
              }
            ]
          },
          {
            name: "state",
            hint: "Action. Use Draft, Pending or Closed. (Default depends " \
              "on transaction definition configuration)"
          }
        ]
      }
    },

    po_txn_transitem: {
      fields: lambda { |_connection|
        [
          { name: "@key", label: "Key", hint: "Document ID" },
          {
            name: "updatepotransitems",
            hint: "To create new line-items",
            type: "array",
            of: "object",
            properties: [
              {
                name: "potransitem",
                label: "Purchase order line-items",
                type: "object",
                properties: [
                  { name: "itemid" },
                  { name: "itemdesc", hint: "Item description" },
                  {
                    name: "taxable",
                    hint: "Taxable. Use false for No, true for Yes. " \
                      "Customer must be set up for taxable.",
                    control_type: "checkbox",
                    type: "boolean"
                  },
                  { name: "warehouseid" },
                  { name: "quantity" },
                  {
                    name: "unit",
                    hint: "Unit of measure to base quantity off"
                  },
                  { name: "price" },
                  {
                    name: "sourcelinekey",
                    hint: "Source line to convert this line from. Use the" \
                      "RECORDNO of the line from the created from " \
                      "transaction document."
                  },
                  { name: "overridetaxamount", name: "Override tax amount" },
                  { name: "tax", hint: "Tax amount" },
                  { name: "locationid" },
                  { name: "departmentid" },
                  { name: "memo" },
                  { name: "itemdetails", hint: "Array of item details" },
                  {
                    name: "form1099",
                    hint: "Form 1099. Use false for No, truefor Yes. " \
                      "Vendor must be set up for 1099s.",
                    control_type: "checkbox",
                    type: "boolean"
                  },
                  {
                    name: "customfields",
                    label: "Custom fields",
                    type: "array",
                    of: "object",
                    properties: [
                      {
                        name: "customfield",
                        label: "Custom field",
                        type: "array",
                        of: "object",
                        properties: [
                          {
                            name: "customfieldname",
                            label: "Custom field name",
                            hint: "Integration name for custom field"
                          },
                          {
                            name: "customfieldvalue",
                            label: "Custom field value",
                            hint: "Enter the value for Custom field"
                          }
                        ]
                      }
                    ]
                  },
                  { name: "projectid" },
                  { name: "customerid" },
                  { name: "vendorid" },
                  { name: "employeeid" },
                  { name: "classid" },
                  { name: "contractid" },
                  {
                    name: "billable",
                    hint: "Billable. Use false for No, true for Yes. " \
                      "(Default: false)",
                    control_type: "checkbox",
                    type: "boolean"
                  }
                ]
              }
            ]
          }
        ]
      }
    },

    po_txn_updatepotransitem: {
      fields: lambda { |_connection|
        [
          { name: "@key", label: "Key", hint: "Document ID" },
          {
            name: "updatepotransitems",
            hint: "Array to update the line-items",
            type: "array",
            of: "object",
            properties: [
              {
                name: "updatepotransitem",
                label: "Purchase order line-items to update",
                type: "object",
                properties: [
                  {
                    name: "@line_num",
                    label: "Line num",
                    type: "integer",
                    optional: false
                  },
                  { name: "itemid" },
                  { name: "itemdesc", hint: "Item description" },
                  {
                    name: "taxable",
                    hint: "Taxable. Use false for No, true for Yes. " \
                      "Customer must be set up for taxable.",
                    control_type: "checkbox",
                    type: "boolean"
                  },
                  { name: "warehouseid" },
                  { name: "quantity" },
                  {
                    name: "unit",
                    hint: "Unit of measure to base quantity off"
                  },
                  { name: "price" },
                  { name: "locationid" },
                  { name: "departmentid" },
                  { name: "memo" },
                  { name: "itemdetails", hint: "Array of item details" },
                  {
                    name: "customfields",
                    type: "array",
                    of: "object",
                    properties: [
                      {
                        name: "customfield",
                        label: "Custom field",
                        type: "array",
                        of: "object",
                        properties: [
                          {
                            name: "customfieldname",
                            label: "Custom field name",
                            hint: "Integration name for custom field"
                          },
                          {
                            name: "customfieldvalue",
                            label: "Custom field value",
                            hint: "Enter the value for Custom field"
                          }
                        ]
                      }
                    ]
                  },
                  { name: "projectid" },
                  { name: "customerid" },
                  { name: "vendorid" },
                  { name: "employeeid" },
                  { name: "classid" },
                  { name: "contractid" },
                  {
                    name: "billable",
                    hint: "Billable. Use false for No, true for Yes. " \
                      "(Default: false)",
                    control_type: "checkbox",
                    type: "boolean"
                  }
                ]
              }
            ]
          }
        ]
      }
    },

    # attachment
    supdoc: {
      fields: lambda { |_connection|
        [
          {
            name: "supdocid",
            label: "Document ID",
            hint: "Attachment ID. Required if company does not have " \
              "attachment autonumbering configured."
          },
          {
            name: "supdocname",
            label: "Doc name",
            hint: "Name of attachment"
          },
          {
            name: "folder",
            label: "Folder name",
            hint: "Attachment folder name to create"
          },
          {
            name: "description",
            label: "Folder description",
            hint: "Description"
          },
          {
            name: "supdocfoldername",
            label: "Folder name",
            hint: "Attachments folder to create in"
          },
          {
            name: "supdocdescription",
            label: "Description",
            hint: "Attachment Description"
          },
          {
            name: "attachments",
            hint: "Zero to many attachments",
            type: "array",
            of: "object",
            properties: [
              {
                name: "attachment",
                type: "object",
                properties: [
                  {
                    name: "attachmentname",
                    label: "Attachment name",
                    hint: "File name, no period or extension",
                    sticky: true
                  },
                  {
                    name: "attachmenttype",
                    label: "Attachment type",
                    hint: "File extension, no period",
                    sticky: true
                  },
                  {
                    name: "attachmentdata",
                    label: "Attachment data",
                    hint: "Base64 encode the file’s binary data",
                    sticky: true
                  }
                ]
              }
            ]
          },
          { name: "creationdate", label: "Creation date" },
          { name: "createdby", label: "Created by" },
          { name: "lastmodified", label: "Last modified" },
          { name: "lastmodifiedby", label: "Last modified by" }
        ]
      }
    },

    # attachment folder
    supdocfolder: {
      fields: lambda { |_connection|
        [
          {
            name: "name",
            label: "Folder name",
            hint: "Attachment folder name to create"
          },
          {
            name: "description",
            label: "Folder description",
            hint: "Description"
          },
          {
            name: "parentfolder",
            label: "Parent folder name",
            hint: "Parent attachment folder"
          },
          {
            name: "supdocfoldername",
            label: "Folder name",
            hint: "Attachment folder name to create"
          },
          {
            name: "supdocfolderdescription",
            label: "Folder description",
            hint: "Description"
          },
          {
            name: "supdocparentfoldername",
            label: "Parent folder name",
            hint: "Parent attachment folder"
          },
          { name: "creationdate", label: "Creation date" },
          { name: "createdby", label: "Created by" },
          { name: "lastmodified", label: "Last modified" },
          { name: "lastmodifiedby", label: "Last modified by" }
        ]
      }
    }
  },

  methods: {
    parse_nested_elements: lambda { |input|
      input[:object].map do |key, value|
        if key == "content!"
          value
        else
          value = value.dig(0) if value.is_a?(Array)
          { key => call("parse_nested_elements", object: value) } if value != {}
        end
      end.compact.inject(:merge)
    }
  },

  actions: {
    # Attachment related actions
    create_attachments: {
      subtitle: "Create attachments",
      description: "Create <span class='provider'>attachments</span> in " \
        "<span class='provider'>Intacct</span>",

      input_fields: lambda { |object_definitions|
        object_definitions["supdoc"].
          ignored("creationdate", "createdby", "lastmodified",
                   "lastmodifiedby").
          ignored("folder", "description").
          required("supdocname", "supdocfoldername")
      },

      execute: lambda { |_connection, input, _object_definitions|
        payload = {
          "content" => {
            "function" => {
              "@controlid" => "testControlId",
              "create_supdoc" => input
            }
          }
        }
        attachment_response = (post("/ia/xml/xmlgw.phtml").
                   payload(payload).
                   dig("response", 0, "operation", 0, "result", 0) || {})
        call("parse_nested_elements", object: attachment_response)
      },

      output_fields: ->(object_definitions) { object_definitions["result"] }
    },

    get_attachment: {
      subtitle: "Get attachment",
      description: "Get <span class='provider'>attachment</span> in " \
        "<span class='provider'>Intacct</span>",

      input_fields: lambda { |_object_definitions|
        [{ name: "key", label: "Attachment ID", optional: false }]
      },

      execute: lambda { |_connection, input|
        payload = {
          "content" => {
            "function" => {
              "@controlid" => "testControlId",
              "get" => {
                "@object" => "supdoc",
                "@key" => input["key"]
              }
            }
          }
        }
        attachment_response = (post("/ia/xml/xmlgw.phtml").
                   payload(payload)
                   dig("response", 0, "operation", 0, "result", 0,
                        "data", 0, "supdoc", 0) || {})
        call("parse_nested_elements", object: attachment_response)
      },

      output_fields: lambda { |object_definitions|
        object_definitions["supdoc"].
          ignored("supdocfoldername", "supdocdescription")
      }
    },

    update_attachment: {
      subtitle: "Update attachment",
      description: "Update <span class='provider'>attachment</span> in " \
        "<span class='>Intacct</span>",

      input_fields: lambda { |object_definitions|
        object_definitions["supdoc"].
          ignored("creationdate", "createdby", "lastmodified",
                   "lastmodifiedby").
          ignored("folder", "description").
          required("supdocid")
      },

      execute: lambda { |_connection, input|
        payload = {
          "content" => {
            "function" => {
              "@controlid" => "testControlId",
              "update_supdoc" => input
            }
          }
        }
        attachment_response = (post("/ia/xml/xmlgw.phtml").
                   payload(payload).
                   dig("response", 0, "operation", 0, "result", 0) || {})
        call("parse_nested_elements", object: attachment_response)
      },

      output_fields: ->(object_definitions) { object_definitions["result"] }
    },

    # Attachment folder related actions
    create_attachment_folder: {
      subtitle: "Create attachment folder",
      description: "Create <span class='provider'>attachment folder</span> " \
         "in <span class='provider'>Intacct</span>",

      input_fields: lambda { |object_definitions|
        object_definitions["supdocfolder"].
          ignored("creationdate", "createdby",
                   "lastmodified", "lastmodifiedby").
          ignored("name", "description", "parentfolder").
          required("supdocfoldername")
      },

      execute: lambda { |_connection, input|
        payload = {
          "content" => {
            "function" => {
              "@controlid" => "testControlId",
              "create_supdocfolder" => input
            }
          }
        }
        folder_response = (post("/ia/xml/xmlgw.phtml").
                   payload(payload).
                   dig("response", 0, "operation", 0, "result", 0) || {})
        call("parse_nested_elements", object: folder_response)
      },

      output_fields: ->(object_definitions) { object_definitions["result"] }
    },

    get_attachment_folder: {
      subtitle: "Get attachment folder",
      description: "Get <span class='provider'>attachment_folder</span> in " \
        "<span class='provider'>Intacct</span>",

      input_fields: lambda { |_object_definitions|
        [{ name: "key", label: "Folder name", optional: false }]
      },

      execute: lambda { |_connection, input|
        payload = {
          "content" => {
            "function" => {
              "@controlid" => "testControlId",
              "get" => {
                "@object" => "supdocfolder",
                "@key" => input["key"]
              }
            }
          }
        }
        attachment_folder_response = (post("/ia/xml/xmlgw.phtml").
                   payload(payload).
                   dig("response", 0, "operation", 0, "result", 0,
                        "data", 0, "supdocfolder", 0) || {})
        call("parse_nested_elements", object: attachment_folder_response)
      },

      output_fields: lambda { |object_definitions|
        object_definitions["supdocfolder"].
          ignored("supdocfoldername", "supdocfolderdescription",
                   "supdocparentfoldername")
      }
    },

    update_attachment_folder: {
      subtitle: "Create attachment folder",
      description: "Create <span class='provider'>attachment folder</span> " \
        "in <span class='provider'>Intacct</span>",

      input_fields: lambda { |object_definitions|
        object_definitions["supdocfolder"].
          ignored("creationdate", "createdby", "lastmodified",
                   "lastmodifiedby").
          ignored("name", "description", "parentfolder").
          required("supdocfoldername")
      },

      execute: lambda { |_connection, input|
        payload = {
          "content" => {
            "function" => {
              "@controlid" => "testControlId",
              "update_supdocfolder" => input
            }
          }
        }
        folder_response = (post("/ia/xml/xmlgw.phtml").
                   payload(payload).
                   dig("response", 0, "operation", 0, "result", 0) || {})
        call("parse_nested_elements", object: folder_response)
      },

      output_fields: ->(object_definitions) { object_definitions["result"] }
    },

    # API Session related actions
    get_api_session: {
      subtitle: "Get API session",
      description: "Get <span class='provider'>API session</span> in " \
        "<span class='provider'>Intacct</span>",

      execute: lambda { |_connection, _input|
        payload = {
          "content" => {
            "function" => {
              "@controlid" => "testControlId",
              "getAPISession" => ""
            }
          }
        }
        api_response = (post("/ia/xml/xmlgw.phtml").
                   payload(payload).
                   dig("response", 0, "operation", 0, "result", 0) || {})
        call("parse_nested_elements", object: api_response)
      },

      output_fields: lambda { |object_definitions|
        object_definitions["api_session"]
      }
    },

    # Employee related actions
    create_employee: {
      subtitle: "Create employee",
      description: "Create <span class='provider'>employee</span> in " \
        "<span class='provider'>Intacct</span>",

      input_fields: lambda { |object_definitions|
        object_definitions["employee_create"].
          ignored("RECORDNO", "CREATEDBY", "MODIFIEDBY", "WHENCREATED",
                   "WHENMODIFIED").
          required("EMPLOYEEID", "PERSONALINFO")
      },

      execute: lambda { |_connection, input|
        payload = {
          "content" => {
            "function" => {
              "@controlid" => "testControlId",
              "create" => { "EMPLOYEE" => input }
            }
          }
        }
        employee_response = (post("/ia/xml/xmlgw.phtml").
                   payload(payload).
                   dig("response", 0, "operation", 0, "result", 0,
                        "data", 0, "employee", 0) || {})
        call("parse_nested_elements", object: employee_response)
      },

      output_fields: lambda { |object_definitions|
        object_definitions["employee_get"]
      }
    },

    get_employee: {
      subtitle: "Get employee",
      description: "Get <span class='provider'>employee</span> in " \
        "<span class='provider'>Intacct</span>",

      input_fields: lambda { |object_definitions|
        object_definitions["employee_get"].
          only("EMPLOYEEID").
          required("EMPLOYEEID")
      },

      execute: lambda { |_connection, input|
        payload = {
          "content" => {
            "function" => {
              "@controlid" => "testControlId",
              "read" => {
                "object" => "EMPLOYEE",
                "keys" => input["EMPLOYEEID"],
                "fields" => "*"
              }
            }
          }
        }
        employee_response = (post("/ia/xml/xmlgw.phtml").
                   payload(payload).
                   dig("response", 0, "operation", 0, "result", 0,
                        "data", 0, "EMPLOYEE", 0) || {})
        call("parse_nested_elements", object: employee_response)
      },

      output_fields: lambda { |object_definitions|
        object_definitions["employee_get"]
      }
    },

    update_employee: {
      subtitle: "Update employee",
      description: "Update <span class='provider'>employee</span> in " \
        "<span class='provider'>Intacct</span>",

      input_fields: lambda { |object_definitions|
        object_definitions["employee_get"].
          ignored("RECORDNO", "CREATEDBY", "MODIFIEDBY", "WHENCREATED",
                   "WHENMODIFIED").
          required("EMPLOYEEID", "PERSONALINFO")
      },

      execute: lambda { |_connection, input|
        payload = {
          "content" => {
            "function" => {
              "@controlid" => "testControlId",
              "update" => { "EMPLOYEE" => input }
            }
          }
        }
        employee_response = (post("/ia/xml/xmlgw.phtml").
                   payload(payload).
                   dig("response", 0, "operation", 0, "result", 0) || {})
        call("parse_nested_elements", object: employee_response)
      },

      output_fields: ->(object_definitions) { object_definitions["result"] }
    },

    # Purchase Order Transaction related actions
    update_purchase_transaction_header: {
      subtitle: "Update purchase transaction header",
      description: "Update <span class='provider'>purchase transaction " \
        "header</span> in <span class='provider'>Intacct</span>",
      help: "Pay special attention to map the data pills in the same order " \
        "as you see in the input list, for the action to be successful!",

      input_fields: lambda { |object_definitions|
        object_definitions["po_txn_header"].required("@key")
      },

      execute: lambda { |_connection, input|
        payload = {
          "content" => {
            "function" => {
              "@controlid" => "testControlId",
              "update_potransaction" =>  input
            }
          }
        }
        po_txn_response = (post("/ia/xml/xmlgw.phtml").
                   payload(payload).
                   dig("response", 0, "operation", 0, "result", 0) || {})
        call("parse_nested_elements", object: po_txn_response)
      },

      output_fields: ->(object_definitions) { object_definitions["result"] }
    },

    add_purchase_transaction_items: {
      subtitle: "Add purchase transaction items",
      description: "Add <span class='provider'>purchase transaction " \
        "items</span> in <span class='provider'>Intacct</span>",
      help: "Pay special attention to map the data pills in the same order " \
        "as you see in the input list, for the action to be successful!",

      input_fields: lambda { |object_definitions|
        object_definitions["po_txn_transitem"].required("@key")
      },

      execute: lambda { |_connection, input|
        payload = {
          "content" => {
            "function" => {
              "@controlid" => "testControlId",
              "update_potransaction" =>  input
            }
          }
        }
        po_txn_response = (post("/ia/xml/xmlgw.phtml").
                   payload(payload).
                   dig("response", 0, "operation", 0, "result", 0) || {})
        call("parse_nested_elements", object: po_txn_response)
      },

      output_fields: ->(object_definitions) { object_definitions["result"] }
    },

    update_purchase_transaction_items: {
      subtitle: "Update purchase transaction items",
      description: "Update <span class='provider'>purchase transaction " \
        "items</span> in <span class='provider'>Intacct</span>",
      help: "Pay special attention to map the data pills in the same order " \
        "as you see in the input list, for the action to be successful!",

      input_fields: lambda { |object_definitions|
        object_definitions["po_txn_updatepotransitem"].required("@key")
      },

      execute: lambda { |_connection, input|
        payload = {
          "content" => {
            "function" => {
              "@controlid" => "testControlId",
              "update_potransaction" =>  input
            }
          }
        }
        po_txn_response = (post("/ia/xml/xmlgw.phtml").
                   payload(payload).
                   dig("response", 0, "operation", 0, "result", 0) || {})
        call("parse_nested_elements", object: po_txn_response)
      },

      output_fields: ->(object_definitions) { object_definitions["result"] }
    }
  },

  pick_lists: {
    statuses: lambda { |_connection|
      [%w[Active active], %w[Inactive inactive]]
    },

    termination_types: lambda { |_connection|
      [%w[Voluntary voluntary], %w[Involuntary involuntary],
       %w[Deceased deceased], %w[Disability disability],
       %w[Retired retired]]
    }
  }
}
