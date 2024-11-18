#!/bin/bash
#Time Calculation
export TZ='Asia/Kolkata'
current_time=$(date +'%H:%M')
echo "current time in IST : $current_time"
start_time="13:00"
end_time="21:30"

# Grafana details
GRAFANA_URL="https://oncall-prod-us-central-0.grafana.net"
# This token is for kumar-manish1@abc.com
API_KEY="e202f8dab03d9a47aa63f6482aff7a6bc9f920252683113638d0cfda670dd073"
#This is for kumar-manish1@abc-software.com
#API_KEY="7fafa9b338b3844b9cb6f45f247cd3b04a2094d398f0acc6d1b593fd341635ca"
# This is API Key found from on call settings in opsalert stack
STATE="new"
SXSRE_TEAM_ID="TCERMHFYGQ42L"

# Endpoints
ALERTS_ENDPOINT="$GRAFANA_URL/oncall/api/v1/alert_groups/?state=$STATE&team_id=$SXSRE_TEAM_ID"
ACKNOWLEDGE_ENDPOINT="$GRAFANA_URL/oncall/api/v1/alert_groups"

# Acknowledge alerts in the "firing" state
acknowledge_firing_alert() {
        if [[ "$current_time" > "$start_time" || "$current_time" == "$start_time" ]] || [[ "$current_time" < "$end_time" || "$current_time" == "$end_time" ]];
        then
         firing_alerts_ids=$(curl --max-time 300 "$ALERTS_ENDPOINT" --request GET --header "Authorization: $API_KEY" --header "Content-Type: application/json" | grep state | jq -r '.results[].id')
 
           if [[ -z "$firing_alerts_ids" ]];
           then
              echo "No firing alerts found."
           else
                for alert_id in $firing_alerts_ids;
                do
                  echo "Acknowledging alert with ID: $alert_id"
                  curl --max-time 300 "$ACKNOWLEDGE_ENDPOINT/$alert_id"  --request GET --header "Authorization: $API_KEY" | jq -r '.title'
                  curl --max-time 300 "$ACKNOWLEDGE_ENDPOINT/$alert_id/acknowledge" --request POST --header "Authorization: $API_KEY"
                  echo "Acknowledged alert with id : $alert_id"
                done
           fi
        else
           echo "This is not your shift time. Current time in IST is : $current_time"
        fi


}

# Main function
acknowledge_firing_alert
