require 'ostruct'

module Settings
  class DjAll
    YAML = OpenStruct.new({
      ttl: 600,
      default_folder: '/tmp'
    })

    GROUPS = OpenStruct.new({
      greenhouse: OpenStruct.new({
        all: 'prod,canary,use1|prod,prod,use1|prod,prod-s2,use1|prod,prod-s3,use1|prod,prod-s4,use1|prod,prod-s101,euc1',
        us: 'prod,canary,use1|prod,prod,use1|prod,prod-s2,use1|prod,prod-s3,use1|prod,prod-s4,use1',
        legacy: 'prod,canary,use1|prod,prod,use1|prod,prod-s2,use1',
        leaders: 'prod,prod,use1|prod,prod-s101,euc1'

      })
    })

    FORMATTING = OpenStruct.new({
      column_spacing: 2,
      max_display_width: 180
    })

  end
end
