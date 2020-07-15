import requests
from pandas.io.json import json_normalize
r = requests.get('http://localhost:8080/ords/pdbutv1/f1_access/drivers/?limit=1000')
print(r.status_code)
print(r.headers['content-type'])
print(r.encoding)
data = r.json()
result = json_normalize(data,'items')
for index, row in result.iterrows():
    print(row['driverid'],row['givenname'],row['familyname'],row['nationality'],row['info'])
