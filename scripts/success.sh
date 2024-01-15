#!/bin/bash
token=$1

aws stepfunctions send-task-success --region us-east-1 --task-output "{}" --task-token $1
