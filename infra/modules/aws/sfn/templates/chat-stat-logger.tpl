{
  "StartAt": "Create Chat Stat Logger Deployment",
      "States": {
          "Create Chat Stat Logger Deployment": {
              "Type": "Task",
              "Resource": "arn:aws:states:::eks:call",
              "InputPath": "$.deployment",
              "Parameters": {
                  "ClusterName": "${cluster_name}",
                  "CertificateAuthority": "${cluster_certificate}",
                  "Endpoint": "${cluster_endpoint}",
                  "Method": "POST",
                  "Path": "/apis/apps/v1/namespaces/${namespace}/deployments",
                  "RequestBody": {
                      "apiVersion": "apps/v1",
                      "kind": "Deployment",
                      "metadata": {
                          "name.$": "States.Format('chat-stat-logger-{}', $.stream_id)",
                          "namespace": "${namespace}"
                      },
                      "spec": {
                          "replicas": 1,
                          "revisionHistoryLimit": 1,
                          "selector": {
                              "matchLabels": {
                                  "app.$": "States.Format('chat-stat-logger-{}', $.stream_id)",
                                  "channel.$": "$.stream_id"
                              }
                          },
                          "template": {
                              "metadata": {
                                  "labels": {
                                      "app.$": "States.Format('chat-stat-logger-{}', $.stream_id)",
                                      "channel.$": "$.stream_id",
                                      "kubernetes.io/arch": "amd64"
                                  }
                              },
                              "spec": {
                                  "serviceAccountName": "fargate-chat-stat",
                                  "nodeSelector": {
                                    "kubernetes.io/arch": "amd64"
                                  },
                                  "containers": [
                                  {
                                      "name": "chat-stat-logger",
                                      "image": "695434033664.dkr.ecr.us-east-1.amazonaws.com/fomiller-chat-stat-logger:latest",
                                      "env": [
                                      {
                                          "name": "REDIS_HOST",
                                          "value": "redis-db-master.redis.svc.cluster.local"
                                      },
                                      {
                                          "name": "TWITCH_CHANNEL",
                                          "value.$": "$.stream_id"
                                      },
                                      {
                                          "name": "TWITCH_CLIENT_SECRET",
                                          "value": "${twitch_client_secret}"
                                      },
                                      {
                                          "name": "TWITCH_CLIENT_ID",
                                          "value": "${twitch_client_id}"
                                      }
                                      ]
                                  }
                                  ]
                              }
                          }
                      }
                  }
              },
              "Retry": [{
                  "ErrorEquals": [ "States.ALL" ],
                  "IntervalSeconds": 30,
                  "MaxAttempts": 2,
                  "BackoffRate": 2
              }],
              "ResultPath": null,
              "Next": "Save TaskToken"
          },
          "Save TaskToken": {
              "Type": "Task",
              "Resource": "arn:aws:states:::aws-sdk:dynamodb:updateItem.waitForTaskToken",
              "Parameters": {
                  "TableName": "fomiller-chat-stat",
                  "Key": {
                      "StreamId": {
                          "S.$": "$.deployment.stream_id"
                      }
                  },
                  "UpdateExpression": "SET TaskToken = :tt",
                  "ExpressionAttributeValues": {
                      ":tt": {
                          "S.$": "$$.Task.Token"
                      }
                  }
              },
              "Retry": [{
                  "ErrorEquals": [ "States.ALL" ],
                  "IntervalSeconds": 30,
                  "MaxAttempts": 2,
                  "BackoffRate": 2
              }],
              "ResultPath": null,
              "Next": "Delete Chat Stat Logger Deployment"
          },
          "Delete Chat Stat Logger Deployment": {
              "Type": "Task",
              "Resource": "arn:aws:states:::eks:call",
              "InputPath": "$.deployment",
              "Parameters": {
                  "ClusterName": "${cluster_name}",
                  "CertificateAuthority": "${cluster_certificate}",
                  "Endpoint": "${cluster_endpoint}",
                  "Method": "DELETE",
                  "Path.$": "States.Format('/apis/apps/v1/namespaces/${namespace}/deployments/chat-stat-logger-{}', $.stream_id)"
              },
              "Retry": [{
                  "ErrorEquals": [ "States.ALL" ],
                  "IntervalSeconds": 30,
                  "MaxAttempts": 2,
                  "BackoffRate": 2
              }],
              "End": true
          }
      }
}
