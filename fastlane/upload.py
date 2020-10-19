# -*- coding: utf-8 -*-


import requests
import random,string
from requests_toolbelt import MultipartEncoder
import argparse
import os

def send_request(filePath, versionID, token):
    # cURL
    # POST https://cod.xinhoo.com:9091/plugins/xhcodrestapi/v1/updateservice/addVersion

    with open(filePath,'rb') as fp:
        file_data = fp.read()

    fields={'file':(os.path.basename(filePath),file_data,"binary"),'versionID':versionID} # 这里的data可以是open()打开的文件流，还可以是一切具有read()方法的对象
    m=MultipartEncoder(fields=fields,boundary='----WebKitFormBoundary'+''.join(random.sample(string.ascii_letters+string.digits,16)))

    headers={
                "Connection": "keep-alive",
                "Accept": "application/json, text/plain, */*",
                "Sec-Fetch-Dest": "empty",
                "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36",
                "Token": token,
                "Content-Type": m.content_type,
                "Origin": "https://cod.xinhoo.com",
                "Sec-Fetch-Site": "same-site",
                "Sec-Fetch-Mode": "cors",
                "Referer": "https://cod.xinhoo.com/webadmin/",
                "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8",
                "Accept-Encoding": "gzip",
            }

    r=requests.post('https://cod.xinhoo.com:9091/plugins/xhcodrestapi/v1/updateservice/addVersion', headers=headers,data=m)

    print(r.text)

parser = argparse.ArgumentParser(description='manual to this script')
parser.add_argument('--version-id', type=str, default = None)
parser.add_argument('--file', type=str, default = None)
parser.add_argument('--token', type=str, default = None)
args = parser.parse_args()
send_request(filePath=args.file, versionID=args.version_id, token=args.token)