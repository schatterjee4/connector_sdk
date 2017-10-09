{
  title: "Coupa",

  connection: {
    fields: [
      { name: "host", control_type: :subdomain, url: ".com", optional: false,
        hint: "If your Coupa URL is https://acme.coupacloud.com then use acme.coupacloud as value." },
      { name: "api_key", control_type: :password, label: "API key",
        hint: "A key can be created from the “API Keys” section of the Administration tab by an admin user." }
    ],

    authorization: {
      type: "custom_auth",

      apply: lambda do |connection|
        headers("X-COUPA-API-KEY": connection["api_key"],
                "ACCEPT": "application/json")
      end
    }
  },

  object_definitions: {
    user_input: {
      fields: ->() {
        [
          { name: "login" },
          { name: "email" },
          { name: "firstname", label: "First name" },
          { name: "lastname", label: "Last name" },
          { name: "generate_password_and_notify", label: "Generate password and notify?",
            control_type: :checkbox, type: :boolean, optional: false },
          { name: "password", hint: "Set temporary password for user", sticky: true },
          { name: "salesforce_enabled", label: "Salesforce enabled?",
            control_type: :checkbox, type: :boolean, optional: false },
          { name: "salesforce_id", hint: "Required if Salesforce is enabled for user",
            label: "Salesforce ID" },
          { name: "purchasing_user", label: "Purchasing user?", type: :boolean },
          { name: "expense_user", label: "Expense user?", type: :boolean },
          { name: "sourcing_user", label: "Sourcing user?", type: :boolean },
          { name: "inventory_user", label: "Inventory user?", type: :boolean },
          { name: "contracts_user", label: "Contracts user?", type: :boolean },
          { name: "analytics_user", label: "Analytics user?", type: :boolean },
          { name: "employee_number", label: "Employee number" },
          { name: "active", type: :boolean },
          { name: "account_security_type", label: "Account security type", type: :integer },
          { name: "authentication_method", label: "Authentication method" },
          { name: "sso_identifier", label: "SSO identifier" },
          { name: "default_locale", label: "Default locale" },
          { name: "business_group_security_type", label: "Business group security type", type: :integer },
          { name: "edit_invoice_on_quick_entry", label: "Edit invoice on quick entry?", type: :boolean },
          { name: "mention_name", label: "Mention name" },
          { name: "assignee", label: "Assignee" },
          { name: "phone_work", label: "Work phone", type: :object, properties: [
            { name: "country_code" },
            { name: "area_code" },
            { name: "number" },
            { name: "extension" }
          ] },
          { name: "phone_mobile", label: "Mobile phone", type: :object, properties: [
            { name: "country_code" },
            { name: "area_code" },
            { name: "number" },
            { name: "extension" }
          ] },
          { name: "roles", type: :array, of: :object, properties: [
            { name: "name" },
          ] },
          { name: "manager", type: :object, properties: [
            { name: "id", label: "Manager", control_type: :select, pick_list: "users",
              toggle_hint: "Select from list", toggle_field: {
                name: "id", type: :string, control_type: :text,
                label: "Manager user ID", toggle_hint: "Use custom value"
            } },
          ] },
          { name: "default_address", label: "Default address", type: :object,
            hint: "Fields below are only required if default address is to be set",
            properties: [
              { name: "name" },
              { name: "location_code", label: "Location code" },
              { name: "street1", optional: false },
              { name: "street2" },
              { name: "city", optional: false },
              { name: "state" },
              { name: "postal_code", optional: false, label: "Postal code" },
              { name: "attention" },
              { name: "active", label: "Active?", type: :boolean },
              { name: "business_group_name", label: "Business group name" },
              { name: "vat_number", label: "VAT number" },
              { name: "local_tax_number", optional: false, label: "Local tax number" },
              { name: "country", optional: false, type: :object, properties: [
                { name: "name", optional: false },
              ] },
              { name: "vat_country", label: "VAT country" },
              { name: "content_groups", label: "Content groups", type: :array, of: :object, properties: [
                { name: "id", label: "Content group", control_type: :multiselect, pick_list: "content_groups" },
            ] },
          ] },
          { name: "default_account", label: "Default account", type: :object, properties: [
            { name: "id", label: "Account", control_type: :select, pick_list: "accounts",
              toggle_hint: "Select from list", toggle_field: {
                name: "id", type: :string, control_type: :text,
                label: "Account ID", toggle_hint: "Use custom value"
            } },
          ] },
          { name: "default_account_type", label: "Default account type", type: :object, properties: [
            { name: "id", label: "Account type", control_type: :select, pick_list: "account_types",
              toggle_hint: "Select from list", toggle_field: {
                name: "id", type: :string, control_type: :text,
                label: "Account type ID", toggle_hint: "Use custom value"
            } },

          ] },
          { name: "default_currency", label: "Default currency", type: :object, properties: [
            { name: "id", label: "Currency", control_type: :select, pick_list: "currencies",
              toggle_hint: "Select from list", toggle_field: {
                name: "id", type: :string, control_type: :text,
                label: "Currency ID", toggle_hint: "Use custom value"
            } },
          ] },
          { name: "pcard" },
          { name: "department", type: :object, properties: [
            { name: "id", label: "Department", control_type: :select, pick_list: "departments",
              toggle_hint: "Select from list", toggle_field: {
                name: "id", type: :string, control_type: :text,
                label: "Department ID", toggle_hint: "Use custom value"
            } },
          ] },
          { name: "requisition_approval_limit", label: "Requisition approval limit", type: :object, properties: [
            { name: "id", label: "ID", type: :integer },
          ] },
          { name: "expense_approval_limit", label: "Expense approval limit", type: :object, properties: [
            { name: "id", label: "ID", type: :integer },
          ] },
          { name: "invoice_approval_limit", label: "Invoice approval limit", type: :object, properties: [
            { name: "id", label: "ID", type: :integer },
          ] },
          { name: "requisition_self_approval_limit", label: "Requisition self-approval limit",type: :object, properties: [
            { name: "id", label: "ID", type: :integer },
          ] },
          { name: "expense_self_approval_limit", label: "Expense self-approval limit",type: :object, properties: [
            { name: "id", label: "ID", type: :integer },
          ] },
          { name: "invoice_self_approval_limit", label: "Invoice self-approval limit",type: :object, properties: [
            { name: "id", label: "ID", type: :integer },
          ] },
          { name: "approval_limit", label: "Approval limit", type: :object, properties: [
            { name: "id", label: "ID", type: :integer },
          ] },
          { name: "self_approval_limit", label: "Self-approval limit", type: :object, properties: [
            { name: "id", label: "ID", type: :integer },
          ] },
          { name: "contract_approval_limit", label: "Contract approval limit", type: :object, properties: [
            { name: "id", label: "ID", type: :integer },
          ] },
          { name: "contract_self_approval_limit", label: "Contract self-approval limit", type: :object, properties: [
            { name: "id", label: "ID", type: :integer },
          ] },
          { name: "content_groups", label: "Content groups", type: :array, of: :object, properties: [
            { name: "id", label: "Content group", control_type: :multiselect, pick_list: "content_groups" }
          ] },
          { name: "account_groups", label: "Account groups", type: :array, of: :object, properties: [
            { name: "id", label: "ID", type: :integer }
          ] },
          { name: "approval_groups", label: "Approval groups", type: :array, of: :object, properties: [
            { name: "id", label: "ID", type: :integer },
          ] },
          { name: "user_groups", label: "User groups", type: :array, of: :object, properties: [
            { name: "id", label: "User group", control_type: :multiselect, pick_list: "user_groups" }
          ] },
          { name: "working_warehouses", label: "Working warehouses", type: :array, of: :object, properties: [
            { name: "id", label: "ID", type: :integer },
          ] },
          { name: "inventory_organizations", label: "Inventory organizations", type: :object, properties: [
            { name: "id", label: "ID", type: :integer },
          ] },
        ]
      }
    },

    user_output: {
      fields: ->() {
        [
          { name: "id", label: "ID", type: :integer },
          { name: "created-at", label: "Created at", type: :datetime },
          { name: "updated-at", label: "Updated at", type: :datetime },
          { name: "login" },
          { name: "email" },
          { name: "purchasing-user", label: "Purchasing user?", control_type: :checkbox, type: :boolean },
          { name: "expense-user", label: "Expense user?", control_type: :checkbox, type: :boolean },
          { name: "sourcing-user", label: "Sourcing user?", control_type: :checkbox, type: :boolean },
          { name: "inventory-user", label: "Inventory user?", control_type: :checkbox, type: :boolean },
          { name: "contracts-user", label: "Contracts user?", control_type: :checkbox, type: :boolean },
          { name: "analytics-user", label: "Analytics user?", control_type: :checkbox, type: :boolean },
          { name: "employee-number", label: "Employee number" },
          { name: "firstname", label: "First name" },
          { name: "lastname", label: "Last name" },
          { name: "fullname", label: "Full name" },
          { name: "api-user", label: "API user?", type: :boolean },
          { name: "active", type: :boolean },
          { name: "salesforce-id", label: "Salesforce ID" },
          { name: "account-security-type", label: "Account security type", type: :integer },
          { name: "authentication-method", label: "Authentication method", },
          { name: "sso-identifier", label: "SSO identifier" },
          { name: "default-locale", label: "Default locale",},
          { name: "business-group-security-type", label: "Business group security type", type: :integer },
          { name: "edit-invoice-on-quick-entry", label: "Edit invoice on quick entry?", type: :boolean },
          { name: "avatar-thumb-url", label: "Avatar thumb URL", },
          { name: "mention-name", label: "Mention name", },
          { name: "assignee" },
          { name: "phone-work", label: "Work phone", type: :object, properties: [
            { name: "country-code" },
            { name: "area-code" },
            { name: "number" },
            { name: "extension" }
          ] },
          { name: "phone-mobile", label: "Mobile phone", type: :object, properties: [
            { name: "country-code" },
            { name: "area-code" },
            { name: "number" },
            { name: "extension" }
          ] },
          { name: "roles", type: :array, of: :object, properties: [
            { name: "id", label: "ID", type: :integer },
            { name: "name" },
            { name: "description" },
            { name: "omnipotent", type: :boolean },
            { name: "system-role", label: "System role", type: :boolean },
          ] },
          { name: "manager", type: :object, properties: [
            { name: "id", label: "ID", type: :integer },
            { name: "login" },
            { name: "firstname", label: "First name" },
            { name: "lastname", label: "Last name" },
            { name: "employee-number", label: "Employee number" },
            { name: "email" },
            { name: "salesforce-id", label: "Salesforce ID" },
            { name: "avatar-thumb-url", label: "Avatar thumb URL" },
          ] },
          { name: "default-address", label: "Default address", type: :object, properties: [
            { name: "id", label: "ID", type: :integer },
            { name: "name" },
            { name: "location-code", label: "Location code" },
            { name: "street1" },
            { name: "street2" },
            { name: "city" },
            { name: "state" },
            { name: "postal-code", label: "Postal code" },
            { name: "attention" },
            { name: "active", label: "Active?", type: :boolean },
            { name: "business-group-name", label: "Business group name" },
            { name: "vat-number", label: "VAT number" },
            { name: "local-tax-number", label: "Local tax number" },
            { name: "country", type: :object, properties: [
              { name: "name" },
            ] },
            { name: "vat-country", label: "VAT country" },
            { name: "content-groups", label: "Content groups", type: :array, of: :object, properties: [
              { name: "id", label: "ID", type: :integer },
              { name: "name" },
              { name: "description" }
            ] },
          ] },
          { name: "default-account", label: "Default account", type: :object, properties: [
            { name: "id", label: "ID", type: :integer },
            { name: "name" },
            { name: "code" },
            { name: "active", label: "Active?", type: :boolean },
            { name: "segment-1" },
            { name: "segment-2" },
            { name: "segment-3" },
            { name: "segment-4" },
            { name: "segment-5" },
            { name: "segment-6" },
            { name: "segment-7" },
            { name: "segment-8" },
            { name: "segment-9" },
            { name: "segment-10" },
            { name: "segment-11" },
            { name: "segment-12" },
            { name: "segment-13" },
            { name: "segment-14" },
            { name: "segment-15" },
            { name: "segment-16" },
            { name: "segment-17" },
            { name: "segment-18" },
            { name: "segment-19" },
            { name: "segment-20" },
            { name: "account-type", type: :object, properties: [
              { name: "id", label: "ID", type: :integer },
              { name: "name" },
              { name: "active", label: "Active?", type: :boolean },
              { name: "currency", type: :object, properties: [
                { name: "id", label: "ID", type: :integer },
                { name: "code" },
                { name: "decimals", type: :integer },
              ] },
              { name: "primary-contact", label: "Primary contact" },
              { name: "primary-address", label: "Primary address", type: :object, properties: [
                { name: "id", label: "ID", type: :integer },
                { name: "name" },
                { name: "location-code", label: "Location code" },
                { name: "street1" },
                { name: "street2" },
                { name: "city" },
                { name: "state" },
                { name: "postal-code", label: "Postal code" },
                { name: "attention" },
                { name: "active", label: "Active?", type: :boolean },
                { name: "business-group-name", label: "Business group name" },
                { name: "vat-number", label: "VAT number" },
                { name: "local-tax-number", label: "Local tax number" },
                { name: "country", type: :object, properties: [
                  { name: "name" },
                ] },
                { name: "vat-country" },
                { name: "content-groups", label: "Content groups", type: :array, of: :object, properties: [
                  { name: "id", label: "ID", type: :integer },
                  { name: "name" },
                  { name: "description" }
                ] },

              ] },
            ] },
          ] },
          { name: "default-account-type", label: "Default account type", type: :object, properties: [
            { name: "id", label: "ID", type: :integer },
            { name: "name" },
            { name: "active", label: "Active?", type: :boolean },
            { name: "currency", type: :object, properties: [
              { name: "id", label: "ID", type: :integer },
              { name: "code" },
              { name: "decimals", type: :integer },
            ] },
            { name: "primary-contact", label: "Primary contact", type: :object },
            { name: "primary-address", label: "Primary address", type: :object, properties: [
              { name: "id", label: "ID", type: :integer },
              { name: "name" },
              { name: "location-code", label: "Location code" },
              { name: "street1" },
              { name: "street2" },
              { name: "city" },
              { name: "state" },
              { name: "postal-code", label: "Postal code" },
              { name: "attention" },
              { name: "active", label: "Active?", type: :boolean },
              { name: "business-group-name", label: "Business group name" },
              { name: "vat-number", label: "VAT number" },
              { name: "local-tax-number", label: "Local tax number" },
              { name: "country", type: :object, properties: [
                { name: "name" },
              ] },
              { name: "vat-country" },
              { name: "content-groups", label: "Content groups", type: :array, of: :object, properties: [
                { name: "id", label: "ID", type: :integer },
                { name: "name" },
                { name: "description" }
              ] },

            ] },
          ] },
          { name: "default-currency", label: "Default currency", type: :object, properties: [
            { name: "id", label: "ID", type: :integer },
            { name: "code" },
            { name: "decimals", type: :integer },
          ] },
          { name: "pcard" },
          { name: "department", type: :object, properties: [
            { name: "id", type: :integer },
            { name: "name" },
            { name: "active", label: "Active?", type: :boolean }
          ] },
          { name: "requisition-approval-limit", label: "Requisition approval limit", type: :object, properties: [
            { name: "id", label: "ID", type: :integer },
            { name: "name" },
            { name: "amount" },
            { name: "subject" },
            { name: "currency", type: :object, properties: [
              { name: "id", label: "ID", type: :integer },
              { name: "code" },
              { name: "decimals", type: :integer },
            ] },
          ] },
          { name: "expense-approval-limit", label: "Expense approval limit", type: :object, properties: [
            { name: "id", label: "ID", type: :integer },
            { name: "name" },
            { name: "amount" },
            { name: "subject" },
            { name: "currency", type: :object, properties: [
              { name: "id", label: "ID", type: :integer },
              { name: "code" },
              { name: "decimals", type: :integer },
            ] },
          ] },
          { name: "invoice-approval-limit", label: "Invoice approval limit", type: :object, properties: [
            { name: "id", label: "ID", type: :integer },
            { name: "name" },
            { name: "amount" },
            { name: "subject" },
            { name: "currency", type: :object, properties: [
              { name: "id", label: "ID", type: :integer },
              { name: "code" },
              { name: "decimals", type: :integer },
            ] },
          ] },
          { name: "requisition-self-approval-limit", label: "Requisition self-approval limit",type: :object, properties: [
            { name: "id", label: "ID", type: :integer },
            { name: "name" },
            { name: "amount" },
            { name: "subject" },
            { name: "currency", type: :object, properties: [
              { name: "id", label: "ID", type: :integer },
              { name: "code" },
              { name: "decimals", type: :integer },
            ] },
          ] },
          { name: "expense-self-approval-limit", label: "Expense self-approval limit",type: :object, properties: [
            { name: "id", label: "ID", type: :integer },
            { name: "name" },
            { name: "amount" },
            { name: "subject" },
            { name: "currency", type: :object, properties: [
              { name: "id", label: "ID", type: :integer },
              { name: "code" },
              { name: "decimals", type: :integer },
            ] },
          ] },
          { name: "contract-approval-limit", label: "Contract approval limit", type: :object, properties: [
            { name: "id", label: "ID", type: :integer },
            { name: "name" },
            { name: "amount" },
            { name: "subject" },
            { name: "currency", type: :object, properties: [
              { name: "id", label: "ID", type: :integer },
              { name: "code" },
              { name: "decimals", type: :integer },
            ] },
          ] },
          { name: "contract-self-approval-limit", label: "Contract self-approval limit", type: :object, properties: [
            { name: "id", label: "ID", type: :integer },
            { name: "name" },
            { name: "amount" },
            { name: "subject" },
            { name: "currency", type: :object, properties: [
              { name: "id", label: "ID", type: :integer },
              { name: "code" },
              { name: "decimals", type: :integer },
            ] },
          ] },
          { name: "can-expense-for", label: "Can expense for", type: :array, of: :string },
          { name: "content-groups", label: "Content groups", type: :array, of: :object, properties: [
            { name: "id", label: "ID", type: :integer },
            { name: "name" },
            { name: "description" }
          ] },
          { name: "account-groups", label: "Account groups", type: :array, of: :string },
          { name: "approval-groups", label: "Approval groups", type: :array, of: :object, properties: [
            { name: "id", label: "ID", type: :integer },
            { name: "name" },
            { name: "active", label: "Active?", type: :boolean },
            { name: "open", label: "Open?", type: :boolean },
            { name: "can-approve", label: "Can approve?", type: :boolean },
            { name: "description" },
            { name: "mention-name", label: "Mention name" },
            { name: "users", type: :array, of: :object, properties: [
              { name: "id", label: "ID", type: :integer },
              { name: "login" },
              { name: "firstname", label: "First name" },
              { name: "lastname", label: "Last name" },
              { name: "employee-number", label: "Employee number" },
              { name: "email" },
              { name: "salesforce-id", label: "Salesforce ID" },
              { name: "avatar-thumb-url", label: "Avatar thumb URL" },
            ] },
          ] },
          { name: "user-groups", label: "User groups", type: :array, of: :object, properties: [
            { name: "id", label: "ID", type: :integer },
            { name: "name" },
            { name: "active", label: "Active?", type: :boolean },
            { name: "open", label: "Open?", type: :boolean },
            { name: "can-approve", label: "Can approve?", type: :boolean },
            { name: "description" },
            { name: "mention-name", label: "Mention name" },
            { name: "users", type: :array, of: :object, properties: [
              { name: "id", label: "ID", type: :integer },
              { name: "login" },
              { name: "firstname", label: "First name" },
              { name: "lastname", label: "Last name" },
              { name: "employee-number", label: "Employee number" },
              { name: "email" },
              { name: "salesforce-id", label: "Salesforce ID" },
              { name: "avatar-thumb-url", label: "Avatar thumb URL" },
            ] },
          ] },
          { name: "working-warehouses", label: "Working warehouses", type: :array, of: :object, properties: [
            { name: "id", label: "ID", type: :integer },
            { name: "active-flag", label: "Active flag", type: :boolean },
            { name: "description" },
            { name: "name" },
            { name: "address", type: :object, properties: [
              { name: "id", label: "ID", type: :integer }
            ] },
            { name: "asset-tracking-location", label: "Asset tracking location", type: :boolean },
            { name: "warehouse-type", label: "Warehouses type", type: :object, properties: [
              { name: "id", label: "ID", type: :integer },
              { name: "description" },
              { name: "name" },
            ] },
            { name: "warehouse-locations", label: "Warehouse locations", type: :object, properties: [
              { name: "id", label: "ID", type: :integer },
              { name: "aisle" },
              { name: "bin" },
              { name: "level" },
            ] },
          ] },
          { name: "inventory-organizations", label: "Inventory organizations", type: :object, properties: [
            { name: "id", label: "ID", type: :integer },
            { name: "fulfillment-type", label: "Fulfillment type" },
            { name: "currency", type: :object, properties: [
              { name: "id", label: "ID", type: :integer },
              { name: "code" },
              { name: "decimals", type: :integer },
            ] },
            { name: "warehouses", label: "Warehouses", type: :array, of: :object, properties: [
              { name: "id", label: "ID", type: :integer },
              { name: "active-flag", label: "Active flag", type: :boolean },
              { name: "description" },
              { name: "name" },
              { name: "address", type: :object, properties: [
                { name: "id", label: "ID", type: :integer }
              ] },
              { name: "asset-tracking-location", label: "Asset tracking location", type: :boolean },
              { name: "warehouse-type", label: "Warehouses type", type: :object, properties: [
                { name: "id", label: "ID", type: :integer },
                { name: "description" },
                { name: "name" },
              ] },
              { name: "warehouse-locations", label: "Warehouse locations", type: :object, properties: [
                { name: "id", label: "ID", type: :integer },
                { name: "aisle" },
                { name: "bin" },
                { name: "level" },
              ] },
            ] },
          ] },
          { name: "created-by", type: :object, properties: [
            { name: "id", label: "ID", type: :integer },
            { name: "login" },
            { name: "firstname", label: "First name" },
            { name: "lastname", label: "Last name" },
            { name: "employee-number", label: "Employee number" },
            { name: "email" },
            { name: "salesforce-id", label: "Salesforce ID" },
            { name: "avatar-thumb-url", label: "Avatar thumb URL" },
          ] },
          { name: "updated-by", type: :object, properties: [
            { name: "id", label: "ID", type: :integer },
            { name: "login" },
            { name: "firstname", label: "First name" },
            { name: "lastname", label: "Last name" },
            { name: "employee-number", label: "Employee number" },
            { name: "email" },
            { name: "salesforce-id", label: "Salesforce ID" },
            { name: "avatar-thumb-url", label: "Avatar thumb URL" },
          ] }
        ]
      }
    }
  },

  test: ->(connection) {
    get("https://#{connection["host"]}.com/api/users")
  },

  actions: {
    get_user_by_id: {
      description: 'Get <span class="provider">user</span> '\
                   'by ID in <span class="provider">Coupa</span>',
      subtitle: "Get user by ID in Coupa",

      input_fields: lambda do
        [
          { name: "user_id", type: :string, optional: false }
        ]
      end,

      execute: lambda do |connection, input|
        get("https://#{connection["host"]}.com/api/users/#{input["user_id"]}")
      end,

      output_fields: lambda do |object_definitions|
        # some fields in the od are not returned by the api
        [
          { name: "user", type: :object, properties: object_definitions["user_output"] }
        ]
      end,

      sample_output: lambda do |connection|
        {
          "user": get("https://#{connection["host"]}.com/api/users").
                    params(limit: 1).first
        }
      end

    },

    create_user: {
      description: 'Create <span class="provider">user</span> '\
                   'in <span class="provider">Coupa</span>',
      subtitle: "Create user in Coupa",

      input_fields: lambda do |object_definitions|
        object_definitions["user_input"].
          required(
            "firstname",
            "lastname",
            "email",
            "login",
            "salesforce-id")
      end,

      execute: lambda do |connection, input|
        post("https://#{connection["host"]}.com/api/users").
          payload(input)
      end,

      output_fields: lambda do |object_definitions|
        [
          { name: "user", type: :object, properties: object_definitions["user_output"] }
        ]
      end,

      sample_output: lambda do |connection|
        {
          "user": get("https://#{connection["host"]}.com/api/users").
                    params(limit: 1).first
        }
      end
    },

    update_user: {
      description: 'Update <span class="provider">user</span> '\
                   'in <span class="provider">Coupa</span>',
      subtitle: "Update user in Coupa",

      input_fields: lambda do |object_definitions|
        [
          { name: "user_id", type: :string, optional: false },
          { name: "user", type: :object, optional: false,
            properties: object_definitions["user_input"].
                          ignored(
                            "generate_password_and_notify",
                            "salesforce_enabled") }
        ]
      end,

      execute: lambda do |connection, input|
        put("https://#{connection["host"]}.com/api/users/#{input["user_id"]}").
          payload(input["user"])
      end,

      output_fields: lambda do |object_definitions|
        [
          { name: "user", type: :object,
            properties: object_definitions["user_output"] }
        ]
      end,

      sample_output: lambda do |connection|
        {
          "user": get("https://#{connection["host"]}.com/api/users").
                    params(limit: 1).first
        }
      end
    }
  },

  triggers: {

    new_or_updated_user: {
      input_fields: lambda do
        [
          { name: "from", type: :timestamp,
            hint: "Defaults to tickets created or updated after the recipe is first started"
          }
        ]
      end,

      poll: lambda do |connection, input, last_updated_since|
        page_size = 50
        updated_since = last_updated_since || input["from"] || Time.now.to_s
        users = get("https://#{connection["host"]}.com/api/users").
                  params("updated_at[gt_or_eq]": updated_since)
        next_updated_since = users.last["updated-at"] unless users.blank?

        {
          events: users,
          next_poll: next_updated_since,
          can_poll_more: users.length >= page_size
        }
      end,

      dedup: lambda do |user|
        user["id"].to_s + "@" + user["updated-at"]
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["user_output"]
      end,

      sample_output: lambda do |connection|
          get("https://#{connection["host"]}.com/api/users").
                    params(limit: 1).first
      end
    }
  },

  pick_lists: {
    accounts: lambda do |connection|
      get("https://#{connection["host"]}.com/api/accounts").
        map { |account| [ (account["name"]? account["name"] : account["code"]), account["id"] ] }
    end,

    account_types: lambda do |connection|
      get("https://#{connection["host"]}.com/api/account_types").
        map { |type| [ type["name"], type["id"] ] }
    end,

    content_groups: lambda do |connection|
      get("https://#{connection["host"]}.com/api/business_groups").
        map { |group| [ group["name"], group["id"] ] }
    end,

    currencies: lambda do |connection|
      get("https://#{connection["host"]}.com/api/currencies").
        map { |currency| [ currency["code"], currency["id"] ] }
    end,

    departments: lambda do |connection|
      get("https://#{connection["host"]}.com/api/departments").
        map { |department| [ department["name"], department["id"] ] }
    end,

    users: lambda do |connection|
      get("https://#{connection["host"]}.com/api/users").
        map { |user| [ user["fullname"], user["id"] ] }
    end,

    user_groups: lambda do |connection|
      get("https://#{connection["host"]}.com/api/user_groups").
        map { |group| [ group["name"], group["id"] ] }
    end
  }
}
