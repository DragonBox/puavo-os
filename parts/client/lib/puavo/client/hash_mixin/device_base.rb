module Puavo
  module Client
    module HashMixin
      module DeviceBase
        include Base

        def prettify_attributes
          # Note: value of attribute may be raw ldap value eg. { puavoHostname => ["thinclient-01"] }
          [
           { :original_attribute_name => "description",
             :new_attribute_name => "description",
             :value_block => lambda{ |value| Array(value).first } },
           { :original_attribute_name => "ipHostNumber",
             :new_attribute_name => "ip_address",
             :value_block => lambda{ |value| Array(value).first } },
           { :original_attribute_name => "jpegPhoto",
             :new_attribute_name => "image",
             :value_block => lambda{ |value| Array(value).first } },
           { :original_attribute_name => "macAddress",
             :new_attribute_name => "mac_address",
             :value_block => lambda{ |value| Array(value).first } },
           { :original_attribute_name => "puavoDefaultPrinter",
             :new_attribute_name => "default_printer",
             :value_block => lambda{ |value| Array(value).first } },
           { :original_attribute_name => "puavoDeviceAutoPowerOffMode",
             :new_attribute_name => "auto_power_mode",
             :value_block => lambda{ |value| Array(value).first } },
           { :original_attribute_name => "puavoDeviceBootMode",
             :new_attribute_name => "boot_mode",
             :value_block => lambda{ |value| Array(value).first } },
           { :original_attribute_name => "puavoDeviceManufacturer",
             :new_attribute_name => "manufacturer",
             :value_block => lambda{ |value| Array(value).first } },
           { :original_attribute_name => "puavoDeviceModel",
             :new_attribute_name => "model",
             :value_block => lambda{ |value| Array(value).first } },
           { :original_attribute_name => "puavoLatitude",
             :new_attribute_name => "latitude",
             :value_block => lambda{ |value| Array(value).first } },
           { :original_attribute_name => "puavoLocationName",
             :new_attribute_name => "location_name",
             :value_block => lambda{ |value| Array(value).first } },
           { :original_attribute_name => "puavoLongitude",
             :new_attribute_name => "longitude",
             :value_block => lambda{ |value| Array(value).first } },
           { :original_attribute_name => "puavoPurchaseDate",
             :new_attribute_name => "purchase_date",
             :value_block => lambda{ |value| Array(value).first } },
           { :original_attribute_name => "puavoPurchaseLocation",
             :new_attribute_name => "purchase_location",
             :value_block => lambda{ |value| Array(value).first } },
           { :original_attribute_name => "puavoPurchaseURL",
             :new_attribute_name => "purchase_url",
             :value_block => lambda{ |value| Array(value).first } },
           { :original_attribute_name => "puavoSupportContract",
             :new_attribute_name => "support_contract",
             :value_block => lambda{ |value| Array(value).first } },
           { :original_attribute_name => "puavoTag",
             :new_attribute_name => "tags",
             :value_block => lambda{ |value| Array(value).first } },
           { :original_attribute_name => "puavoWarrantyEndDate",
             :new_attribute_name => "warranty_end_date",
             :value_block => lambda{ |value| Array(value).first } },
           { :original_attribute_name => "serialNumber",
             :new_attribute_name => "serialnumber",
             :value_block => lambda{ |value| Array(value).first } },
           { :original_attribute_name => "puavoHostname",
             :new_attribute_name => "hostname",
             :value_block => lambda{ |value| Array(value).first } },
           { :original_attribute_name => "puavoId",
             :new_attribute_name => "puavo_id",
             :value_block => lambda{ |value| Array(value).first } },
           { :original_attribute_name => "puavoDeviceKernelVersion",
             :new_attribute_name => "kernel_version",
             :value_block => lambda{ |value| Array(value).first } },
           { :original_attribute_name => "puavoDeviceKernelArguments",
             :new_attribute_name => "kernel_arguments",
             :value_block => lambda{ |value| Array(value).first } },
           { :original_attribute_name => "puavoDeviceXrandr",
             :new_attribute_name => "xrandrs",
             :value_block => lambda{ |value| Array(value) } },
           { :original_attribute_name => "puavoDeviceXrandrDisable",
             :new_attribute_name => "xrandr_disable",
             :value_block => lambda{ |value| Array(value).first } },
           { :original_attribute_name => "puavoDeviceType",
             :new_attribute_name => "device_type",
             :value_block => lambda{ |value| Array(value).first } },
           { :original_attribute_name => "puavoDeviceImage",
             :new_attribute_name => "device_image",
             :value_block => lambda{ |value| Array(value).first } },
           { :original_attribute_name => "puavoDeviceXserver",
             :new_attribute_name => "xserver_driver",
             :value_block => lambda{ |value| Array(value).first } } ]
        end
      end
    end
  end
end
