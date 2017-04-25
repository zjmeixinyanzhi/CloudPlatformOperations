#!/usr/bin/env python
from openstack import connection
conn = connection.Connection(auth_url="http://192.168.100.201:5000/v3",
                             project_name="admin",
                             username="admin",
                             password="123456")
for container in conn.object_store.containers():
   print(container.name)
