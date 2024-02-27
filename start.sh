#! /bin/bash
# this script is added to create db_vero_digital if it does not exist

Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White
Color_Off='\033[0m'

docker-compose up -d  || echo "failed"

if [[ $? -ne 0 ]]; then
    echo "you need to install docker-compose"
else
    var_sql_server_state=$(docker ps -a --filter "name=\bvero-sql-server\b" --format "table {{.Status}}" | grep -o  Up)
    if [[ ! -z $var_sql_server_state ]]; then

            echo -e "${Yellow}info: vero-sql-server container is running"
            echo -e "${Yellow}info: waiting for mssql service"
            var_create_vero_db_result=$(docker exec -it vero-sql-server sh -c '/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P Un!q@to2023 -Q "CREATE DATABASE db_vero_digital"')
            var_create_vero_db_result_Failed=$(echo $var_create_vero_db_result | grep  -o "^Sqlcmd: Error")
            echo $var_create_vero_db_result_Failed
            if [[ $var_create_vero_db_result_Failed == "Sqlcmd: Error" ]]; then
                echo -e "${Yellow}info:mssql service is not ready."
                var_sql_socket_ready="Sqlcmd: Error"
                counter_st=0
                echo -e "${Yellow}info:will stop retrying after 10 attempts."
                while [[ $var_sql_socket_ready =~ "Sqlcmd: Error" ]]; do
                    echo -e "${Color_Off}Retrying...."
                    var_sql_socket_ready=$(docker exec -it vero-sql-server sh -c '/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P Un!q@to2023 -Q "CREATE DATABASE db_vero_digital"')
                    echo -e "${Red} $var_sql_socket_ready"
                    counter_st=$(($counter_st + 1))
                     if [[ $counter_st == "10" ]]; then
                        exit 1
                     fi
                    sleep 5
			    done
                 echo -e "${Color_Off}Sql service is ready"
            else
               echo -e "${Color_Off}Sql service is ready"
            fi
    else    
                echo "we couldn't find sql server container"
    fi

fi
