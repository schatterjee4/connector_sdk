
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

      detect_on: [/"success"\s*\:\s*false/],

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
          { name: "id" },
          { name: "name" },
          { name: "currency" },
          { name: "notes" },
          { name: "billCycleDay" },
          { name: "autoPay", type: "boolean", control_type: "checkbox" },
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
          { name: "hpmCreditCardPaymentMethodId", sticky: true },
          {
            name: "creditCard",
            type: "object",
            properties: [
              { name: "cardType", sticky: true },
              { name: "cardNumber", sticky: true },
              { name: "expirationMonth", sticky: true },
              { name: "expirationYear", sticky: true },
              { name: "securityCode" }
            ]
          },
          {
            name: "subscription",
            type: "object",
            properties: [
              { name: "contractEffectiveDate", type: "date" },
              { name: "termType", sticky: true },
              { name: "initialTerm" },
              { name: "renewalTerm" },
              { name: "autoRenew", type: "boolean", control_type: "checkbox" },
              { name: "notes" },
              {
                name: "subscribeToRatePlans",
                type: "array",
                of: "object",
                properties: [
                  {
                    name: "subscribeToRatePlan",
                    type: "object",
                    properties: [
                      { name: "productRatePlanId" },
                      {
                        name: "chargeOverrides",
                        type: "array",
                        of: "object",
                        properties: [
                          {
                            name: "chargeOverride",
                            type: "object",
                            properties: [
                              { name: "productRatePlanChargeId" },
                              { name: "price", type: "integer" }
                            ]
                          }
                        ]
                      }
                    ]
                  }
                ]
              }
            ]
          },
          { name: "invoice", type: "boolean", control_type: "checkbox" },
          { name: "collect", type: "boolean", control_type: "checkbox" }
        ]
      }
    }
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

      input_fields: lambda { |object_definitions|
        object_definitions["customer_account"].required("id")
      },

      execute: lambda { |_connection, input|
        put("/v1/accounts/#{input.delete('id')}").payload(input) || {}
      },

      output_fields: ->(_object_definitions) { [] },

      sample_output: ->(_connection) { { success: true } }
    }
  }
}
