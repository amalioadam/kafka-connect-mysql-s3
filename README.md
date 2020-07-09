# End-to-end demo of Kafka streams used during presentations

The sample project:

* sets up Kafka broker, Kafka Connect,  MySql database and AWS S3 mock
* configures Debezium source  connector to capture and stream data changes from MySql to Kafka broker
* configures S3 sink connector to stream the events from Kafka broker to AWS S3

#Requirement
* Installed docker ( configured with min 4096 MiB RAM)
https://docs.docker.com/get-docker/
* Installed AWS client 
https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html
* Optionally installed HTTPie 
https://httpie.org/
  
## How to run it  
### run the environment
  *  open a new terminal window under the root project directory and execute
  ```
  docker-compose up
  ```
### check if the broker is running 
  
  * go to console in your browser
  ```
    http://localhost:3030/
  ```
  
### check the database 
  
  * connect to the database ( open a new terminal window under the root project directory )
  ```
  docker-compose exec mysql bash -c 'mysql -u mysqluser -pmysqlpw inventory'
  ```
  * verify the table  
  ```sql
     show tables;
     describe cars;
    select * from cars;
  ```
  
### check if AWS S3 mock is available and create the bucket  
  * configure 'mock' profile for the S3 client (open a new terminal window)
    ```
    aws configure --p mock
    AWS Access Key ID [None]: AWS_ACCESS_KEY_ID
    AWS Secret Access Key [None]: AWS_SECRET_ACCESS_KEY
    Default region name [eu-west-1]: eu-east-1
    Default output format [None]: json
    ```
  * create bucket
    ```
    aws --endpoint-url=http://localhost:5000 s3 mb s3://test-bucket --p mock
    ```
  * list bucket (result shall be empty)
    ```
    aws --endpoint-url=http://localhost:5000 s3api list-objects --bucket test-bucket --p mock
    ```
### register Debezium source connector   
    
   * in the terminal window execute
   ```
    cat register-src-connector.json | http POST http://localhost:8083/connectors/
   ```
   * check the connector status 
    
   ```
    http localhost:8083/connectors/src-connector/status
   ```
   or in the browser
   ```
    http://localhost:3030/kafka-connect-ui/#/cluster/fast-data-dev/connector/src-connector
   ```
    
### check data are present in a Kafka topic    
    
   * in the browser go to
   
   ```
   http://localhost:3030/kafka-topics-ui/#/cluster/fast-data-dev/topic/n/dbserver1_inventory_cars/
   ```
   records from the table shall be present in the kafka topic 
    
###  register S3 sink connector   
   * in the terminal window execute
   
  ```
    cat register-sink-s3-connector.json | http POST http://localhost:8083/connectors/
  ```
   * check the status 
   ```
    http localhost:8083/connectors/s3-sink-connector/status
   ```
   or in the browser
   ```
    http://localhost:3030/kafka-connect-ui/#/cluster/fast-data-dev/connector/s3-sink-connector
   ```
### verify if records are sent to S3 bucket   
 * list bucket (result shall be empty)
    ```
     aws --endpoint-url=http://localhost:5000 s3api list-objects --bucket test-bucket --p mock
    ```  
  or via http
  ```
  http://localhost:5000/test-bucket
  ```
  and download it 
  ```
  aws --endpoint-url=http://localhost:5000 s3api get-object --bucket test-bucket --key topics/dbserver1_inventory_cars/partition=0/dbserver1_inventory_cars+0+0000000000.json cars1.json
  ```

## Process changes in real time
### Change table content 

* execute the sql commands in Mysql terminal 
```sql
INSERT INTO cars (car_id, brand, model, ts_created) VALUES ( 3, 'ford', 'ka', '2020-07-06 16:50:47');
UPDATE cars set model="nitro" WHERE car_id=2;
DELETE from cars WHERE car_id=1;
```
* check the result in  S3 (in separate terminal window)
```
 aws --endpoint-url=http://localhost:5000 s3api list-objects --bucket test-bucket --p mock
```  

### Change table structure(adding columns) in the database via MySQL client
```sql
ALTER TABLE cars ADD COLUMN type VARCHAR(15);
```  
* check the result in Kafka topic

  http://localhost:3030/kafka-topics-ui/#/cluster/fast-data-dev/topic/n/schema-changes.inventory/
  
# Good practices
Create dedicated DB user with limited rights to be used by source connector.
Configure credentials in a config provider (https://docs.confluent.io/current/connect/security.html#externalizing-secrets) 
Monitor the platform  https://docs.confluent.io/current/connect/managing/monitoring.html

# Links 
https://github.com/lensesio/fast-data-dev
https://debezium.io/
https://docs.confluent.io/2.0.0/connect/
https://debezium.io/docs/connectors/mysql/#data-types