require 'json'
require 'awspec'

json_file_path = 'spec/output.json'
$tfvars = JSON.parse(File.read(json_file_path))

describe autoscaling_group($tfvars["asg_id"]["value"]), region: $tfvars["region"]["value"] do
  it { should exist }
end
