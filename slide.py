import urllib3
import json
from datetime import datetime
import os

# Api documentatie op https://documenter.getpostman.com/view/6223391/S1Lu2pSf?version=latest#intro
# Make sure you have the environment settings slide_email and slide_password set
# In AWS: in the Environment variables box at the source code page
# In PyCharm: in the Run -> Edit Configurations dialog box

BASE_URL = 'https://api.goslide.io/api/'
BASE_HEADERS = {'Content-Type': 'application/json', 'X-Requested-With': 'XMLHttpRequest'}

class Slide():
    def __init__(self):
        self.ensure_login()
        self.overview = self.get_overview()

    def ensure_login(self):
        def str2dt(s):
            return datetime.strptime(s, '%Y-%m-%d %H:%M:%S')

        exp = os.environ.get( 'expires_at')
        if not exp or str2dt(exp).date() <= datetime.today().date():
            # Logon when there is no settings file and therefore no Key or when settings are expired
            self.login()

    def login(self):
        url = BASE_URL + "auth/login"

        email = os.environ['slide_email']
        password = os.environ['slide_password']

        payload = f'{{"email": "{email}","password": "{password}"\n}}'
        response_json = request("POST", url, headers=BASE_HEADERS, data=payload)
        os.environ['token'] = response_json['access_token']
        os.environ['expires_at'] = response_json['expires_at']
        os.environ['household_id'] = str(response_json['household_id'])

    def get_overview(self):
        headers = self.authorisation_headers()
        response_json = request("GET", BASE_URL + 'slides/overview', headers=headers)
        overview = {}
        for item in response_json['slides']:
            overview[item['device_name']] = {'id': item['id'], 'pos': item['device_info']['pos']}
        return overview

    def get_position(self, name):
        id = self.overview[name]['id']
        url = BASE_URL + f"slide/{id}/info"
        headers = self.authorisation_headers()
        response_json = request("GET", url, headers=headers)
        return response_json['data']['pos']

    def move(self, name, pos):
        id = self.overview[name]['id']
        url = BASE_URL + f"slide/{id}/position"
        headers = self.authorisation_headers()
        payload = f'{{"pos":{pos}\n}}'
        request("POST", url, headers=headers, data = payload)
        print( f"Slide '{name}' moved to {pos}." )

    def print_overview(self):
        print(json.dumps(self.overview, indent=4, sort_keys=True))

    def authorisation_headers(self):
        h = BASE_HEADERS
        h.update({ 'Authorization': 'Bearer ' + os.environ['token']})
        return h

def request(protocol, url, headers, data={}):
    http = urllib3.PoolManager()
    response_data = http.urlopen(protocol, url, headers=headers, body=data).data
    return json.loads( response_data )

if __name__=='__main__':
    sl = Slide()
    sl.print_overview()
    sl.move("Livingroom", .1)
    sPosition = f'Slide is at position {sl.get_position("Livingroom")}'
    print(sPosition )
