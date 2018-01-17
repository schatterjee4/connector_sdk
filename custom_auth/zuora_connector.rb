
{
  title: "Zuora",

  connection: {
    fields: [
      {
        name: "client_id",
        hint: "Find more information " \
        "<a href='https://knowledgecenter.zuora.com/" \
        "CF_Users_and_Administrators/A_Administrator_Settings/Manage_Users" \
        "#Create_an_OAuth_Client_for_a_User'>here</a>",
        optional: false
      },
      {
        name: "client_secret",
        hint: "Find more information " \
        "<a href='https://knowledgecenter.zuora.com/" \
        "CF_Users_and_Administrators/A_Administrator_Settings/Manage_Users" \
        "#Create_an_OAuth_Client_for_a_User'>here</a>",
        optional: false,
        control_type: "password"
      },
      {
        name: "environment",
        hint: "Find more information <a href='https://jp.zuora.com" \
        "/api-reference/#section/Introduction/Endpoints' " \
        "target='_blank'>here</a>",
        control_type: "select",
        pick_list: [
          ["US Production", "rest"],
          ["US Sandbox", "rest.apisandbox"],
          ["US Performance Test", "rest.pt1"],
          ["EU Production", "rest.eu"],
          ["EU Sandbox", "rest.sandbox.eu"]
        ],
        optional: false
      }
    ],

    authorization: {
      type: "custom_auth",

      acquire: lambda { |connection|
        {
          auth_token: post("https://#{connection['environment']}.zuora.com" \
                           "/oauth/token").
          payload(client_id: connection["client_id"],
                  client_secret: connection["client_secret"],
                  grant_type: "client_credentials").
          request_format_www_form_urlencoded.
          dig("access_token")
        }
      },

      refresh_on: [401],

      detect_on: [/"Success"\S*\:\s*false/],

      apply: lambda { |connection|
        headers("Authorization": "Bearer #{connection['auth_token']}")
      }
    },

    base_uri: lambda { |connection|
      "https://#{connection['environment']}.zuora.com"
    }
  },

  test: lambda { |_connection|
    post("/v1/connections")
  },

  object_definitions: {
    customer_account_get: {
      fields: lambda {
        [
          {
            name: "basicInfo",
            type: "object",
            properties: [
              { name: "id" },
              { name: "name" },
              { name: "accountNumber" },
              { name: "notes" },
              { name: "status" },
              { name: "crmId" },
              { name: "batch" },
              { name: "invoiceTemplateId" },
              { name: "communicationProfileId" },
              { name: "salesRep" },
              { name: "parentId" }
            ]
          },
          {
            name: "billingAndPayment",
            type: "object",
            properties: [
              { name: "billCycleDay" },
              { name: "currency" },
              { name: "paymentTerm" },
              { name: "paymentGateway" },
              { name: "invoiceDeliveryPrefsPrint" },
              { name: "invoiceDeliveryPrefsEmail" },
              { name: "additionalEmailAddresses" }
            ]
          },
          {
            name: "metrics",
            type: "object",
            properties: [
              { name: "balance" },
              { name: "totalInvoiceBalance" },
              { name: "creditBalance" },
              { name: "contractedMrr" }
            ]
          },
          {
            name: "billToContact",
            type: "object",
            properties: [
              { name: "address1" },
              { name: "address2" },
              { name: "city" },
              { name: "country" },
              { name: "county" },
              { name: "fax" },
              { name: "firstName" },
              { name: "homePhone", control_type: "phone" },
              { name: "lastName" },
              { name: "mobilePhone", control_type: "phone" },
              { name: "nickname" },
              { name: "otherPhone", control_type: "phone" },
              { name: "otherPhoneType" },
              { name: "personalEmail", control_type: "email" },
              { name: "state" },
              { name: "taxRegion" },
              { name: "workEmail", control_type: "email" },
              { name: "workPhone", control_type: "phone" },
              { name: "zipCode" }
            ]
          },
          {
            name: "soldToContact",
            type: "object",
            properties: [
              { name: "address1" },
              { name: "address2" },
              { name: "city" },
              { name: "country" },
              { name: "county" },
              { name: "fax" },
              { name: "firstName" },
              { name: "homePhone", control_type: "phone" },
              { name: "lastName" },
              { name: "mobilePhone", control_type: "phone" },
              { name: "nickname" },
              { name: "otherPhone" },
              { name: "otherPhoneType" },
              { name: "personalEmail", control_type: "email" },
              { name: "state" },
              { name: "taxRegion" },
              { name: "workEmail", control_type: "email" },
              { name: "workPhone", control_type: "phone" },
              { name: "zipCode" }
            ]
          },
          {
            name: "taxInfo",
            type: "object",
            properties: [
              { name: "exemptStatus" },
              { name: "exemptCertificateId" },
              { name: "exemptCertificateType" },
              { name: "exemptIssuingJurisdiction" },
              { name: "exemptEffectiveDate", type: "date" },
              { name: "exemptExpirationDate", type: "date" },
              { name: "exemptDescription" },
              { name: "companyCode" },
              { name: "VATId" }
            ]
          }
        ]
      }
    },

    customer_account: {
      fields: lambda {
        [
          { name: "batch" },
          { name: "name" },
          { name: "currency" },
          { name: "notes" },
          { name: "billCycleDay", type: "integer", hint: "Specify any day of the month (1-31, where 31 = end-of-month), or 0" },
          { name: "autoPay", type: "boolean", control_type: "checkbox" },
          { name: "crmId" },
          { name: "invoiceTemplateId" },
          { name: "communicationProfileId" },
          { name: "paymentGateway" },
          { name: "paymentTerm" },
          {
            name: "billToContact",
            type: "object",
            properties: [
              { name: "address1" },
              { name: "address2" },
              { name: "city" },
              { name: "country" },
              { name: "firstName", sticky: true },
              { name: "lastName", sticky: true },
              { name: "zipCode" },
              { name: "state" },
              { name: "workEmail", control_type: "email" }
            ]
          },
          {
            name: "soldToContact",
            type: "object",
            properties: [
              { name: "address1" },
              { name: "address2" },
              { name: "city" },
              { name: "country", sticky: true },
              { name: "firstName", sticky: true },
              { name: "lastName", sticky: true },
              { name: "zipCode" },
              { name: "state" },
              { name: "workEmail", control_type: "email" }
            ]
          },
          { name: "hpmCreditCardPaymentMethodId", sticky: true,
            hint: "The ID of the HPM credit card payment method associated with this account.
              You must provide either this field or the creditCard structure, but not both." },
          {
            name: "creditCard",
            type: "object",
            hint: " You must provide either this structure or the <code>hpmCreditCardPaymentMethodId</code> field, but not both.",
            properties: [
              { name: "cardType", sticky: true,
                hint: "Possible values are:<code> Visa, MasterCard, \
                 AmericanExpress, Discover.</code>" },
              { name: "cardNumber", sticky: true,
                hint: "Card number, up to 16 characters." },
              { name: "expirationMonth", sticky: true,
                hint: "Two-digit expiration month (01-12)" },
              { name: "expirationYear", sticky: true,
                hint: "Four-digit expiration year" },
              { name: "securityCode",
                hint: "The CVV or CVV2 security code of the card." },
              { name: "cardHolderInfo",
                hint: "If provided, Zuora will only use this information for this card"},
              { name: "cardHolderName",
                hint: "The card holder's full name as it appears on the card, e.g., <code>'J Smith'</code>"}
            ]
          },
          {
            name: "subscription",
            type: "object",
            properties: [
              { name: "subscriptionNumber" },
              { name: "invoiceOwnerAccountKey", hint: "Invoice owner account number or ID" },
              { name: "termType", sticky: true,
                hint: "Possible values are: <code>TERMED, EVERGREEN</code>." },
              { name: "contractEffectiveDate", type: "date" },
              { name: "serviceActivationDate", type: "date" },
              { name: "customerAcceptanceDate", type: "date" },
              { name: "termStartDate", type: "date" },
              { name: "initialTerm", type: "integer",
                hint: "Duration of the initial subscription term in whole months.  Default is 0." },
              { name: "renewalTerm", type: "integer",
                hint: "Duration of the renewal term in whole months. Default is 0." },
              { name: "autoRenew", type: "boolean", control_type: "checkbox" },
              {
                name: "subscribeToRatePlans",
                type: "array",
                of: "object",
                properties: [
                  { name: "productRatePlanId", sticky: true },
                  {
                    name: "chargeOverrides",
                    type: "array",
                    of: "object",
                    properties: [
                      { name: "productRatePlanChargeId" },
                      { name: "quantity", type: "integer"}
                    ]
                  }
                ]
              },
              { name: "invoiceCollect", type: "boolean", control_type: "checkbox" },
              { name: "invoice", type: "boolean", control_type: "checkbox" },
              { name: "collect", type: "boolean", control_type: "checkbox",
                hint: "Prerequisite: invoice must be true" },
              { name: "invoiceSeparately", type: "boolean", control_type: "checkbox" },
              { name: "applyCreditBalance", type: "boolean", control_type: "checkbox" },
              { name: "invoiceTargetDate", type: "date",
                hint: "If invoiceCollect is true, the target date for the invoice." }
            ]
          },
          { name: "taxInfo", type: "object", properties: [
              { name: "companyCode" },
              { name: "exemptCertificateId", hint: "ID of the customer tax exemption certificate." },
              { name: "exemptCertificateType" },
              { name: "exemptDescription" },
              { name: "exemptEffectiveDate", type: "date" },
              { name: "exemptExpirationDate", type: "date" },
              { name: "exemptIssuingJurisdiction" },
              { name: "exemptStatus", hint: "Values: <code> Yes, No, pendingVerification </code>"},
              { name: "VATId", hint: "EU Value Added Tax ID. This feature is in Limited Availability"}

          ] }

        ]
      }
    },
    contact: {
      fields: lambda do
        [
          { name: "address1" },
          { name: "address2" },
          { name: "city" },
          { name: "state" },
          { name: "country", hint: "Country; must be a valid country name or abbreviation." },
          { name: "county" },
          { name: "zipCode" },
          { name: "taxRegion" },
          { name: "firstName" },
          { name: "lastName" },
          { name: "nickname" },
          { name: "homePhone", control_type: "phone" },
          { name: "mobilePhone", control_type: "phone" },
          { name: "otherPhone", control_type: "phone" },
          { name: "fax" },
          { name: "otherPhoneType", hint: "Possible values are: <code>Work, Mobile, Home, Other</code>." },
          { name: "personalEmail", control_type: "email" },
          { name: "workEmail", control_type: "email" },
          { name: "workPhone", control_type: "phone" }
        ]
      end
    },
    account_response: {
      fields: lambda do
        [
          { name: "success", type: "boolean" },
          { name: "processId", hint: "Only returned if success is false."},
          { name: "reasons", type: "array", of: "object", properties: [
              { name: "code" },
              { name: "message" }
          ] },
          { name: "accountId" },
          { name: "accountNumber" },
          { name: "paymentMethodId" },
          { name: "subscriptionId" },
          { name: "subscriptionNumber" },
          { name: "invoiceId" },
          { name: "paymentId" },
          { name: "paidAmount" },
          { name: "contractedMrr" },
          { name: "totalContractedValue" },
          { name: "companyCode" },
          { name: "exemptCertificateId" },
          { name: "exemptCertificateType" },
          { name: "exemptDescription" },
          { name: "exemptEffectiveDate", type: "date" },
          { name: "exemptExpirationDate", type: "date" },
          { name: "exemptIssuingJurisdiction" },
          { name: "exemptStatus" },
          { name: "VATId" }
        ]
      end
    },
    object_output: {
      fields: lambda do |_connection, config|
        metadata = get("/v1/describe/#{config['object_name']}").response_format_xml.dig("object", 0, "fields", 0, "field")
        fields = metadata.select{|field| field.dig("selectable", 0, "content!") == "true"}.map do |o|
          #if o.dig("selectable", 0, "content!") == "true"
            case o.dig("type", 0, "content!")
            when "decimal"
              { name: o.dig("name", 0, "content!"), type: "integer",
                optional: o.dig("required", 0, "content!").include?("false"),
                label:  o.dig("label", 0, "content!")}
            when "int"
              { name: o.dig("name", 0, "content!"), type: "integer",
               optional: o.dig("required", 0, "content!").include?("false"),
                label:  o.dig("label", 0, "content!")}
            when "text"
              { name: o.dig("name", 0, "content!"), type: "string",
                optional: o.dig("required", 0, "content!").include?("false"),
                label:  o.dig("label", 0, "content!")}
            when "picklist"
              { name: o.dig("name", 0, "content!"), type: "string",
                optional: o.dig("required", 0, "content!").include?("false"),
                label:  o.dig("label", 0, "content!")}
            when "string"
              { name: o.dig("name", 0, "content!"), type: "string",
               optional: o.dig("required", 0, "content!").include?("false"),
                label:  o.dig("label", 0, "content!")}
            when "boolean"
              { name: o.dig("name", 0, "content!"), type: "boolean",
               optional: o.dig("required", 0, "content!").include?("false"),
                label:  o.dig("label", 0, "content!")}
            when "datetime"
              { name: o.dig("name", 0, "content!"), type: "date_time",
               optional: o.dig("required", 0, "content!").include?("false"),
                label:  o.dig("label", 0, "content!")}
            when "date"
              { name: o.dig("name", 0, "content!"), type: "date",
                optional: o.dig("required", 0, "content!").include?("false"),
                label:  o.dig("label", 0, "content!")}
            else
              { name: o.dig("name", 0, "content!"), type: "string",
               optional: o.dig("required", 0, "content!").include?("false"),
                label:  o.dig("label", 0, "content!")}
            end
          end
       # end
        fields.compact
      end
    },
    create_object: {
      fields: lambda do |connection, config|
        metadata = get("/v1/describe/#{config['object_name']}").response_format_xml.dig("object", 0, "fields", 0, "field")
        object  = metadata.select{|field| field.dig("createable", 0, "content!") == "true"}.map do |o|
            case o.dig("type", 0, "content!")
            when "decimal"
              { name: o.dig("name", 0, "content!"), type: "integer",
                optional: o.dig("required", 0, "content!").include?("false"),
                label:  o.dig("label", 0, "content!")}
            when "int"
              { name: o.dig("name", 0, "content!"), type: "integer",
                optional: o.dig("required", 0, "content!").include?("false"),
                label:  o.dig("label", 0, "content!")}
            when "text"
              { name: o.dig("name", 0, "content!"), type: "string",
                optional: o.dig("required", 0, "content!").include?("false"),
                label:  o.dig("label", 0, "content!")}
            when "string"
              { name: o.dig("name", 0, "content!"), type: "string",
                optional: o.dig("required", 0, "content!").include?("false"),
                label:  o.dig("label", 0, "content!")}
            when "boolean"
              { name: o.dig("name", 0, "content!"), type: "boolean",
                optional: o.dig("required", 0, "content!").include?("false"),
                control_type: "checkbox",
                label:  o.dig("label", 0, "content!"),
                toggle_hint: "Select from list",
                toggle_field: {
                  name: o.dig("name", 0, "content!"),
                  label: o.dig("label", 0, "content!"),
                  type: :string,
                  control_type: "text",
                  optional: false,
                  toggle_hint: "Use custom value",
                  }}
            when "datetime"
              { name: o.dig("name", 0, "content!"), type: "date_time",
                optional: o.dig("required", 0, "content!").include?("false"),
                label:  o.dig("label", 0, "content!")}
            when "date"
              { name: o.dig("name", 0, "content!"), type: "date",
                optional: o.dig("required", 0, "content!").include?("false"),
                label:  o.dig("label", 0, "content!")}
            when "picklist"
              list = o.dig("options", 0, "option").map do |option|
                [ option.dig("content!"), option.dig("content!")]
              end
              { name: o.dig("name", 0, "content!"),
                control_type: "select",
                optional: o.dig("required", 0, "content!").include?("false"),
                pick_list: list,
                label:  o.dig("label", 0, "content!"),
                toggle_hint: "Select from list",
                toggle_field: {
                  name: o.dig("name", 0, "content!"),
                  label: o.dig("label", 0, "content!"),
                  type: :string,
                  control_type: "text",
                  optional: false,
                  toggle_hint: "Use custom value",
                }}
            else
              o.dig("type", 0, "content!") == "text"
              { name: o.dig("name", 0, "content!"), type: "string",
                optional: o.dig("required", 0, "content!").include?("false"),
                label:  o.dig("label", 0, "content!")}
            end
         # end
        end
       object.compact
      end
    },
    update_object: {
      fields: lambda do |_connection, config|
        metadata = get("/v1/describe/#{config['object_name']}").response_format_xml.dig("object", 0, "fields", 0, "field")
        object = metadata.select{|field| field.dig("updateable", 0, "content!") == "true"}.map do |o|
            case o.dig("type", 0, "content!")
            when "decimal"
              { name: o.dig("name", 0, "content!"), type: "integer",
                optional: o.dig("required", 0, "content!").include?("false"),
                label:  o.dig("label", 0, "content!")}
            when "int"
              { name: o.dig("name", 0, "content!"), type: "integer",
                optional: o.dig("required", 0, "content!").include?("false"),
                label:  o.dig("label", 0, "content!")}
            when "text"
              { name: o.dig("name", 0, "content!"), type: "string",
                optional: o.dig("required", 0, "content!").include?("false"),
                label:  o.dig("label", 0, "content!")}
            when "string"
              { name: o.dig("name", 0, "content!"), type: "string",
                optional: o.dig("required", 0, "content!").include?("false"),
                label:  o.dig("label", 0, "content!")}
            when "boolean"
              { name: o.dig("name", 0, "content!"), type: "boolean",
                optional: o.dig("required", 0, "content!").include?("false"),
                label:  o.dig("label", 0, "content!"),
                control_type: "checkbox",
                toggle_hint: "Select from list",
                toggle_field: {
                  name: o.dig("name", 0, "content!"),
                  label: o.dig("label", 0, "content!"),
                  type: :string,
                  control_type: "text",
                  optional: false,
                  toggle_hint: "Use custom value",
                }}
            when "datetime"
              { name: o.dig("name", 0, "content!"), type: "date_time",
                optional: o.dig("required", 0, "content!").include?("false"),
                label:  o.dig("label", 0, "content!")}
            when "date"
              { name: o.dig("name", 0, "content!"), type: "date",
                optional: o.dig("required", 0, "content!").include?("false"),
                label:  o.dig("label", 0, "content!")}
            when "picklist"
              list = o.dig("options", 0, "option").map do |option|
                [ option.dig("content!"), option.dig("content!")]
              end
              list.reject { |el| el.blank? }
              { name: o.dig("name", 0, "content!"), type: "select",
                optional: o.dig("required", 0, "content!").include?("false"),
                picklist: list,
                label:  o.dig("label", 0, "content!")}
            else
              o.dig("type", 0, "content!") == "text"
              { name: o.dig("name", 0, "content!"), type: "string",
                optional: o.dig("required", 0, "content!").include?("false"),
                label:  o.dig("label", 0, "content!")}
            end
         # end
        end
        object.compact
      end
    },
    filter_object: {
      fields: lambda do |_connection, config|
        metadata = get("/v1/describe/#{config['object_name']}").response_format_xml.dig("object", 0, "fields", 0, "field")
        object = metadata.select{|field| field.dig("filterable", 0, "content!") == "true"  &&
          field.dig("type", 0, "content!") == "text" }.map do |o|
            case o.dig("type", 0, "content!")
            when "decimal"
              { name: o.dig("name", 0, "content!"), type: "integer",
                label:  o.dig("label", 0, "content!")}
            when "int"
              { name: o.dig("name", 0, "content!"), type: "integer",
                label:  o.dig("label", 0, "content!")}
            when "text"
              { name: o.dig("name", 0, "content!"), type: "string",
                label:  o.dig("label", 0, "content!")}
            when "string"
              { name: o.dig("name", 0, "content!"), type: "string",
                label:  o.dig("label", 0, "content!")}
            when "boolean"
              { name: o.dig("name", 0, "content!"), type: "boolean",
                label:  o.dig("label", 0, "content!"),
                control_type: "checkbox",
                toggle_hint: "Select from list",
                toggle_field: {
                  name: o.dig("name", 0, "content!"),
                  label: o.dig("label", 0, "content!"),
                  type: :string,
                  control_type: "text",
                  optional: false,
                  toggle_hint: "Use custom value",
                }}
            when "datetime"
              { name: o.dig("name", 0, "content!"), type: "date_time",
                label:  o.dig("label", 0, "content!")}
            when "date"
              { name: o.dig("name", 0, "content!"), type: "date",
                label:  o.dig("label", 0, "content!")}
            when "picklist"
              list = o.dig("options", 0, "option").map do |option|
                [ option.dig("content!"), option.dig("content!")]
              end
              list.reject { |el| el.blank? }
              { name: o.dig("name", 0, "content!"), type: "select",
                picklist: list,
                label:  o.dig("label", 0, "content!")}
            else
              o.dig("type", 0, "content!") == "text"
              { name: o.dig("name", 0, "content!"), type: "string",
                label:  o.dig("label", 0, "content!")}
            end
        end
        object.compact
      end
    }
  },

  methods: {
    get_object_fields: lambda do |input|
      get("/v1/describe/" + input[:object]).
          response_format_xml.
          dig("object", 0, "fields", 0, "field").map do |o|
          o.dig("name", 0, "content!") unless o.dig("selectable", 0,
            "content!") == "false"
      end
    end,

    object_sample_output: lambda do |input|
      post("/v1/action/query").
          headers("x-zuora-wsdl-version": 88.0).
          payload(queryString: "Select " + call("get_object_fields",
           { object: input[:object] }).smart_join(", ") +
            " from " + input[:object] + " ").
          dig("records").first || {}
    end
  },

  actions: {
    get_customer_account_by_id: {
      subtitle: "Get customer account by ID",
      description: "Get <span class='provider'>customer account</span> by ID " \
      "in <span class='provider'>Zuora</span>",

      input_fields: lambda { |_object_definitions|
        [{ name: "id", optional: false }]
      },

      execute: lambda { |_connection, input|
        get("/v1/accounts/#{input['id']}") || {}
      },

      output_fields: lambda { |object_definitions|
        object_definitions["customer_account_get"]
      },

      sample_output: lambda { |_connection|
        account_id = post("/v1/action/query").
        params(batchSize: 1).
        payload(queryString: "select Id from account where " \
                "Status='Active'").
        dig("records", 0, "Id") || ""
        account_id.blank? ? {} : get("/v1/accounts/#{account_id}") || {}
      }
    },

    search_customer_accounts: {
      subtitle: "Search  customer accounts",
      description: "Search <span class='provider'>customer accounts</span> " \
      "in <span class='provider'>Zuora</span>",

      input_fields: lambda { |object_definitions|
        object_definitions["customer_account"].
        only("id", "name", "currency", "autoPay", "paymentTerm", "notes")
      },

      execute: lambda { |_connection, input|
        where_clause = (input || []).
        map { |key, value| "#{key} = '#{value}'" }.
        join(" or ")

        {
          customer_accounts: post("/v1/action/query").
          params(batchSize: 100).
          payload(queryString: " select id, name, currency, autoPay, " \
                  "paymentTerm, notes from account " <<
                  (where_clause.blank? ? "" : "where #{where_clause}")).
          dig("records") || []
        }
      },

      output_fields: lambda { |object_definitions|
        [
          {
            name: "customer_accounts",
            type: "array",
            of: "object",
            properties: object_definitions["customer_account"].
            only("id", "name", "currency", "autoPay", "paymentTerm", "notes")
          }
        ]
      },

      sample_output: lambda { |_connection|
        account_id = post("/v1/action/query").
        params(batchSize: 1).
        payload(queryString: "select Id from account where " \
                "Status='Active'").
        dig("records", 0, "Id") || ""
        account_id.blank? ? {} : get("/v1/accounts/#{account_id}") || {}
      }
    },

    create_customer_account: {
      subtitle: "Create customer account",
      description: "Create <span class='provider'>customer account</span> " \
      "in <span class='provider'>Zuora</span>",
      hint: "Customer accounts created with this call are automatically be set to Auto Pay",
      input_fields: lambda { |object_definitions|
        object_definitions["customer_account"].
        ignored("id").
        required("name", "currency", "billToContact")
      },

      execute: lambda { |_connection, input|
        post("/v1/accounts/").payload(input) || {}
      },

      output_fields: lambda { |_object_definitions|
        [
          { name: "accountId" },
          { name: "accountNumber" },
          { name: "paymentMethodId" }
        ]
      },

      sample_output: lambda { |_connection|
        {
          accountId: "402892c74c9193cd014c96bbe7c101f9",
          accountNumber: "A00000004",
          paymentMethodId: "402892c74c9193cd014c96bbe7d901fd"
        }
      }
    },

    update_customer_account: {
      subtitle: "Update customer account",
      description: "Update <span class='provider'>customer account</span> " \
      "in <span class='provider'>Zuora</span>",
      config_fields: [
        { name: 'object_name', control_type: :select,
          pick_list: :object_list,
          label: 'Object',
          hint: "Select any standard or custom object, e.g. Account",
          optional: false }
      ],
      input_fields: lambda { |object_definitions|
        object_definitions["customer_account"].required("id")
      },

      execute: lambda { |_connection, input|
        put("/v1/accounts/#{input.delete('id')}").payload(input) || {}
      },

      output_fields: ->(_object_definitions) { [] },

      sample_output: ->(_connection) { { success: true } }
    },

    create_object: {
      subtitle: "Create Object",
      description: "Create <span class='provider'>Object</span> " \
      "in <span class='provider'>Zuora</span>",
      config_fields: [
          { name: "object_name", control_type: "select",
            pick_list: "object_list",
            label: "Select Object", optional: false }
        ],
      
      input_fields: lambda do |object_definitions|
        object_definitions["create_object"].ignored("Id", "CreatedById",
          "CreatedDate", "UpdatedById", "UpdatedDate")
      end,

      execute: lambda do |connection, input|
      object = input.delete("object_name")
      results = post("/v1/action/create").
        payload(objects: [input], type: object)
      
      response = results.first unless results.blank?
      {
        response: response
      }
      end,
      output_fields: lambda do |object_definitions|
        [
          { name: "response", type: "object", properties: [
              { name: "success", type: "boolean",
                control_type: "checkbox" },
              { name: "Id" },
              { name: "Errors", type: "array",
                of: "object", properties: [
                  { name: "Code" },
                  { name: "Message"}
                ]}
            ] },
          
        ]
      end,
      sample_output: lambda do |_connection, input|
        { response: { success: "true", Id: "107bb8280175668b1f47e51710214497" }}
      end
    },
     create_objects: {
      subtitle: "Create Objects(bulk)",
      description: "Create <span class='provider'>Objects (bulk)</span> " \
      "in <span class='provider'>Zuora</span>",
      hint: "You can pass in a maximum of 50 zObjects at a time, \n " \
        "You cannot pass in null zObjects. \n" \
        "All objects must be of the same type.",
      config_fields: [
          { name: "object_name", control_type: "select",
            pick_list: "object_list", label: "Select Object",
            optional: false }
        ],
      
      input_fields: lambda do |object_definitions|
        [
          { name: "objects", type: "array", of: "object", 
            optional: false,
            properties: object_definitions["create_object"].ignored("Id",
              "CreatedById", "CreatedDate", "UpdatedById", "UpdatedDate"),
            hint: "You can pass in a maximum of 50 zObjects at a time, \n " \
              "You cannot pass in null zObjects. \n" \
              "All objects must be of the same type.",}
        ]
      end,

      execute: lambda do |connection, input|
      object = input.delete("object_name")
      results = post("/v1/action/create").
        payload(objects: input["objects"], type: object)
      {
        results: results
      }
      end,
      output_fields: lambda do |object_definitions|
        [ { name: "results", type: "array", of: "object", properties: [
            { name: "Errors", type: "array", of: "object", properties: [
              { name: "Code" },
              { name: "Message"}
            ] },
            { name: "success", type: "boolean", control_type: "checkbox" },
            { name: "Id" }] }
        ]
      end,
      sample_output: lambda do |_connection, input|
        { results: [{ success: "true", Id: "107bb8280175668b1f47e51710214497" }]}
      end
    },
    update_object: {
      subtitle: "Update Object",
      description: "Update <span class='provider'>Object</span> " \
      "in <span class='provider'>Zuora</span>",
      config_fields: [
          { name: "object_name", control_type: "select",
            pick_list: "object_list", label: "Select Object",
            optional: false }
        ],
      
      input_fields: lambda do |object_definitions|
        object_definitions["update_object"].required("Id").
          ignored("CreatedById", "CreatedDate", "UpdatedById", "UpdatedDate")
      end,
      execute: lambda do |connection, input|
      object = input.delete("object_name")
      results = post("/v1/action/update").
        payload(objects: [input], type: object)
      response = results.first unless results.blank?
      {
        response: response
      }
      end,
      output_fields: lambda do
        [
          { name: "response", type: "object", properties: [
              { name: "success", type: "boolean",
                control_type: "checkbox" },
              { name: "Id" },
              { name: "Errors", type: "array", of: "object",
                properties: [
                  { name: "Code" },
                  { name: "Message"}
                ]}
            ] },
        ]
      end,

      sample_output: lambda do |_connection, input|
        { response: { success: "true", Id: "107bb8280175668b1f47e51710214497" } }
      end
    },
    update_objects: {
      subtitle: "Update Objects(bulk)",
      description: "Update <span class='provider'>Objects (bulk)</span> " \
      "in <span class='provider'>Zuora</span>",
      config_fields: [
          { name: "object_name",
            control_type: "select",
            pick_list: "object_list", 
            label: "Select Object",
            optional: false }
        ],
      
      input_fields: lambda do |object_definitions|
        [
          { name: "objects", type: "array", of: "object",
            optional: false,
            properties:  object_definitions["update_object"].
              required("Id").ignored("CreatedById", "CreatedDate",
                "UpdatedById", "UpdatedDate"),
            hint: "You can pass in a maximum of 50 zObjects at a time, \n " \
              "You cannot pass in null zObjects. \n" \
              "All objects must be of the same type."}
        ]
      end,

      execute: lambda do |connection, input|
      object = input.delete("object_name")
      results = post("/v1/action/update").
        payload(objects: input, type: object)
      {
        results: results
      }
      end,
      output_fields: lambda do |object_definitions|
        [ { name: "results", type: "array", of: "object",
            properties: [
              { name: "Errors", type: "array", of: "object", properties: [
                { name: "Code" },
                { name: "Message"}
              ] },
            { name: "success", type: "boolean", control_type: "checkbox" },
            { name: "Id" } ] }
        ]
      end,

      sample_output: lambda do |_connection, input|
        { results: [{ success: "true", Id: "107bb8280175668b1f47e51710214497" }]}
      end
    },
    
    search_object: {
      subtitle: "Search Objects",
      description: "Search <span class='provider'>Objects</span> " \
      "in <span class='provider'>Zuora</span>",
      config_fields: [
          { name: "object_name",
            control_type: "select",
            pick_list: "object_list", 
            label: "Select Object",
            optional: false }
        ],
      input_fields: lambda do |object_definitions|
        object_definitions["filter_object"]
      end,

      execute: lambda do |connection, input|
        object = input.delete("object_name")
        fields = call("get_object_fields", { object: object })
        query_params = (input || []).map do |k,v| 
          if ["Name"].include?(k)
            " #{k} = '%#{v}%'" 
          else
            " #{k} = '#{v}'" 
          end
        end.join(" or ")
        
        queryString = "Select " + fields.smart_join(", ") + " from #{object} " +
        ( query_params.blank? ? "" :  "where " + query_params )
        response = post("/v1/action/query").
          headers("x-zuora-wsdl-version": 88.0).
          payload(queryString: queryString)
        objects = response.dig("records")
        {
          objects: objects
        }
      end,

      output_fields: lambda do |object_definitions|
        [
          { name: "objects", type: "array", of: "object",
            properties: object_definitions["object_output"] }
        ]
      end,

      sample_output: lambda do |_connection, input|
        { objects: [call("object_sample_output", { object: input["object_name"] })] }
      end
    }
  },

  triggers: {
    new_object: {
      description: "New <span class='provider'>object</span> in "\
      "<span class='provider'>Zuora</span>",
      help: "Checks for created records, " \
      "Each new record will be processed as a single trigger event.",

      config_fields: [
        { name: "object_name",
          control_type: :select,
          pick_list: :object_list,
          label: "Object",
          hint: "Select any standard or custom object, e.g. Account",
          optional: false }
      ],
      input_fields: lambda do
        [
          {
            name: "since", type: "timestamp",
            label: "From",
            control_type: "date_time",
            hint: "Fetch new objects created from specified time. "\
            "Trigger will fetch objects trigger start time, if left blank",
            sticky: true
          }
        ]
      end,
      poll: lambda do |connection, input, last_created_date|
        last_created = (last_created_date || input["since"] || now).
          to_time.in_time_zone("US/Pacific").strftime("%Y-%m-%dT%H:%M:%S.%L%:z")
        fields = get("/v1/describe/#{input['object_name']}").
          response_format_xml.
          dig("object", 0, "fields", 0, "field").
          map do |o|
          o.dig("name", 0, "content!") unless o.dig("selectable", 0,
            "content!") == "false"
          end
        queryString = "Select " + fields.smart_join(", ") +
          " from #{input['object_name']} where CreatedDate > " +
          "'" + last_created  + "'"
        response = post("/v1/action/query").
          headers("x-zuora-wsdl-version": 88.0).
          payload(queryString: queryString)
        objects = response.dig("records")
        # Query More if there are more than 2000 records
        while response["done"] == false do
          response = post("/v1/action/queryMore").
            headers("x-zuora-wsdl-version": 88.0).
            payload(queryLocator: response["queryLocator"])
          objects << response.dig("records")
        end
        sorted_objects = objects.
          sort_by { |obj| obj["CreatedDate"] } unless objects.blank?
        last_created = sorted_objects.
          last["CreatedDate"] unless sorted_objects.blank?
          {
            events: sorted_objects,
            next_poll: last_created,
            can_poll_more: response["done"] == false
          }
      end,

      dedup: lambda do |object|
          object["Id"] + "@" + object["CreatedDate"]
      end,

      output_fields: lambda do | object_definitions|
        object_definitions["object_output"]
      end,

      sample_output: lambda do |_connection, input|
        call("object_sample_output", { object: input["object_name"] })
      end
    },

    new_updated_object: {
      description: "New or updated <span class='provider'>object</span>"\
      " in <span class='provider'>Zuora</span>",
      help: "Checks for created or updated records, "\
      "new or updated record will be processed as a single trigger event.",
      config_fields: [
        { name: "object_name",
          control_type: :select,
          pick_list: :filter_object_list,
          label: "Object",
          hint: "Select any standard or custom object, e.g. Account",
          optional: false }
      ],
      input_fields: lambda do
        [
          {
            name: "since", type: "timestamp",
            label: "From", control_type: "date_time",
            hint: "Fetch new objects created from specified time."\
            " Trigger will fetch objects from trigger start time if left blank",
            sticky: true
          }
        ]
      end,

      poll: lambda do |connection, input, last_modified_date|
        last_modified = ( last_modified_date || input["since"] ||  now ).
          to_time.in_time_zone("US/Pacific").
          strftime("%Y-%m-%dT%H:%M:%S.%L%:z")
        fields = get("/v1/describe/#{input['object_name']}").
          response_format_xml.
          dig("object", 0, "fields", 0, "field").
          map do |o|
          o.dig("name", 0, "content!") unless o.dig("selectable", 0,
            "content!") == "false"
          end
        queryString = "Select " + fields.smart_join(", ") +
          " from #{input['object_name']} where UpdatedDate > " +
          "'" + last_modified  + "'"
        response = post("/v1/action/query").
          headers("x-zuora-wsdl-version": 88.0, pageSize: 2).
          payload(queryString: queryString)
        objects = response.dig("records")
        # Query More if there are more than 2000 records
        while response["done"] == false do
          response = post("/v1/action/queryMore").
            headers("x-zuora-wsdl-version": 88.0).
            payload(queryLocator: response["queryLocator"])
          objects << response.dig("records")
        end
        sorted_objects = objects.
          sort_by { |obj| obj["UpdatedDate"] } unless objects.blank?
        last_modified = sorted_objects.
          last["UpdatedDate"] unless sorted_objects.blank?
          {
            events: sorted_objects,
            next_poll: last_modified,
            can_poll_more: response["done"] == false
          }
      end,

      dedup: lambda do |object|
          object["Id"] + "@" + object["UpdatedDate"]
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["object_output"]
      end,

      sample_output: lambda do |_connection, input|
        call("object_sample_output", { object: input["object_name"] })
      end
    }
  },
  pick_lists: {
    filter_object_list: lambda do
      get("/v1/describe/").
        response_format_xml.
        dig("objects", 0, "object", ).
        map do | a |
          [ a.dig("label", 0, "content!"), a.dig("name", 0, "content!") ]
        end
    end,
    object_list: lambda do
      get("/v1/describe/").
        response_format_xml.dig("objects", 0, "object", ).
        reject{|field| ["ChargeMetricsRun"].include?field.dig("name", 0, "content!")}.map do | a |
          [ a.dig("label", 0, "content!"), a.dig("name", 0, "content!") ]
        end
    end
  }
}
