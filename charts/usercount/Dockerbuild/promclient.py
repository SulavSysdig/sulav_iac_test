from flask import Flask, Response
import datetime
import os
import random
import time
import os.path

app = Flask(__name__)

@app.route('/metrics')
def metrics():
    now = datetime.datetime.now()
    if (now.weekday()) == 6 or now.weekday() == 2  or os.path.exists("./error"):
        try:
            metricslog = open("/metrics/metricsdigest.log")
        except IOError, e:
            print e
            return "Internal Server Error: " + str(e),500
    else:
      metric = "# HELP current_active_users Users logged and using the interface\n# TYPE current_active_users gauge\ncurrent_active_users " + str(float(random.randint(1,100))) + "\n"
      return Response(metric, mimetype='text/plain')

if __name__ == '__main__':
    app.run(debug=False,host='0.0.0.0', port=9100)
