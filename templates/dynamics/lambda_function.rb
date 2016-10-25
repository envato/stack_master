SparkleFormation.dynamic(:lambda_function) do |_name, _config = {}|
  resources.set!("#{_name}") do
    type "AWS::Lambda::Function"
    properties do
      description _config.fetch(:description)
      function_name "#{_name}"
      handler _config.fetch(:handler)
      memory_size _config.fetch(:memorysize)
      role _config.fetch(:role)
      runtime _config.fetch(:runtime)
      timeout _config.fetch(:timeout)
      code do
        zip_file _config.fetch(:code)
      end
    end
  end

  outputs.set!("#{_name}") do
    description "Function ARN"
    value ref!("#{_name}".to_sym)
  end
end
