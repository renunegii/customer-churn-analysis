-- Created DataBase and imported table from the csv file
CREATE DATABASE IF NOT EXISTS customer_churn;
USE customer_churn;

CREATE TABLE stg_Churn (
    Customer_ID VARCHAR(20) PRIMARY KEY,
    Gender VARCHAR(10),
    Age INT,
    Married VARCHAR(5),
    State VARCHAR(50),
    Number_of_Referrals INT,
    Tenure_in_Months INT,
    Value_Deal VARCHAR(20),
    Phone_Service VARCHAR(5),
    Multiple_Lines VARCHAR(20),
    Internet_Service VARCHAR(5),
    Internet_Type VARCHAR(20),
    Online_Security VARCHAR(20),
    Online_Backup VARCHAR(20),
    Device_Protection_Plan VARCHAR(20),
    Premium_Support VARCHAR(20),
    Streaming_TV VARCHAR(20),
    Streaming_Movies VARCHAR(20),
    Streaming_Music VARCHAR(20),
    Unlimited_Data VARCHAR(20),
    Contract VARCHAR(20),
    Paperless_Billing VARCHAR(5),
    Payment_Method VARCHAR(20),
    Monthly_Charge DECIMAL(10,2),
    Total_Charges DECIMAL(10,2),
    Total_Refunds DECIMAL(10,2),
    Total_Extra_Data_Charges INT,
    Total_Long_Distance_Charges DECIMAL(10,2),
    Total_Revenue DECIMAL(10,2),
    Customer_Status VARCHAR(10),
    Churn_Category VARCHAR(30),
    Churn_Reason VARCHAR(100)
);
-- Here starts exploration

-- Gender distribution in Percentage
SELECT Gender, COUNT(Gender) AS TotalCount,
COUNT(Gender) * 1.0 / (SELECT COUNT(*) FROM stg_Churn) AS Percentage
FROM stg_Churn
GROUP BY Gender;

-- Contract type distribution
SELECT Contract, COUNT(Contract) AS TotalCount, 
COUNT(Contract) * 1.0 / (SELECT COUNT(*) FROM stg_Churn) AS Percentage
FROM stg_Churn
GROUP BY Contract;

-- Customer status vs revenue contribution
SELECT Customer_Status, COUNT(Customer_Status) AS TotalCount, SUM(Total_Revenue) AS TotalRev,
       SUM(Total_Revenue) / (SELECT SUM(Total_Revenue) FROM stg_Churn) * 100 AS RevPercentage
FROM stg_Churn
GROUP BY Customer_Status;

-- State distribution, ranked
SELECT State, COUNT(State) AS TotalCount,
       COUNT(State) * 1.0 / (SELECT COUNT(*) FROM stg_Churn) AS Percentage
FROM stg_Churn
GROUP BY State
ORDER BY Percentage DESC;

-- Check Empty string/Nulls in Data
SELECT 
    SUM(CASE WHEN Value_Deal = '' THEN 1 ELSE 0 END) AS Empty_String_Count,
    SUM(CASE WHEN Value_Deal IS NULL THEN 1 ELSE 0 END) AS True_Null_Count,
    COUNT(*) AS Total_Rows
FROM stg_Churn;

