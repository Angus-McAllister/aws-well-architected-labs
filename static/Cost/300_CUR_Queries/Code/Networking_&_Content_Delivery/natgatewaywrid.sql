-- query_id: natgateway
-- query_description: This query provides monthly unblended cost and usage information about NAT Gateway Usage including resource id. The usage amount and cost will be summed and the cost will be in descending order.
-- query_columns: bill_payer_account_id,line_item_usage_account_id,line_item_resource_id,month_line_item_usage_start_date,line_item_usage_type,sum_line_item_usage_amount,sum_line_item_unblended_cost
-- query_link: /cost/300_labs/300_cur_queries/queries/networking__content_delivery/

SELECT -- automation_select_stmt
  bill_payer_account_id,
  line_item_usage_account_id,
  line_item_resource_id,
  DATE_FORMAT(line_item_usage_start_date,'%Y-%m') AS month_line_item_usage_start_date, -- automation_timerange_dateformat
  CASE  
    WHEN line_item_usage_type LIKE '%%NatGateway-Bytes' THEN 'NAT Gateway Data Processing Charge' -- Charge for per GB data processed by NatGateways
    WHEN line_item_usage_type LIKE '%%NatGateway-Hours' THEN 'NAT Gateway Hourly Charge'          -- Hourly charge for NAT Gateways
    ELSE line_item_usage_type
  END AS line_item_usage_type,
  SUM(CAST(line_item_usage_amount AS double)) AS sum_line_item_usage_amount,
  SUM(CAST(line_item_unblended_cost AS decimal(16,8))) AS sum_line_item_unblended_cost
FROM -- automation_from_stmt
  ${table_name} -- automation_tablename
WHERE -- automation_where_stmt
  year = '2020' AND (month BETWEEN '7' AND '9' OR month BETWEEN '07' AND '09') -- automation_timerange_year_month
  AND product_product_family = 'NAT Gateway'
  AND line_item_line_item_type  in ('DiscountedUsage', 'Usage', 'SavingsPlanCoveredUsage')
GROUP BY -- automation_groupby_stmt
  bill_payer_account_id, 
  line_item_usage_account_id,
  DATE_FORMAT(line_item_usage_start_date,'%Y-%m'), -- automation_timerange_dateformat
  line_item_resource_id,
  line_item_usage_type
ORDER BY -- automation_order_stmt
  sum_line_item_unblended_cost DESC,
  sum_line_item_usage_amount;