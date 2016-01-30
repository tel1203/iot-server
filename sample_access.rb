# coding: utf-8
require "./iot-access.rb"

serv=IoTAccess.new()

# Ex: data registration
res=serv.put("ABCDEF", "12345")
p res

# Ex: data reading
res=serv.get("ABCDEF")
p res

# Check response from server 
puts("code -> #{res.code}")
puts("msg -> #{res.message}")
puts("body -> #{res.body}")

