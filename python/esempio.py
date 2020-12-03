import requests
from requests.structures import CaseInsensitiveDict

url = "https://ws-a.geninfo.it/rest/api/Autenticazione"

headers = CaseInsensitiveDict()
headers["Content-Type"] = "application/json"

data = """
{"apiKey": "apikey00-del0-mio0-0000-progetto0000",
          "nonce": "123456",
          "userName": "il-mio-username",
          "improntaPwd": "la-mia-impronta-sha256",
          "idDispositivo": "il-mio-dispositivo"}
"""


resp = requests.post(url, headers=headers, data=data)

print(resp.status_code)

