require 'ostruct'
require 'json'

module Settings
  DJALL = JSON.parse({
    yaml: {
      ttl: 600,
      default_folder: '/tmp'
    },

    groups: {
      greenhouse: {
        all: 'prod,canary,use1|prod,prod,use1|prod,prod-s2,use1|prod,prod-s3,use1|prod,prod-s4,use1|prod,prod-s101,euc1',
        us: 'prod,canary,use1|prod,prod,use1|prod,prod-s2,use1|prod,prod-s3,use1|prod,prod-s4,use1',
        us_base: 'prod,canary,use1|prod,prod,use1|prod,prod-s2,use1|prod,prod-s3,use1|prod,prod-s4,use1|prod,prod-base,use1',
        legacy: 'prod,canary,use1|prod,prod,use1|prod,prod-s2,use1',
        leaders: 'prod,prod,use1|prod,prod-s101,euc1',
        staging: 'prod,staging,use1|prod,staging-canary,use1|prod,staging-s2,use1',
        staging_base: 'prod,staging,use1|prod,staging-canary,use1|prod,staging-s2,use1|prod,staging-base,use1',
        non_prod: 'prod,staging,use1|prod,staging-canary,use1|prod,staging-s2,use1|prod,sandbox,use1',
        non_prod_base: 'prod,staging,use1|prod,staging-canary,use1|prod,staging-s2,use1|prod,sandbox,use1'
      }
    },

    formatting: {
      column_spacing: 2,
      max_display_width: 180
    },

    secret_password: ENV.fetch('DJ_ALL_SECRET_PASSWORD', nil)
  }.to_json, object_class: OpenStruct)

end
