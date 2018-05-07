#
# Cookbook:: bjc_windows_bootstrap
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
powershell_script 'Set host file so the instance knows where to find chef-server' do
    code <<-EOH
    $hosts = "34.211.143.194 chef.automate-demo.com"
    $file = "C:\\Windows\\System32\\drivers\\etc\\hosts"
    $hosts | Add-Content $file
    EOH
  end
  
  powershell_script 'Create first-boot.json' do
    code <<-EOH
    $firstboot = @{
       "run_list" = @("role[base]")
    }
    Set-Content -Path c:\\chef\\first-boot.json -Value ($firstboot | ConvertTo-Json -Depth 10)
    EOH
  end
    
  powershell_script 'Create first-boot.json2' do
    code <<-EOH
    $nodeName = "lab-win-{0}" -f (-join ((65..90) + (97..122) | Get-Random -Count 4 | % {[char]$_}))
  
    $clientrb = @"
  chef_server_url 'https://chef.automate-demo.com/organizations/automate'
  validation_client_name 'validator'
  validation_key 'C:\\Users\\Administrator\\AppData\\Local\\Temp\\kitchen\\cookbooks\\myiis\\recipes\\validator.pem'
  node_name '{0}'
  "@ -f $nodeName
  
    Set-Content -Path c:\\chef\\client.rb -Value $clientrb
    EOH
  end
  powershell_script 'Run Chef' do
    code <<-EOH
    ## Run Chef
    C:\\opscode\\chef\\bin\\chef-client.bat -j C:\\chef\\first-boot.json
    EOH
  end

