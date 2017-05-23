aws_template_format_version '2010-09-09'
resources.my_distribution do
  type 'AWS::CloudFront::Distribution'
  properties do
    distribution_config do
      origins _array(
        -> {
          domain_name 'mybucket.s3.amazonaws.com'
          id 'myS3Origin'
          s3_origin_config do
            origin_access_identity 'origin-access-identity/cloudfront/E127EXAMPLE51Z'
          end
        },
      )
      enabled 'true'
      comment 'Some comment'
      default_root_object 'index.html'
      logging do
        include_cookies 'false'
        bucket 'mylogs.s3.amazonaws.com'
        prefix 'myprefix'
      end
      aliases ["mysite.example.com", "yoursite.example.com"]
      default_cache_behavior do
        allowed_methods ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
        target_origin_id 'myS3Origin'
        forwarded_values do
          query_string 'false'
          cookies do
            forward 'none'
          end
        end
        trusted_signers ["1234567890EX", "1234567891EX"]
        viewer_protocol_policy 'allow-all'
      end
      price_class 'PriceClass_200'
      restrictions do
        geo_restriction do
          restriction_type 'whitelist'
          locations ["AQ", "CV"]
        end
      end
      viewer_certificate do
        cloud_front_default_certificate 'true'
      end
    end
  end
end