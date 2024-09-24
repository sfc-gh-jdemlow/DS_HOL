USE ROLE ACCOUNTADMIN;
CREATE OR REPLACE SECRET GH_SECRET
    TYPE = password
    USERNAME = '<GITHUB_USERNAME>'
    PASSWORD = '<GITHUB_PERSONAL_ACCESS_TOKEN>';
;

CREATE OR REPLACE API INTEGRATION git_api_integration
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = ('<GITHUB_REPO_URL>') -- ie: https://github.com/sfc-gh-jdemlow
  ALLOWED_AUTHENTICATION_SECRETS = all
  ENABLED = TRUE
;

GRANT USAGE ON INTEGRATION git_api_integration TO ROLE churn_data_scientist;

USE ROLE churn_data_scientist;

SHOW API INTEGRATIONS;
USE ROLE churn_data_scientist;
CREATE OR REPLACE GIT REPOSITORY DS_HOL
    API_INTEGRATION = git_api_integration
    GIT_CREDENTIALS = GH_SECRET
    ORIGIN = 'https://github.com/sfc-gh-jdemlow/DS_HOL'
;

-- See files in the repository
ls @DS_HOL/branches/main/;

USE DATABASE CHURN_PROD;
USE SCHEMA ANALYTICS;

SET NB='CHURN_PROD.ANALYTICS."Telco Churn Ingest Data"';
CREATE OR REPLACE NOTEBOOK IDENTIFIER($NB)
FROM '@CHURN_PROD.ANALYTICS.DS_HOL/branches/main/'
QUERY_WAREHOUSE = 'churn_ds_wh'
MAIN_FILE = 'notebooks/1_telco_churn_ingest_data.ipynb'
;

SET NB='CHURN_PROD.ANALYTICS."Telco Churn ML Feature Engineering"';
CREATE OR REPLACE NOTEBOOK IDENTIFIER($NB)
FROM '@CHURN_PROD.ANALYTICS.DS_HOL/branches/main/'
QUERY_WAREHOUSE = 'churn_ds_wh'
MAIN_FILE = 'notebooks/2_telco_churn_ml_feature_engineering.ipynb'
;

CREATE OR REPLACE SCHEMA DEMO;

SET NB='CHURN_PROD.DEMO."Lead Soring Cortex ML Classification Model"';
CREATE OR REPLACE NOTEBOOK IDENTIFIER($NB)
FROM '@CHURN_PROD.ANALYTICS.DS_HOL/branches/main/'
QUERY_WAREHOUSE = 'churn_ds_wh'
MAIN_FILE = 'notebooks/3_lead_scoring_cortex_ml_classification_model.ipynb'
;

-- Grab new changes from the git repository
alter git repository CHURN_PROD.ANALYTICS.DS_HOL fetch;