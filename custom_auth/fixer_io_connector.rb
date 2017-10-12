{
  title: "Fixer.io",

  connection: {
    fields: [],

    authorization: {},
  },

  test: ->() {},

  object_definitions: {

    base_currency: {
      fields: ->() {
        [
          { name: "amount", type: :number, optional: false },
          { name: "conversion_date", type: :date,
            hint: "Time at which currency conversion rate is valid. "\
                  "Leave blank to fetch latest rates" }
        ]
      }
  	},

    target_currency: {
      fields: ->() {
        [
          { name: "amount", type: :bigdecimal },
          { name: "rate", type: :number },
          { name: "base_currency_code" },
          { name: "target_currency_code" },
          { name: "conversion_date", type: :date }
        ]
      }
    },

  },

  actions: {
    convert_to_specified_currency: {
      description: 'Convert <span class="provider">currency</span> '\
                   'via <span class="provider">Fixer.io</span>',
      subtitle: "Convert currency via Fixer.io",

      input_fields: lambda do |object_definitions|
        [
          { name: "from_fx", label: "Base Currency (Code)",
            hint: "Choose a currency code you would like to convert from",
            control_type: :select, pick_list: "currencies", optional: false,
            toggle_hint: "Select from list",
              toggle_field: {
                name: "from_fx", label: "Base Currency (Custom)", type: :string,
                control_type: "text", optional: false,
                toggle_hint: "Use custom value",
                hint: "Enter the currency code you would like to convert from, "\
                      "in ISO4217 format. e.g.: USD - US Dollar, "\
                      "SGD - Singapore Dollar" } },
          { name: "to_fx", label: "Target Currency (Code)",
            hint: "Choose a currency code you would like to convert to",
            control_type: :select, pick_list: "currencies", optional: false,
            toggle_hint: "Select from list",
            toggle_field: {
              name: "to_fx", label: "Target Currency (Custom)", type: :string,
              control_type: "text", optional: false,
              toggle_hint: "Use custom value",
              hint: "Enter the currency code you would like to convert to, "\
                    "in ISO4217 format. e.g.: USD - US Dollar, "\
                    "SGD - Singapore Dollar" } }
        ].concat(object_definitions["base_currency"])
      end,

      execute: lambda do |connection, input|
        conversion_date = input["conversion_date"].present? ?
        	input["conversion_date"] : "latest"
        result = get("http://api.fixer.io/#{conversion_date}").
                   params(
          	          base: input["from_fx"],
                      symbols: input["to_fx"]
                   )
        rate = result["rates"][input["to_fx"]]
        fx_out = input["amount"].to_f * rate
        {
          "amount": fx_out,
          "rate": rate,
          "base_currency_code": input["from_fx"],
          "target_currency_code": input["to_fx"],
          "conversion_date": input["conversion_date"]
        }
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["target_currency"]
      end
    }
  },

  triggers: {
  },

  pick_lists: {
    currencies: ->() {
      results = get("https://api.fixer.io/latest").dig("rates")
      # EUR is excluded by default, manually add for the purpose of mapping
      results[:EUR] = "EUR"
      results.map { |k,v| [k,k] }
    }
  }
}
