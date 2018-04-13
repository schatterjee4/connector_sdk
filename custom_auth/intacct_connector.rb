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

      acquire: ->(_connection) {},

      detect_on: [%r{<status>failure</status>}],

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
        [
          { name: "sessionid", label: "Session ID" },
          { name: "endpoint", label: "Endpoint" }
        ]
      }
    },

    result: {
      fields: lambda { |_connection|
        [
          { name: "status", label: "Job status" },
          { name: "function", label: "Job function" },
          { name: "controlid", label: "Control ID" },
          { name: "key", label: "Record key" }
        ]
      }
    },

    employee_create: {
      fields: lambda { |_connection|
        [
          { name: "RECORDNO", label: "Record number", type: "integer" },
          { name: "EMPLOYEEID", label: "Employee ID", sticky: true },
          {
            name: "PERSONALINFO",
            label: "Personal info",
            hint: "Contact info",
            optional: false,
            type: "object",
            properties: [{
              name: "CONTACTNAME",
              label: "Contact name",
              hit: "Contact name of an existing contact",
              optional: false,
              control_type: "select",
              pick_list: "contact_names",
              toggle_hint: "Select from list",
              toggle_field: {
                name: "CONTACTNAME",
                label: "Contact name",
                toggle_hint: "Use custom value",
                control_type: "text",
                type: "string"
              }
            }]
          },
          { name: "STARTDATE", label: "Start date", type: "date" },
          { name: "TITLE", label: "Title" },
          { name: "SSN", label: "Social security number" },
          { name: "EMPLOYEETYPE", label: "Employee type" },
          {
            name: "STATUS",
            label: "Status",
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
          { name: "BIRTHDATE", label: "Birth date", type: "date" },
          { name: "ENDDATE", label: "End date", type: "date" },
          {
            name: "TERMINATIONTYPE",
            label: "Termination type",
            control_type: "select",
            pick_list: "termination_types",
            toggle_hint: "Select from list",
            toggle_field: {
              name: "TERMINATIONTYPE",
              label: "Termination type",
              toggle_hint: "Use custom value",
              control_type: "text",
              type: "string"
            }
          },
          {
            name: "SUPERVISORID",
            label: "Manager",
            control_type: "select",
            pick_list: "employees",
            toggle_hint: "Select from list",
            toggle_field: {
              name: "SUPERVISORID",
              label: "Manager's employee ID",
              toggle_hint: "Use custom value",
              control_type: "text",
              type: "string"
            }
          },
          {
            name: "GENDER",
            label: "Gender",
            control_type: "select",
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
            label: "Department",
            control_type: "select",
            pick_list: "departments",
            toggle_hint: "Select from list",
            toggle_field: {
              name: "DEPARTMENTID",
              label: "Department ID",
              toggle_hint: "Use custom value",
              control_type: "text",
              type: "string"
            }
          },
          {
            name: "LOCATIONID",
            label: "Location",
            hint: "Required only when an employee is created at the " \
              "top level in a multi-entity, multi-base-currency company.",
            sticky: true,
            control_type: "select",
            pick_list: "locations",
            toggle_hint: "Select from list",
            toggle_field: {
              name: "LOCATIONID",
              label: "Location ID",
              toggle_hint: "Use custom value",
              control_type: "text",
              type: "string"
            }
          },
          {
            name: "CLASSID",
            label: "Class",
            control_type: "select",
            pick_list: "classes",
            toggle_hint: "Select from list",
            toggle_field: {
              name: "CLASSID",
              label: "Class ID",
              toggle_hint: "Use custom value",
              control_type: "text",
              type: "string"
            }
          },
          {
            name: "CURRENCY",
            label: "Currency",
            hint: "Default currency code"
          },
          { name: "EARNINGTYPENAME", label: "Earning type name" },
          {
            name: "POSTACTUALCOST",
            label: "Post actual cost",
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
          { name: "PAYMETHODKEY", label: "Preferred payment method" },
          {
            name: "PAYMENTNOTIFY",
            label: "Payment notify",
            hint: "Send automatic payment notification",
            control_type: "checkbox",
            type: "boolean"
          },
          {
            name: "MERGEPAYMENTREQ",
            label: "Merge payment requests",
            control_type: "checkbox",
            type: "boolean"
          },
          {
            name: "ACHENABLED",
            label: "ACH enabled",
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
          { name: "MODIFIEDBY", label: "Modified by" }
        ]
      }
    },

    employee_get: {
      fields: lambda { |_connection|
        [
          { name: "RECORDNO", label: "Record number", type: "integer" },
          {
            name: "EMPLOYEEID",
            label: "Employee",
            sticky: true,
            control_type: "select",
            pick_list: "employees",
            toggle_hint: "Select from list",
            toggle_field: {
              name: "EMPLOYEEID",
              label: "Employee ID",
              toggle_hint: "Use custom value",
              control_type: "text",
              type: "string"
            }
          },
          {
            name: "PERSONALINFO",
            label: "Personal info",
            hint: "Contact info",
            type: "object",
            properties: [
              { name: "CONTACTNAME", label: "Contact name" },
              { name: "PRINTAS", label: "Print as" },
              { name: "COMPANYNAME", label: "Company name" },
              {
                name: "TAXABLE",
                label: "Taxable",
                control_type: "checkbox",
                type: "boolean"
              },
              {
                name: "TAXGROUP",
                label: "Tax group",
                hint: "Contact tax group name"
              },
              { name: "PREFIX", label: "Prefix" },
              { name: "FIRSTNAME", label: "First name" },
              { name: "LASTNAME", label: "Last name" },
              { name: "INITIAL", label: "Initial", hint: "Middle name" },
              {
                name: "PHONE1",
                label: "Primary phone number",
                control_type: "phone"
              },
              {
                name: "PHONE2",
                label: "Secondary phone number",
                control_type: "phone"
              },
              {
                name: "CELLPHONE",
                label: "Cellphone",
                hint: "Cellular phone number",
                control_type: "phone"
              },
              { name: "PAGER", label: "Pager", hint: "Pager number" },
              { name: "FAX", label: "Fax", hint: "Fax number" },
              {
                name: "EMAIL1",
                label: "Primary email address",
                control_type: "email"
              },
              {
                name: "EMAIL2",
                label: "Secondary email address",
                control_type: "email"
              },
              {
                name: "URL1",
                label: "Primary URL",
                control_type: "url"
              },
              {
                name: "URL2",
                label: "Secondary URL",
                control_type: "url"
              },
              {
                name: "STATUS",
                label: "Status",
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
                name: "MAILADDRESS",
                label: "Mailing information",
                type: "object",
                properties: [
                  { name: "ADDRESS1", label: "Address line 1" },
                  { name: "ADDRESS2", label: "Address line 2" },
                  { name: "CITY", label: "City" },
                  { name: "STATE", label: "State", hint: "State/province" },
                  { name: "ZIP", label: "Zip", hint: "Zip/postal code" },
                  { name: "COUNTRY", label: "Country" }
                ]
              }
            ]
          },
          { name: "STARTDATE", label: "Start date", type: "date" },
          { name: "TITLE", label: "Title" },
          { name: "SSN", label: "Social security number" },
          { name: "EMPLOYEETYPE", label: "Employee type" },
          {
            name: "STATUS",
            label: "Status",
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
          { name: "BIRTHDATE", label: "Birth date", type: "date" },
          { name: "ENDDATE", label: "End date", type: "date" },
          {
            name: "TERMINATIONTYPE",
            label: "Termination type",
            control_type: "select",
            pick_list: "termination_types",
            toggle_hint: "Select from list",
            toggle_field: {
              name: "TERMINATIONTYPE",
              label: "Termination type",
              toggle_hint: "Use custom value",
              control_type: "text",
              type: "string"
            }
          },
          {
            name: "SUPERVISORID",
            label: "Manager",
            control_type: "select",
            pick_list: "employees",
            toggle_hint: "Select from list",
            toggle_field: {
              name: "SUPERVISORID",
              label: "Manager's employee ID",
              toggle_hint: "Use custom value",
              control_type: "text",
              type: "string"
            }
          },
          {
            name: "GENDER",
            label: "Gender",
            control_type: "select",
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
            label: "Department",
            control_type: "select",
            pick_list: "departments",
            toggle_hint: "Select from list",
            toggle_field: {
              name: "DEPARTMENTID",
              label: "Department ID",
              toggle_hint: "Use custom value",
              control_type: "text",
              type: "string"
            }
          },
          {
            name: "LOCATIONID",
            label: "Location",
            hint: "Required only when an employee is created at the " \
              "top level in a multi-entity, multi-base-currency company.",
            sticky: true,
            control_type: "select",
            pick_list: "locations",
            toggle_hint: "Select from list",
            toggle_field: {
              name: "LOCATIONID",
              label: "Location ID",
              toggle_hint: "Use custom value",
              control_type: "text",
              type: "string"
            }
          },
          {
            name: "CLASSID",
            label: "Class",
            control_type: "select",
            pick_list: "classes",
            toggle_hint: "Select from list",
            toggle_field: {
              name: "CLASSID",
              label: "Class ID",
              toggle_hint: "Use custom value",
              control_type: "text",
              type: "string"
            }
          },
          {
            name: "CURRENCY",
            label: "Currency",
            hint: "Default currency code"
          },
          { name: "EARNINGTYPENAME", label: "Earning type name" },
          {
            name: "POSTACTUALCOST",
            label: "Post actual cost",
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
          { name: "PAYMETHODKEY", label: "Preferred payment method" },
          {
            name: "PAYMENTNOTIFY",
            label: "Payment notify",
            hint: "Send automatic payment notification",
            control_type: "checkbox",
            type: "boolean"
          },
          {
            name: "MERGEPAYMENTREQ",
            label: "Merge payment requests",
            control_type: "checkbox",
            type: "boolean"
          },
          {
            name: "ACHENABLED",
            label: "ACH enabled",
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
          { name: "MODIFIEDBY", label: "Modified by" }
        ]
      }
    },

    # Purchase order transaction
    po_txn_header: {
      fields: lambda { |_connection|
        [
          {
            name: "@key",
            label: "Key",
            hint: "Document ID of purchase transaction"
          },
          {
            name: "datecreated",
            label: "Date created",
            hint: "Transaction date",
            type: "date"
          },
          {
            name: "dateposted",
            label: "Date posted",
            hint: "GL posting date",
            type: "date"
          },
          { name: "referenceno", label: "Reference number" },
          { name: "vendordocno", label: "Vendor document number" },
          { name: "termname", label: "Payment term" },
          { name: "datedue", label: "Due date", type: "date" },
          { name: "message" },
          { name: "shippingmethod", label: "Shipping method" },
          {
            name: "returnto",
            label: "Return to contact",
            type: "object",
            properties: [{
              name: "contactname",
              label: "Contact name",
              hit: "Contact name of an existing contact",
              optional: false,
              control_type: "select",
              pick_list: "contact_names",
              toggle_hint: "Select from list",
              toggle_field: {
                name: "contactname",
                label: "Contact name",
                toggle_hint: "Use custom value",
                control_type: "text",
                type: "string"
              }
            }]
          },
          {
            name: "payto",
            label: "Pay to contact",
            type: "object",
            properties: [{
              name: "contactname",
              label: "Contact name",
              hit: "Contact name of an existing contact",
              optional: false,
              control_type: "select",
              pick_list: "contact_names",
              toggle_hint: "Select from list",
              toggle_field: {
                name: "contactname",
                label: "Contact name",
                toggle_hint: "Use custom value",
                control_type: "text",
                type: "string"
              }
            }]
          },
          {
            name: "supdocid",
            label: "Supporting document ID",
            hint: "Attachments ID"
          },
          { name: "externalid", label: "External ID" },
          { name: "basecurr", label: "Base currency code" },
          { name: "currency", hint: "Transaction currency code" },
          { name: "exchratedate", label: "Exchange rate date", type: "date" },
          {
            name: "exchratetype",
            label: "Exchange rate type",
            hint: "Do not use if exchrate is set. " \
              "(Leave blank to use Intacct Daily Rate)"
          },
          {
            name: "exchrate",
            label: "Exchange rate",
            hint: "Do not use if exchangeratetype is set."
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
                    hint: "Integration name of custom field"
                  },
                  {
                    name: "customfieldvalue",
                    label: "Custom field value",
                    hint: "Enter the value of custom field"
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
          {
            name: "@key",
            label: "Key",
            hint: "Document ID of purchase transaction"
          },
          {
            name: "updatepotransitems",
            label: "Transaction items",
            hint: "Array to create new line items",
            type: "array",
            of: "object",
            properties: [
              {
                name: "potransitem",
                label: "Purchase order line items",
                type: "object",
                properties: [
                  { name: "itemid", label: "Item ID" },
                  { name: "itemdesc", label: "Item description" },
                  {
                    name: "taxable",
                    hint: "Customer must be set up for taxable.",
                    control_type: "checkbox",
                    type: "boolean"
                  },
                  {
                    name: "warehouseid",
                    label: "Warehouse",
                    control_type: "select",
                    pick_list: "warehouses",
                    toggle_hint: "Select from list",
                    toggle_field: {
                      name: "warehouseid",
                      label: "Warehouse ID",
                      toggle_hint: "Use custom value",
                      control_type: "text",
                      type: "string"
                    }
                  },
                  { name: "quantity" },
                  { name: "unit", hint: "Unit of measure to base quantity" },
                  { name: "price", control_type: "currency", type: "number" },
                  {
                    name: "sourcelinekey",
                    label: "Source line key",
                    hint: "Source line to convert this line from. Use the" \
                      "RECORDNO of the line from the created from " \
                      "transaction document."
                  },
                  {
                    name: "overridetaxamount",
                    label: "Override tax amount",
                    control_type: "currency",
                    type: "number"
                  },
                  {
                    name: "tax",
                    hint: "Tax amount",
                    control_type: "currency",
                    type: "number"
                  },
                  {
                    name: "locationid",
                    label: "Location",
                    sticky: true,
                    control_type: "select",
                    pick_list: "locations",
                    toggle_hint: "Select from list",
                    toggle_field: {
                      name: "locationid",
                      label: "Location ID",
                      toggle_hint: "Use custom value",
                      control_type: "text",
                      type: "string"
                    }
                  },
                  {
                    name: "departmentid",
                    label: "Department",
                    control_type: "select",
                    pick_list: "departments",
                    toggle_hint: "Select from list",
                    toggle_field: {
                      name: "departmentid",
                      label: "Department ID",
                      toggle_hint: "Use custom value",
                      control_type: "text",
                      type: "string"
                    }
                  },
                  { name: "memo" },
                  # { name: "itemdetails", hint: "Array of item details" },
                  {
                    name: "form1099",
                    hint: "Vendor must be set up for 1099s.",
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
                            hint: "Integration name of custom field"
                          },
                          {
                            name: "customfieldvalue",
                            label: "Custom field value",
                            hint: "Enter the value of custom field"
                          }
                        ]
                      }
                    ]
                  },
                  {
                    name: "projectid",
                    label: "Project",
                    control_type: "select",
                    pick_list: "projects",
                    toggle_hint: "Select from list",
                    toggle_field: {
                      name: "projectid",
                      label: "Project ID",
                      toggle_hint: "Use custom value",
                      control_type: "text",
                      type: "string"
                    }
                  },
                  { name: "customerid" , label: "Customer ID" },
                  { name: "vendorid", label: "Vendor ID" },
                  {
                    name: "employeeid",
                    label: "Employee",
                    control_type: "select",
                    pick_list: "employees",
                    toggle_hint: "Select from list",
                    toggle_field: {
                      name: "employeeid",
                      label: "Employee ID",
                      toggle_hint: "Use custom value",
                      control_type: "text",
                      type: "string"
                    }
                  },
                  {
                    name: "classid",
                    label: "Class",
                    control_type: "select",
                    pick_list: "classes",
                    toggle_hint: "Select from list",
                    toggle_field: {
                      name: "classid",
                      label: "Class ID",
                      toggle_hint: "Use custom value",
                      control_type: "text",
                      type: "string"
                    }
                  },
                  { name: "contractid", label: "Contract ID" },
                  {
                    name: "billable",
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
          {
            name: "@key",
            label: "Key",
            hint: "Document ID of purchase transaction"
          },
          {
            name: "updatepotransitems",
            label: "Transaction items",
            hint: "Array to update the line items",
            optional: false,
            type: "array",
            of: "object",
            properties: [
              {
                name: "updatepotransitem",
                label: "Purchase order line items",
                hint: "Purchase order line items to update",
                type: "object",
                properties: [
                  {
                    name: "@line_num",
                    label: "Line number",
                    type: "integer",
                    optional: false
                  },
                  { name: "itemid", label: "Item ID" },
                  { name: "itemdesc", label: "Item description" },
                  {
                    name: "taxable",
                    hint: "Customer must be set up for taxable.",
                    control_type: "checkbox",
                    type: "boolean"
                  },
                  {
                    name: "warehouseid",
                    label: "Warehouse",
                    control_type: "select",
                    pick_list: "warehouses",
                    toggle_hint: "Select from list",
                    toggle_field: {
                      name: "warehouseid",
                      label: "Warehouse ID",
                      toggle_hint: "Use custom value",
                      control_type: "text",
                      type: "string"
                    }
                  },
                  { name: "quantity" },
                  { name: "unit", hint: "Unit of measure to base quantity" },
                  { name: "price", control_type: "currency", type: "number" },
                  {
                    name: "locationid",
                    label: "Location",
                    sticky: true,
                    control_type: "select",
                    pick_list: "locations",
                    toggle_hint: "Select from list",
                    toggle_field: {
                      name: "locationid",
                      label: "Location ID",
                      toggle_hint: "Use custom value",
                      control_type: "text",
                      type: "string"
                    }
                  },
                  {
                    name: "departmentid",
                    label: "Department",
                    control_type: "select",
                    pick_list: "departments",
                    toggle_hint: "Select from list",
                    toggle_field: {
                      name: "departmentid",
                      label: "Department ID",
                      toggle_hint: "Use custom value",
                      control_type: "text",
                      type: "string"
                    }
                  },
                  { name: "memo" },
                  # { name: "itemdetails", hint: "Array of item details" },
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
                            hint: "Integration name of custom field"
                          },
                          {
                            name: "customfieldvalue",
                            label: "Custom field value",
                            hint: "Enter the value of custom field"
                          }
                        ]
                      }
                    ]
                  },
                  {
                    name: "projectid",
                    label: "Project",
                    control_type: "select",
                    pick_list: "projects",
                    toggle_hint: "Select from list",
                    toggle_field: {
                      name: "projectid",
                      label: "Project ID",
                      toggle_hint: "Use custom value",
                      control_type: "text",
                      type: "string"
                    }
                  },
                  { name: "customerid", label: "Customer ID" },
                  { name: "vendorid", label: "Vendor ID" },
                  {
                    name: "employeeid",
                    label: "Employee",
                    control_type: "select",
                    pick_list: "employees",
                    toggle_hint: "Select from list",
                    toggle_field: {
                      name: "employeeid",
                      label: "Employee ID",
                      toggle_hint: "Use custom value",
                      control_type: "text",
                      type: "string"
                    }
                  },
                  {
                    name: "classid",
                    label: "Class",
                    control_type: "select",
                    pick_list: "classes",
                    toggle_hint: "Select from list",
                    toggle_field: {
                      name: "classid",
                      label: "Class ID",
                      toggle_hint: "Use custom value",
                      control_type: "text",
                      type: "string"
                    }
                  },
                  { name: "contractid", label: "Contract ID" },
                  {
                    name: "billable",
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
    supdoc_create: {
      fields: lambda { |_connection|
        [{
          name: "attachment",
          optional: false,
          type: "object",
          properties: [
            {
              name: "supdocid",
              label: "Supporting document ID",
              hint: "Required if company does not have " \
                "attachment autonumbering configured.",
              sticky: true
            },
            {
              name: "supdocname",
              label: "Supporting document name",
              hint: "Name of attachment",
              optional: false
            },
            {
              name: "supdocfoldername",
              label: "Folder name",
              hint: "Attachments folder name",
              optional: false
            },
            { name: "supdocdescription", label: "Attachment description" },
            {
              name: "attachments",
              hint: "Zero to many attachments",
              sticky: true,
              type: "array",
              of: "object",
              properties: [{
                name: "attachment",
                sticky: true,
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
              }]
            }
          ]
        }]
      }
    },

    supdoc_get: {
      fields: lambda { |_connection|
        [
          {
            name: "supdocid",
            label: "Supporting document ID",
            hint: "Required if company does not have " \
              "attachment autonumbering configured.",
            sticky: true
          },
          {
            name: "supdocname",
            label: "Supporting document name",
            hint: "Name of attachment"
          },
          {
            name: "folder",
            label: "Folder name",
            hint: "Attachment folder name"
          },
          { name: "description", label: "Attachment description" },
          {
            name: "supdocfoldername",
            label: "Folder name",
            hint: "Attachments folder name"
          },
          { name: "supdocdescription", label: "Attachment description" },
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
            hint: "Attachment folder name"
          },
          { name: "description",label: "Folder description" },
          {
            name: "parentfolder",
            label: "Parent folder name",
            hint: "Parent attachment folder"
          },
          {
            name: "supdocfoldername",
            label: "Folder name",
            hint: "Attachment folder name"
          },
          { name: "supdocfolderdescription", label: "Folder description" },
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
      input.map do |key, value|
        if key == "content!"
          value
        else
          value = value&.first if value.is_a?(Array)
          { key => call("parse_nested_elements", value) } if value != {}
        end
      end&.compact.inject(:merge)
    }
  },

  actions: {
    # Attachment related actions
    create_attachments: {
      subtitle: "Create attachments",
      description: "Create <span class='provider'>attachments</span> in " \
        "<span class='provider'>Intacct</span>",

      execute: lambda { |_connection, input|
        payload = {
          "content" => {
            "function" => {
              "@controlid" => "testControlId",
              "create_supdoc" => input["attachment"]
            }
          }
        }
        attachment_response = post("/ia/xml/xmlgw.phtml", payload).
                              dig("response", 0, "operation", 0,
                                  "result", 0) || {}
        call("parse_nested_elements", attachment_response)
      },

      input_fields: lambda { |object_definitions|
        object_definitions["supdoc_create"]
      },

      output_fields: ->(object_definitions) { object_definitions["result"] }
    },

    get_attachment: {
      subtitle: "Get attachment",
      description: "Get <span class='provider'>attachment</span> in " \
        "<span class='provider'>Intacct</span>",

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
        attachment_response = post("/ia/xml/xmlgw.phtml", payload).
                              dig("response", 0, "operation", 0, "result", 0,
                                  "data", 0, "supdoc", 0) || {}
        call("parse_nested_elements", attachment_response)
      },

      input_fields: lambda { |_object_definitions|
        [{ name: "key", label: "Supporting document ID", optional: false }]
      },

      output_fields: lambda { |object_definitions|
        object_definitions["supdoc_get"].
          ignored("supdocfoldername", "supdocdescription")
      }
    },

    update_attachment: {
      subtitle: "Update attachment",
      description: "Update <span class='provider'>attachment</span> in " \
        "<span class='>Intacct</span>",

      execute: lambda { |_connection, input|
        payload = {
          "content" => {
            "function" => {
              "@controlid" => "testControlId",
              "update_supdoc" => input
            }
          }
        }
        attachment_response = post("/ia/xml/xmlgw.phtml", payload).
                              dig("response", 0, "operation", 0,
                                  "result", 0) || {}
        call("parse_nested_elements", attachment_response)
      },

      input_fields: lambda { |object_definitions|
        object_definitions["supdoc_get"].
          ignored("creationdate", "createdby", "lastmodified",
                  "lastmodifiedby", "folder", "description").
          required("supdocid")
      },

      output_fields: ->(object_definitions) { object_definitions["result"] }
    },

    # Attachment folder related actions
    create_attachment_folder: {
      subtitle: "Create attachment folder",
      description: "Create <span class='provider'>attachment folder</span> " \
         "in <span class='provider'>Intacct</span>",

      execute: lambda { |_connection, input|
        payload = {
          "content" => {
            "function" => {
              "@controlid" => "testControlId",
              "create_supdocfolder" => input
            }
          }
        }
        folder_response = post("/ia/xml/xmlgw.phtml", payload).
                          dig("response", 0, "operation", 0, "result", 0) || {}
        call("parse_nested_elements", folder_response)
      },

     input_fields: lambda { |object_definitions|
       object_definitions["supdocfolder"].
         ignored("creationdate", "createdby", "lastmodified",
                 "lastmodifiedby", "name", "description", "parentfolder").
         required("supdocfoldername")
     },

      output_fields: ->(object_definitions) { object_definitions["result"] }
    },

    get_attachment_folder: {
      subtitle: "Get attachment folder",
      description: "Get <span class='provider'>attachment_folder</span> in " \
        "<span class='provider'>Intacct</span>",

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
        attachment_folder_response = post("/ia/xml/xmlgw.phtml", payload).
                                     dig("response", 0, "operation", 0,
                                         "result", 0, "data", 0,
                                         "supdocfolder", 0) || {}
        call("parse_nested_elements", attachment_folder_response)
      },

      input_fields: lambda { |_object_definitions|
        [{ name: "key", label: "Folder name", optional: false }]
      },

      output_fields: lambda { |object_definitions|
        object_definitions["supdocfolder"].
          ignored("supdocfoldername", "supdocfolderdescription",
                  "supdocparentfoldername")
      }
    },

    update_attachment_folder: {
      subtitle: "Update attachment folder",
      description: "Update <span class='provider'>attachment folder</span> " \
        "in <span class='provider'>Intacct</span>",

      execute: lambda { |_connection, input|
        payload = {
          "content" => {
            "function" => {
              "@controlid" => "testControlId",
              "update_supdocfolder" => input
            }
          }
        }
        folder_response = post("/ia/xml/xmlgw.phtml", payload).
                          dig("response", 0, "operation", 0, "result", 0) || {}
        call("parse_nested_elements", folder_response)
      },

      input_fields: lambda { |object_definitions|
        object_definitions["supdocfolder"].
          ignored("creationdate", "createdby", "lastmodified",
                  "lastmodifiedby", "name", "description", "parentfolder").
          required("supdocfoldername")
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
        api_response = post("/ia/xml/xmlgw.phtml", payload).
                       dig("response", 0, "operation", 0, "result", 0) || {}
        call("parse_nested_elements", api_response)
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

      execute: lambda { |_connection, input|
        payload = {
          "content" => {
            "function" => {
              "@controlid" => "testControlId",
              "create" => { "EMPLOYEE" => input }
            }
          }
        }
        employee_response = post("/ia/xml/xmlgw.phtml", payload).
                            dig("response", 0, "operation", 0, "result", 0,
                                "data", 0, "employee", 0) || {}
        call("parse_nested_elements", employee_response)
      },

      input_fields: lambda { |object_definitions|
        object_definitions["employee_create"].
          ignored("RECORDNO", "CREATEDBY", "MODIFIEDBY", "WHENCREATED",
                  "WHENMODIFIED")
      },

      output_fields: lambda { |object_definitions|
        object_definitions["employee_get"].only("RECORDNO", "EMPLOYEEID")
      }
    },

    get_employee: {
      subtitle: "Get employee",
      description: "Get <span class='provider'>employee</span> in " \
        "<span class='provider'>Intacct</span>",

      execute: lambda { |_connection, input|
        payload = {
          "content" => {
            "function" => {
              "@controlid" => "testControlId",
              "read" => {
                "object" => "EMPLOYEE",
                "keys" => input["RECORDNO"],
                "fields" => "*"
              }
            }
          }
        }
        employee_response = post("/ia/xml/xmlgw.phtml", payload).
                            dig("response", 0, "operation", 0, "result", 0,
                                "data", 0, "EMPLOYEE", 0) || {}
        call("parse_nested_elements", employee_response)
      },

      input_fields: lambda { |object_definitions|
        object_definitions["employee_get"].
          only("RECORDNO").
          required("RECORDNO")
      },

      output_fields: lambda { |object_definitions|
        object_definitions["employee_get"]
      }
    },

    update_employee: {
      subtitle: "Update employee",
      description: "Update <span class='provider'>employee</span> in " \
        "<span class='provider'>Intacct</span>",

      execute: lambda { |_connection, input|
        payload = {
          "content" => {
            "function" => {
              "@controlid" => "testControlId",
              "update" => { "EMPLOYEE" => input }
            }
          }
        }
        employee_response = post("/ia/xml/xmlgw.phtml", payload).
                            dig("response", 0, "operation", 0, "result", 0,
                                "data", 0, "employee", 0) || {}
        call("parse_nested_elements", employee_response)
      },

      input_fields: lambda { |object_definitions|
        object_definitions["employee_get"].
          ignored("CREATEDBY", "MODIFIEDBY", "WHENCREATED", "WHENMODIFIED").
          required("RECORDNO")
      },

      output_fields: lambda { |object_definitions|
        object_definitions["employee_get"].only("RECORDNO", "EMPLOYEEID")
      }
    },

    # Purchase Order Transaction related actions
    update_purchase_transaction_header: {
      subtitle: "Update purchase transaction header",
      description: "Update <span class='provider'>purchase transaction " \
        "header</span> in <span class='provider'>Intacct</span>",
      help: "Pay special attention to map the data pills in the same order " \
        "as you see in the input list, for the action to be successful!",

      execute: lambda { |_connection, input|
        build_date_object = lambda { |raw_date|
          {
            "year" => raw_date.to_date.strftime("%Y"),
            "month" => raw_date.to_date.strftime("%m"),
            "day" => raw_date.to_date.strftime("%d")
          }
        }

        input["datecreated"] = (raw_date = input["datecreated"].presence) &&
                               build_date_object[raw_date]
        input["dateposted"] = (raw_date = input["dateposted"].presence) &&
                              build_date_object[raw_date]
        input["datedue"] = (raw_date = input["datedue"].presence) &&
                           build_date_object[raw_date]
        input["exchratedate"] = (raw_date = input["exchratedate"].presence) &&
                                build_date_object[raw_date]
        payload = {
          "content" => {
            "function" => {
              "@controlid" => "testControlId",
              "update_potransaction" =>  input&.compact
            }
          }
        }
        po_txn_response = post("/ia/xml/xmlgw.phtml", payload).
                          dig("response", 0, "operation", 0, "result", 0) || {}
        call("parse_nested_elements", po_txn_response)
      },

      input_fields: lambda { |object_definitions|
        object_definitions["po_txn_header"].required("@key")
      },

      output_fields: ->(object_definitions) { object_definitions["result"] }
    },

    add_purchase_transaction_items: {
      subtitle: "Add purchase transaction items",
      description: "Add <span class='provider'>purchase transaction " \
        "items</span> in <span class='provider'>Intacct</span>",
      help: "Pay special attention to map the data pills in the same order " \
        "as you see in the input list, to run the action successfully!",

      execute: lambda { |_connection, input|
        payload = {
          "content" => {
            "function" => {
              "@controlid" => "testControlId",
              "update_potransaction" =>  input
            }
          }
        }
        po_txn_response = post("/ia/xml/xmlgw.phtml", payload).
                          dig("response", 0, "operation", 0, "result", 0) || {}
        call("parse_nested_elements", po_txn_response)
      },

      input_fields: lambda { |object_definitions|
        object_definitions["po_txn_transitem"].required("@key")
      },

      output_fields: ->(object_definitions) { object_definitions["result"] }
    },

    update_purchase_transaction_items: {
      subtitle: "Update purchase transaction items",
      description: "Update <span class='provider'>purchase transaction " \
        "items</span> in <span class='provider'>Intacct</span>",
      help: "Pay special attention to map the data pills in the same order " \
        "as you see in the input list, for the action to be successful!",

      execute: lambda { |_connection, input|
        payload = {
          "content" => {
            "function" => {
              "@controlid" => "testControlId",
              "update_potransaction" =>  input
            }
          }
        }
        po_txn_response = post("/ia/xml/xmlgw.phtml", payload).
                          dig("response", 0, "operation", 0, "result", 0) || {}
        call("parse_nested_elements", po_txn_response)
      },

      input_fields: lambda { |object_definitions|
        object_definitions["po_txn_updatepotransitem"].required("@key")
      },

      output_fields: ->(object_definitions) { object_definitions["result"] }
    }
  },

  pick_lists: {
    classes: lambda { |_connection|
      payload = {
        "content" => {
          "function" => {
            "@controlid" => "testControlId",
            "readByQuery" => {
              "object" => "CLASS",
              "fields" => "NAME, CLASSID",
              "query" => "STATUS = 'T'",
              "pagesize" => "1000"
            }
          }
        }
      }
      class_response = post("/ia/xml/xmlgw.phtml", payload).
                            dig("response", 0, "operation", 0, "result", 0,
                                "data", 0, "class") || []

      class_response.map do |value|
        class_var = call("parse_nested_elements", value)
        [class_var["NAME"], class_var["CLASSID"]]
      end
    },

    contact_names: lambda { |_connection|
      payload = {
        "content" => {
          "function" => {
            "@controlid" => "testControlId",
            "readByQuery" => {
              "object" => "CONTACT",
              "fields" => "RECORDNO, CONTACTNAME",
              "query" => "STATUS = 'T'",
              "pagesize" => "1000"
            }
          }
        }
      }
      contact_response = post("/ia/xml/xmlgw.phtml", payload).
                         dig("response", 0, "operation", 0, "result", 0,
                             "data", 0, "contact") || []

      contact_response.map do |value|
        contact = call("parse_nested_elements", value)
        [contact["CONTACTNAME"], contact["CONTACTNAME"]]
      end
    },

    departments: lambda { |_connection|
      payload = {
        "content" => {
          "function" => {
            "@controlid" => "testControlId",
            "readByQuery" => {
              "object" => "DEPARTMENT",
              "fields" => "TITLE, DEPARTMENTID",
              "query" => "STATUS = 'T'",
              "pagesize" => "1000"
            }
          }
        }
      }
      department_response = post("/ia/xml/xmlgw.phtml", payload).
                            dig("response", 0, "operation", 0, "result", 0,
                                "data", 0, "department") || []

      department_response.map do |value|
        department = call("parse_nested_elements", value)
        [department["TITLE"], department["DEPARTMENTID"]]
      end
    },

    employees: lambda { |_connection|
      payload = {
        "content" => {
          "function" => {
            "@controlid" => "testControlId",
            "readByQuery" => {
              "object" => "EMPLOYEE",
              "fields" => "TITLE, EMPLOYEEID",
              "query" => "STATUS = 'T'",
              "pagesize" => "1000"
            }
          }
        }
      }
      employee_response = post("/ia/xml/xmlgw.phtml", payload).
                          dig("response", 0, "operation", 0, "result", 0,
                              "data", 0, "employee") || []

      employee_response.map do |value|
        employee = call("parse_nested_elements", value)
        [employee["TITLE"], employee["EMPLOYEEID"]]
      end
    },

    genders: ->(_connection) { [%w[Male male], %w[Female female]] },

    locations: lambda { |_connection|
      payload = {
        "content" => {
          "function" => {
            "@controlid" => "testControlId",
            "readByQuery" => {
              "object" => "LOCATION",
              "fields" => "NAME, LOCATIONID",
              "query" => "STATUS = 'T'",
              "pagesize" => "1000"
            }
          }
        }
      }
      location_response = post("/ia/xml/xmlgw.phtml", payload).
                          dig("response", 0, "operation", 0, "result", 0,
                              "data", 0, "location") || []

      location_response.map do |value|
        location = call("parse_nested_elements", value)
        [location["NAME"], location["LOCATIONID"]]
      end
    },

    projects: lambda { |_connection|
      payload = {
        "content" => {
          "function" => {
            "@controlid" => "testControlId",
            "readByQuery" => {
              "object" => "PROJECT",
              "fields" => "NAME, PROJECTID",
              "query" => "STATUS = 'T'",
              "pagesize" => "1000"
            }
          }
        }
      }
      project_response = post("/ia/xml/xmlgw.phtml", payload).
                         dig("response", 0, "operation", 0, "result", 0,
                             "data", 0, "project") || []

      project_response.map do |value|
        project = call("parse_nested_elements", value)
        [project["NAME"], project["PROJECTID"]]
      end
    },

    statuses: ->(_connection) { [%w[Active active], %w[Inactive inactive]] },

    termination_types: lambda { |_connection|
      [%w[Voluntary voluntary], %w[Involuntary involuntary],
       %w[Deceased deceased], %w[Disability disability],
       %w[Retired retired]]
    },

    warehouses: lambda { |_connection|
      payload = {
        "content" => {
          "function" => {
            "@controlid" => "testControlId",
            "readByQuery" => {
              "object" => "WAREHOUSE",
              "fields" => "NAME, WAREHOUSEID",
              "query" => "STATUS = 'T'",
              "pagesize" => "1000"
            }
          }
        }
      }
      warehouse_response = post("/ia/xml/xmlgw.phtml", payload).
                           dig("response", 0, "operation", 0, "result", 0,
                               "data", 0, "warehouse") || []

      warehouse_response.map do |value|
        warehouse = call("parse_nested_elements", value)
        [warehouse["NAME"], warehouse["WAREHOUSEID"]]
      end
    }
  }
}
