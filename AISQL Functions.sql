create or replace database AISQL_DB;

use AISQL_DB;

create or replace schema AISQL_SCHEMA;

ALTER ACCOUNT SET CORTEX_ENABLED_CROSS_REGION ='ANY_REGION'

--AI_COMPLETE(Single String)

SELECT AI_COMPLETE('gemma-7b', 'Write a Python Program to find whether the given number is even or not');


SELECT AI_COMPLETE(
    model => 'llama2-70b-chat',
    prompt => 'how does a snowflake get its unique pattern?',
    model_parameters => {
        'temperature': 0.7,
        'max_tokens': 10
    },
    show_details=>True
);


--AI_COMPLETE(Single Image)

create or replace stage AI_STAGE;

list @AISQL_DB.AISQL_SCHEMA.AI_STAGE
--uploaded a tiger image to the stage

ALTER STAGE AISQL_DB.AISQL_SCHEMA.AI_STAGE SET ENCRYPTION=(TYPE='SNOWFLAKE_SSE')

show stages;


select AI_COMPLETE('openai-gpt-4.1','Analyze the image and give me the details and what the image describe about?',
TO_FILE('@AISQL_DB.AISQL_SCHEMA.AI_STAGE','Tiger.jpg'))


--AI_COMPLETE(Prompt Object)
select AI_COMPLETE('openai-gpt-4.1',PROMPT('Are the both dog images {0} and {1} are same?',
TO_FILE('@AISQL_DB.AISQL_SCHEMA.AI_STAGE','Dog_image1.jpg'),TO_FILE('@AISQL_DB.AISQL_SCHEMA.AI_STAGE','Dog_image2.jpg'))) as image_classification
--For batch processing of images we can use directory tables




--AI_CLASSIFY

SELECT AI_CLASSIFY('One day I will see the world', ['travel', 'cooking']),

'{
  "labels": ["travel"]
 }';

SELECT AI_CLASSIFY('One day I will see the world and learn to cook my favorite dishes', ['travel', 'cooking', 'reading', 'driving'], {'output_mode': 'multi'}),

'{
  "labels": ["travel", "cooking"]
 }';


select AI_CLASSIFY('One day I will see the world and learn to cook my favorite dishes',
  [
    {'label': 'travel', 'description': 'content related to traveling'},
    {'label': 'cooking'},
    {'label': 'reading'},
    {'label': 'driving'}
  ],
{
    'task_description': 'Determine topics related to the given text',
    'output_mode': 'multi',
    'examples': [
      {
        'input': 'i love traveling with a good book',
        'labels': ['travel', 'reading'],
        'explanation': 'the text mentions traveling and a good book which relates to reading'
      }
    ]
  }),
  '{
  "labels": ["travel", "cooking"]
}';


create or replace temporary table text_classification_table AS
select 'France' AS input, ['North America', 'Europe', 'Asia'] AS classes
UNION ALL
SELECT 'Singapore', ['North America', 'Europe', 'Asia']
UNION ALL
SELECT 'one day I will see the world', ['travel', 'cooking', 'dancing']
UNION ALL
SELECT 'my lobster bisque is second to none', ['travel', 'cooking', 'dancing'];


select * from text_classification_table

select input,classes,
AI_CLASSIFY(input,classes):labels AS classification
from text_classification_table;



--PARSE DOCUMENTS

list @AI_STAGE;

select TO_VARCHAR(SNOWFLAKE.CORTEX.PARSE_DOCUMENT('@AI_STAGE','dev-example.pdf',{'mode': 'OCR'})) AS OCR

select TO_VARCHAR(SNOWFLAKE.CORTEX.PARSE_DOCUMENT('@AI_STAGE','dev-example.pdf',{'mode': 'LAYOUT'})) AS LAYOUT


"""Model allow list"""
ALTER ACCOUNT SET CORTEX_MODELS_ALLOWLIST = 'All';

CALL SNOWFLAKE.MODELS.CORTEX_BASE_MODELS_REFRESH();

SHOW MODELS IN SNOWFLAKE.MODELS;

SHOW APPLICATION ROLES IN APPLICATION SNOWFLAKE;


--Snowflake Rest API LLM


GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER To ROLE ACCOUNTADMIN;
GRANT role ACCOUNTADMIN to user SNOWFLAKEPRACTICE22;



 --vector_inner_product
 CREATE TABLE vectors (a VECTOR(FLOAT, 3), b VECTOR(FLOAT, 3));

 INSERT INTO vectors SELECT [1.1,2.2,3]::VECTOR(FLOAT,3), [1,1,1]::VECTOR(FLOAT,3);
INSERT INTO vectors SELECT [1,2.2,3]::VECTOR(FLOAT,3), [4,6,8]::VECTOR(FLOAT,3);



select * from vectors


select vector_inner_product(a,b) from vectors

select vector_l1_distance(a,b) from vectors


select vector_l2_distance(a,b) from vectors


select vector_cosine_similarity(a,b) from vectors

--Entity Sentiment

select snowflake.cortex.ENTITY_SENTIMENT('A tourist\'s delight, in low urban light,
  Recommended gem, a pizza night sight.  Swift arrival, a pleasure so right,
  Yet, pockets felt lighter, a slight pricey bite. 💰🍕🚀',
  ['Cost','Waiting Time','Quality']
  )


select snowflake.cortex.ENTITY_SENTIMENT('A tourist\'s delight, in low urban light,
  Recommended gem, a pizza night sight.  Swift arrival, a pleasure so right,
  Yet, pockets felt lighter, a slight pricey bite. 💰🍕🚀',
  ['Cost','Professionalism','Brand']
  )


  SELECT SNOWFLAKE.CORTEX.SENTIMENT('A tourist\'s delight, in low urban light,
  Recommended gem, a pizza night sight. Swift arrival, a pleasure so right,
  Yet, pockets felt lighter, a slight pricey bite. 💰🍕🚀');

--Fine Tuning

  SELECT *
  FROM SNOWFLAKE.ACCOUNT_USAGE.CORTEX_FINE_TUNING_USAGE_HISTORY;


  GRANT CREATE MODEL ON SCHEMA AISQL_SCHEMA TO ROLE ACCOUNTADMIN


create or replace table support_tickets(
TICKETID varchar(100),
customer_name varchar(100),
customer_email varchar(100),
service_type varchar(100),
request varchar(100),
contact_preference varchar(100)
)

select * from support_tickets


SET prompt = 'You are an agent that helps organize the requests that come to your support team
The request category is the reason why the customer reached out. These are the possible types of request categories
Slow performance
Product Info
Account Management
Billing
Technical Support
';

select snowflake.cortex.finetune(
'CREATE',
'my_tuned_model',
'mistral-7b',
'select PROMPT(prompt) as prompt,request as completion from support_tickets'
)




