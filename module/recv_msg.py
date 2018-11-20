#!/usr/bin/env python

# WARNING: This file is deployed from template. Raise a pull request against terraform-template to change.

import boto3
import json
import sys
import re
import argparse
import time
import os

parser = argparse.ArgumentParser()
parser.add_argument('--env', required=True)
parser.add_argument('--region', required=True)
parser.add_argument('--envtype', required=True)
parser.add_argument('--resource', required=True)
parser.add_argument('--count', default=1)
parser.add_argument('--threshold', default=1)
parser.add_argument('--skip', dest='skip', type=lambda x:bool(x.lower() == "true"), default='false')
args = parser.parse_args()

if args.skip == True:
    sys.exit(0)

env = args.env
region = args.region
envtype = args.envtype
resource = args.resource
count = int(args.count)

# script timeout after 30 mins
t_end = time.time() + 60 * os.getenv("RECV_TIMEOUT", 30)

# Get the service resource
sqs = boto3.resource('sqs', region_name=region)

# Get the queue
queuename = resource + "-" + env + "-" + envtype
print queuename

queue = sqs.get_queue_by_name(QueueName=queuename)

#if count > threshold don't print all data, just the results
threshold = int(args.threshold)
currcount = 0

print "count: %i\nthreshold: %i" % (count, threshold)

res = {}
res["instances"] = {}
res["name"] = resource
while True:
    if time.time() > t_end:
        print json.dumps(res, sort_keys=True, indent=2)
        print("Timeout")
        sys.exit(77)
    # Process messages by printing out body and optional author name
    for message in queue.receive_messages():

        # Get the custom author message attribute if it was set
        body = json.loads(message.body)
        print body['Message']

        # Let the queue know that the message is processed
        message.delete()

        # ok=7    changed=0    unreachable=0    failed=0
        r = re.compile('(\S+)\s+.*ok=.*changed=.*unreachable.*failed=(\d+)')
        match = r.search(body['Message'])
        if match != None:
            res["instances"][match.group(1)] = match.group(2)
            currcount += 1

    if currcount == count:
        failcount = 0
        for inst in res["instances"]:
            if res["instances"][inst] != "0":
                failcount += 1

        print resource + " done. Ansible fail counts:"
        print json.dumps(res, sort_keys=True, indent=2)
        sys.exit(failcount)