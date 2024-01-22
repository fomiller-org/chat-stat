#!/bin/bash
# aws --region us-east-1 timestream-write write-records \
# --database-name fomiller \
# --table-name chat-stat \
# --common-attributes "{\"Dimensions\":[{\"Name\":\"emote\", \"Value\":\"pog\"},{\"Name\":\"channel\", \"Value\":\"moonmoon\"},{\"Name\":\"extension\", \"Value\":\"twitch\"},{\"Name\":\"platform\", \"Value\":\"twitch\"}], \"Time\":\"1631051324000\",\"TimeUnit\":\"MILLISECONDS\"}" \
# --records "[{\"MeasureName\":\"count\", \"MeasureValueType\":\"DOUBLE\",\"MeasureValue\":\"1\"}]"

aws --region us-east-1 timestream-write write-records \
--database-name test-db \
--table-name chat-stat \
--common-attributes "{\"Dimensions\":[{\"Name\":\"asset_id\", \"Value\":\"100\"}], \"Time\":\"1631051324000\",\"TimeUnit\":\"MILLISECONDS\"}" \
--records "[{\"MeasureName\":\"temperature\", \"MeasureValueType\":\"DOUBLE\",\"MeasureValue\":\"30\"},{\"MeasureName\":\"windspeed\", \"MeasureValueType\":\"DOUBLE\",\"MeasureValue\":\"7\"},{\"MeasureName\":\"humidity\", \"MeasureValueType\":\"DOUBLE\",\"MeasureValue\":\"15\"},{\"MeasureName\":\"brightness\", \"MeasureValueType\":\"DOUBLE\",\"MeasureValue\":\"17\"}]"