-- Count Empty string/Nulls
SELECT 
    SUM(CASE WHEN Value_Deal IS NULL OR Value_Deal = '' THEN 1 ELSE 0 END) AS Value_Deal_Null_Count,
    SUM(CASE WHEN Multiple_Lines IS NULL OR Multiple_Lines = '' THEN 1 ELSE 0 END) AS Multiple_Lines_Null_Count,
    SUM(CASE WHEN Internet_Type IS NULL OR Internet_Type = '' THEN 1 ELSE 0 END) AS Internet_Type_Null_Count,
    SUM(CASE WHEN Online_Security IS NULL OR Online_Security = '' THEN 1 ELSE 0 END) AS Online_Security_Null_Count,
    SUM(CASE WHEN Online_Backup IS NULL OR Online_Backup = '' THEN 1 ELSE 0 END) AS Online_Backup_Null_Count,
    SUM(CASE WHEN Device_Protection_Plan IS NULL OR Device_Protection_Plan = '' THEN 1 ELSE 0 END) AS Device_Protection_Plan_Null_Count,
    SUM(CASE WHEN Premium_Support IS NULL OR Premium_Support = '' THEN 1 ELSE 0 END) AS Premium_Support_Null_Count,
    SUM(CASE WHEN Streaming_TV IS NULL OR Streaming_TV = '' THEN 1 ELSE 0 END) AS Streaming_TV_Null_Count,
    SUM(CASE WHEN Streaming_Movies IS NULL OR Streaming_Movies = '' THEN 1 ELSE 0 END) AS Streaming_Movies_Null_Count,
    SUM(CASE WHEN Streaming_Music IS NULL OR Streaming_Music = '' THEN 1 ELSE 0 END) AS Streaming_Music_Null_Count,
    SUM(CASE WHEN Unlimited_Data IS NULL OR Unlimited_Data = '' THEN 1 ELSE 0 END) AS Unlimited_Data_Null_Count,
    SUM(CASE WHEN Churn_Category IS NULL OR Churn_Category = '' THEN 1 ELSE 0 END) AS Churn_Category_Null_Count,
    SUM(CASE WHEN Churn_Reason IS NULL OR Churn_Reason = '' THEN 1 ELSE 0 END) AS Churn_Reason_Null_Count
FROM stg_Churn;

-- Converting Empty strings into Nulls and then filling all the missing values accordingly
DROP TABLE IF EXISTS prod_Churn;
CREATE TABLE prod_Churn AS
SELECT 
    Customer_ID,
    Gender,
    Age,
    Married,
    State,
    Number_of_Referrals,
    Tenure_in_Months,
    IFNULL(NULLIF(Value_Deal, ''), 'No Deal') AS Value_Deal,
    Phone_Service,
    IFNULL(NULLIF(Multiple_Lines, ''), 'No Phone Service') AS Multiple_Lines,
    Internet_Service,
    IFNULL(NULLIF(Internet_Type, ''), 'No Internet Service') AS Internet_Type,
    IFNULL(NULLIF(Online_Security, ''), 'No Internet Service') AS Online_Security,
    IFNULL(NULLIF(Online_Backup, ''), 'No Internet Service') AS Online_Backup,
    IFNULL(NULLIF(Device_Protection_Plan, ''), 'No Internet Service') AS Device_Protection_Plan,
    IFNULL(NULLIF(Premium_Support, ''), 'No Internet Service') AS Premium_Support,
    IFNULL(NULLIF(Streaming_TV, ''), 'No Internet Service') AS Streaming_TV,
    IFNULL(NULLIF(Streaming_Movies, ''), 'No Internet Service') AS Streaming_Movies,
    IFNULL(NULLIF(Streaming_Music, ''), 'No Internet Service') AS Streaming_Music,
    IFNULL(NULLIF(Unlimited_Data, ''), 'No Internet Service') AS Unlimited_Data,
    Contract,
    Paperless_Billing,
    Payment_Method,
    ABS(Monthly_Charge) AS Monthly_Charge,
    Total_Charges,
    Total_Refunds,
    Total_Extra_Data_Charges,
    Total_Long_Distance_Charges,
    Total_Revenue,
    Customer_Status,
    IFNULL(NULLIF(Churn_Category, ''), 'Not Applicable') AS Churn_Category,
    IFNULL(NULLIF(Churn_Reason, ''), 'Not Applicable') AS Churn_Reason
FROM stg_Churn;
ALTER TABLE prod_Churn ADD PRIMARY KEY (Customer_ID);

-- Final Check if exists any missing value in data
SELECT 
  SUM(Value_Deal = '') AS empty_value_deal,
  SUM(Online_Security = '') AS empty_security,
  SUM(Churn_Category = '') AS empty_churn_cat,
  SUM(Monthly_Charge < 0) AS still_negative,
  COUNT(*) AS total_rows
FROM prod_Churn;

