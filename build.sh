curl -u ""$RANCHER_USER":"$RANCHER_PASS"" \
-X POST \
-H 'Accept: application/json' \
-H 'Content-Type: application/json' \
-d '{"inServiceStrategy":{"launchConfig": {"imageUuid":"docker:80017/todo-db"}},"toServiceStrategy":null}' \
'http://162.209.122.250:8080/v2-beta/projects/1a5/services/1s416?action=upgrade'
