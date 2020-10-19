#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import time
import requests
import json
import re

authorization = "eXwdrXrvrjsHDs7F"
token = "2d7ec4165bd24c1c89196582b0f8a966"
userId = "cod_60013977"

# token = "8cb76875552040cb850d492552161818"
# userId = "cod_60013981"

fastlaneENV = 'env ROBOT_TOKEN="{t}" ROBOT_USER_NAME="{u}"'.format(t=token, u=userId)

needUpdateVersion = ""
bulid_cmd = ""

def send_request_getupdates():
    # Request
    # POST https://cod.xinhoo.com:9002/rest-api/v1/robot/cod_60013977/2d7ec4165bd24c1c89196582b0f8a966/getupdates

    try:
        response = requests.post(
            url="https://cod.xinhoo.com:9002/rest-api/v1/robot/" + userId + "/" + token + "/getupdates",
            headers={
                "authorization": authorization,
                "Content-Type": "application/json; charset=utf-8",
            },
            data=json.dumps({
                "token": token,
                "userId": userId
            })
        )

        if response:
            responseData = json.loads(response.text)

            if responseData and responseData.has_key('data'):
                return responseData["data"]

        
    except requests.exceptions.RequestException:
        print('HTTP Request failed')


def send_request_sendMessage(type, tarUserName, roomname, text):
    # Request
    # POST https://cod.xinhoo.com:9002/rest-api/v1/robot/cod_60013977/2d7ec4165bd24c1c89196582b0f8a966/getupdates

    try:
        response = requests.post(
            url="https://cod.xinhoo.com:9091/plugins/xhcodrestapi/v1/apiservice/user" + userId + ":" + token + "/v2/sendmessage",
            headers={
                "authorization": authorization,
                "Content-Type": "application/json; charset=utf-8",
            },
            data=json.dumps({
                "token": token,
                "userId": userId,
                "type": type,
                "tarUserName": tarUserName,
                "roomname": roomname,
                "text": text
            })
        )

        print(response.text)

    except requests.exceptions.RequestException:
        print('HTTP Request failed')


def wantBuildIM(user_cmd):

    cmds = [
        "打IM",
        "打IM包",
        "打个IM包",
        "打个星河包",
        "打星河包",
        "打包星河",
        "打包IM"
    ]

    for cmd in cmds:
        if user_cmd.find(cmd) >= 0:
            return True

    return False

def wantBuildMango(user_cmd):

    cmds = [
        "打MANGO",
        "打MANGO包",
        "打个MANGO包",
        "打个芒果包",
        "打芒果包",
        "打包芒果",
        "打包MANGO"
    ]

    for cmd in cmds:
        if user_cmd.find(cmd) >= 0:
            return True

    return False

def wantUpdateVersion(user_cmd):
    cmds = [
        "升级版本号",
        "UPDATEVERSION",
    ]

    for cmd in cmds:
        if user_cmd.find(cmd) >= 0:
            return True

    return False

def simple_check_cmd(cmd):

    if is_answer_cmd(cmd) is True:
        return True

    if is_build_cmd(cmd) is True:
        return True

    if wantUpdateVersion(cmd) is True:
        return True
    
    return False

def is_build_cmd(cmd):

    if cmd.find("/打") == 0:
        return True
    
    return False

def is_answer_cmd(cmd):

    if cmd == "/1" or cmd == "/0":
        return True
    
    return False

def is_create_branch_release(cmd):

    # matchObj = re.match(r'\d+.\d+', cmd)
    pattern = re.compile(r'\d+.\d+分支')
    result = pattern.findall(cmd)

    print(result)

    if result:
        
        if cmd.find("/创建") == 0 or cmd.find("/拉") == 0:
            return True

    return False

def get_create_branch_release_version(cmd):
    pattern = re.compile(r'\d+.\d+')
    result = pattern.findall(cmd)
    if result.count == 1:
        return result[0]
    


def clean_cmd():
    global needUpdateVersion
    global bulid_cmd
    needUpdateVersion = ""
    bulid_cmd = ""


def create_release_branch(version):
    cli_cmd = "gcd & git delete-merged-branches & gflrs {v}".format(v=version)
    os.system(cli_cmd)


    

while True:

  responseData = send_request_getupdates()

  if responseData is not None:

      print(responseData)

      cmd_text = responseData["text"]
      tarUserName = responseData["userId"]
      roomname = responseData["chatId"]
      type = responseData["chatType"]

      if cmd_text is not None:
          cmd_text = cmd_text.upper().encode('utf-8')
          cmd_text = cmd_text.replace(" ", "")

          print(cmd_text)

        #   if cmd_text == "/TEST":
        #       cli_cmd = fastlaneENV + ' ROBOT_CHAT_TYPE="{t}" ROOM_NAME="{r}" ROBOT_TARGET_USER="{tu}" '.format(t=type, r=roomname, tu=tarUserName) + " fastlane ios sendText"
        #       print(cli_cmd)
        #       os.system(cli_cmd)


        #   if is_create_branch_release(cmd_text):
        #       cli_cmd = fastlaneENV + ' ROBOT_CHAT_TYPE="{t}" ROOM_NAME="{r}" ROBOT_TARGET_USER="{tu}" '.format(t=type, r=roomname, tu=tarUserName) + " fastlane ios sendText"
        #       print(cli_cmd)
        #       os.system(cli_cmd)


          if simple_check_cmd(cmd_text) is False:
              continue
            
          if is_build_cmd(cmd_text):
              bulid_cmd = cmd_text

          if is_answer_cmd(cmd_text) and bulid_cmd != "":
              needUpdateVersion = cmd_text

          if needUpdateVersion == "":
              send_request_sendMessage(type, tarUserName, roomname, "是否需要更新当前版本号：【是】/1， 【否】/0")
              continue
          
          if wantBuildIM(bulid_cmd):
              if needUpdateVersion == "/1":
                  os.system("fastlane ios update_version")
                # print("fastlane ios update_version")

              print(bulid_cmd)
              send_request_sendMessage(type, tarUserName, roomname, "正在为你打IM包...")
            #   print("fastlane ios im")
              os.system("fastlane ios im")
              clean_cmd()

          if wantBuildMango(bulid_cmd):

              if needUpdateVersion == "/1":
                #   print("fastlane ios update_version")
                  os.system("fastlane ios update_version")

              send_request_sendMessage(type, tarUserName, roomname, "正在为你打Mango包...")
            #   print("fastlane ios mango")
              os.system("fastlane ios mango")
              clean_cmd()

          if wantUpdateVersion(cmd_text):
            #   print("fastlane ios update_version")
              os.system("fastlane ios update_version")
              send_request_sendMessage(type, tarUserName, roomname, "版本号升级成功")

       

  time.sleep(1)