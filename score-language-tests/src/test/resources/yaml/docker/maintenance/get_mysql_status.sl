#   (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0

##################################################################################################################################################
# This operation retrieves the MySQL server status.
# Inputs:
#    - container - name or ID of the docker container that runs MySQL
#    - host - docker machine host
#    - username - docker machine username
#    - password - docker machine password
#    - mysqlUsername - MySQL instance username
#    - mysqlPassword - MySQL instance password
#
# Outputs:
#    - uptime - The number of seconds the MySQL server has been running.
#    - threads - The number of active threads (clients).
#    - questions - The number of questions (queries) from clients since the server was started.
#    - slowQueries - The number of queries that have taken more than long_query_time(MySQL system variable) seconds
#    - opens - The number of tables the server has opened.
#    - flushTables - The number of flush-*, refresh, and reload commands the server has executed.
#    - openTables - The number of tables that currently are open.
#    - queriesPerSecondAVG - an average value of the number of queries in a second
#    - errorMessage - contains the STDERR of the machine if the shh action was executed successfully, the cause of the exception otherwise
#
# Results:
#    - SUCCESS - the action was executed successfully and STDERR of the machine contains no errors
#    - FAILURE
##################################################################################################################################################

namespace: docker.maintenance

operations:
  - get_mysql_status:
        inputs:
          - container
          - host
          - port:
                default: "'22'"
                override: true
          - username
          - password
          - privateKeyFile:
                default: "''"
                override: true
          - arguments:
                default: "''"
                override: true
          - mysqlUsername
          - mysqlPassword
          - execCmd:
                default: "'mysqladmin -u ' + mysqlUsername + ' -p' + mysqlPassword + ' status'"
                override: true
          - command:
                default: "'docker exec ' + container + ' ' + execCmd"
                override: true
          - characterSet:
                default: "'UTF-8'"
                override: true
          - pty:
                default: "'false'"
                override: true
          - timeout:
                default: "'90000'"
                override: true
          - closeSession:
                default: "'false'"
                override: true
        action:
          java_action:
            className: org.openscore.content.ssh.actions.SSHShellCommandAction
            methodName: runSshShellCommand
        outputs:
          - uptime: "returnResult.replace(':', ' ').split('  ')[1]"
          - threads: "returnResult.replace(':', ' ').split('  ')[3]"
          - questions: "returnResult.replace(':', ' ').split('  ')[5]"
          - slowQueries: "returnResult.replace(':', ' ').split('  ')[7]"
          - opens: "returnResult.replace(':', ' ').split('  ')[9]"
          - flushTables: "returnResult.replace(':', ' ').split('  ')[11]"
          - openTables: "returnResult.replace(':', ' ').split('  ')[13]"
          - queriesPerSecondAVG: "returnResult.replace(':', ' ').split('  ')[15]"
          - errorMessage: STDERR if returnCode == '0' else returnResult
        results:
          - SUCCESS : returnCode == '0' and (not 'Error' in STDERR)
          - FAILURE
