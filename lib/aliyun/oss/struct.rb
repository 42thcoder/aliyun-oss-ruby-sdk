# -*- encoding: utf-8 -*-

module Aliyun
  module OSS

    ##
    # Access Control List, it controls how the bucket/object can be
    # accessed.
    # * public-read-write: allow access(read&write) anonymously
    # * public-read: allow read anonymously
    # * private: access must be signatured
    #
    module ACL
      PUBLIC_READ_WRITE = "public-read-write"
      PUBLIC_READ = "public-read"
      PRIVATE = "private"
    end # ACL

    ##
    # A OSS object may carry some metas(String key-value pairs) with
    # it. MetaDirective specifies what to do with the metas in the
    # copy process.
    # * COPY: metas are copied from the source object to the dest
    #   object
    # * REPLACE: source object's metas are NOT copied, use user
    #   provided metas for the dest object
    #
    module MetaDirective
      COPY = "COPY"
      REPLACE = "REPLACE"
    end # MetaDirective

    ##
    # The object key may contains unicode charactors which cannot be
    # encoded in the request/response body(XML). KeyEncoding specifies
    # the encoding type for the object key.
    # * url: the object key is url-encoded
    # @note url-encoding is the only supported KeyEncoding type
    #
    module KeyEncoding
      URL = "url"

      @@all = [URL]

      def self.include?(enc)
        all.include?(enc)
      end

      def self.all
        @@all
      end
    end # KeyEncoding

    ##
    # Common structs used. It provides a 'attrs' helper method for
    # subclass to define its attributes. 'attrs' is based on
    # attr_reader and provide additional functionalities for classes
    # that inherits Struct::Base :
    # * the constuctor is provided to accept options and set the
    #   corresponding attibute automatically
    # * the #to_s method is rewrite to concatenate the defined
    #   attributes keys and values
    # @example
    #   class X < Struct::Base
    #     attrs :foo, :bar
    #   end
    #
    #   x.new(:foo => 'hello', :bar => 'world')
    #   x.foo # == "hello"
    #   x.bar # == "world"
    #   x.to_s # == "foo: hello, bar: world"
    module Struct
      class Base
        module AttrHelper
          def attrs(*s)
            define_method(:attrs) {s}
            attr_reader(*s)
          end
        end

        extend AttrHelper

        def initialize(opts = {})
          attrs.each do |attr|
            instance_variable_set("@#{attr}", opts[attr])
          end
        end

        def to_s
          attrs.map do |attr|
            v = instance_variable_get("@#{attr}")
            "#{attr.to_s}: #{v}"
          end.join(", ")
        end
      end # Base
    end # Struct

    ##
    # LifeCycle rule for bucket. See: {http://help.aliyun.com/document_detail/oss/product-documentation/function/lifecycle.html OSS Bucket LifeCycle}
    # Attributes:
    # * id [String] the unique id of a rule
    # * enabled [Boolean] whether to enable this rule
    # * prefix [String] the prefix objects to apply this rule
    # * expiry [Date] or [Fixnum] the expire time of objects
    #   * if expiry is a Date, it specifies the absolute date to
    #     expire objects
    #   * if expiry is a Fixnum, it specifies the relative date to
    #     expire objects: how many days after the object's last
    #     modification time to expire the object
    # @example Specify expiry as Date
    #   LifeCycleRule.new(
    #     :id => 'rule1',
    #     :enabled => true,
    #     :prefix => 'foo/',
    #     :expiry => Date.new(2016, 1, 1))
    # @example Specify expiry as days
    #   LifeCycleRule.new(
    #     :id => 'rule1',
    #     :enabled => true,
    #     :prefix => 'foo/',
    #     :expiry => 15)
    # @note the expiry date is treated as UTC time
    class LifeCycleRule < Struct::Base

      attrs :id, :enabled, :prefix, :expiry

    end # LifeCycleRule

    ##
    # CORS rule for bucket. See: {http://help.aliyun.com/document_detail/oss/product-documentation/function/referer-white-list.html OSS CORS}
    # Attributes:
    # * allowed_origins [Array<String>] the allowed origins
    # * allowed_methods [Array<String>] the allowed methods
    # * allowed_headers [Array<String>] the allowed headers
    # * expose_headers [Array<String>] the expose headers
    # * max_age_seconds [Integer] the max age seconds
    class CORSRule < Struct::Base

      attrs :allowed_origins, :allowed_methods, :allowed_headers,
            :expose_headers, :max_age_seconds

    end # CORSRule

  end # OSS
end # Aliyun