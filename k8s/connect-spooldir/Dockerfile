FROM confluentinc/cp-kafka-connect:5.1.2
  
ENV CONNECT_PLUGIN_PATH="/usr/share/java,/usr/share/confluent-hub-components"

RUN  confluent-hub install --no-prompt jcustenborder/kafka-connect-spooldir:1.0.37
RUN mkdir -p /usr/share/spooldir/source
RUN mkdir -p /usr/share/spooldir/finished
RUN mkdir -p /usr/share/spooldir/error
