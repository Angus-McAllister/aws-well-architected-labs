-- query_id: billservice
-- query_description: This query will provide a monthly cost summary by AWS Service Charge which is an approximation to the monthly bill in the billing console.
-- query_columns: month_line_item_usage_start_date,bill_bill_type,product_product_name,product_location,line_item_line_item_description,round_sum_line_item_unblended_cost,sum_line_item_usage_amount
-- query_link: /cost/300_labs/300_cur_queries/queries/global/

SELECT -- automation_select_stmt
  DATE_FORMAT((line_item_usage_start_date),'%Y-%m-01') AS month_line_item_usage_start_date, -- automation_timerange_dateformat
  bill_bill_type,
  CASE
    WHEN ("product_product_family" = 'Data Transfer') THEN 'Data Transfer' ELSE replace(replace(replace("product_product_name", 'Amazon '),'Amazon'),'AWS ') END "product_product_name",
  product_location,
  line_item_line_item_description,
  sum(line_item_unblended_cost) AS round_sum_line_item_unblended_cost,
  sum(line_item_usage_amount) AS sum_line_item_usage_amount
FROM -- automation_from_stmt
  ${table_name} -- automation_tablename
WHERE -- automation_where_stmt
  year = '2020' AND (month BETWEEN '7' AND '9' OR month BETWEEN '07' AND '09') -- automation_timerange_year_month
GROUP BY -- automation_groupby_stmt
  1,
  bill_bill_type,
  3,
  product_location,
  line_item_line_item_description
HAVING sum(line_item_usage_amount) > 0
ORDER BY -- automation_order_stmt
  month_line_item_usage_start_date,
  bill_bill_type,
  product_product_name,
  product_location,
  line_item_line_item_description;
