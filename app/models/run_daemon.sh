ruby listener_daemon.rb /home/kenb/development/RESTful-Message-Beans inventory \
  '<opt>  \
    <subscriber port=61613 url=\"/topic/inventory\" host=\"localhost\" password=\"\" user=\"\" /> \
    <receiver delivery_url=\"http://localhost:3000/documents/new\" login_url=\"http://localhost:3000/login\" password=\"hypsemikerge\" user=\"listener_daemon_inventory\" /> \
  </opt> '
