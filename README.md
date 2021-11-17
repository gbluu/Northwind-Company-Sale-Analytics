# Northwind Company Sale Analytics
Dữ liệu Northwind, đây là một database miễn phí và open-source được tạo bởi Microsoft. Database liên quan đến việc xuất nhập khẩu đồ ăn trên thế giới, thông tin nhân viên, đơn hàng, vận chuyển.

👉 **Nhiệm vụ của tôi trong case-study này là thực hiện phân tích đánh giá hiệu suất thông qua SQL và Power BI để trực quan dữ liệu**. 

Trả lời các câu hỏi của các team:
- Product Team
- Logistics Team
- HR Team
- Pricing Team
## Dataset
Dưới đây là entity relationship diagram (ERD) của dataset
![Model](/image/modelviews.png)
## Câu Hỏi
#### 1. Product Team muốn biết những sản phẩm đang được offer với giá từ $20 - $50?
<details>
<summary>
Solution
</summary>

```sql
SELECT product_name,
       unit_price
FROM   northwind_company..products
WHERE  unit_price BETWEEN 20 AND 50
       AND discontinued = 0
ORDER  BY unit_price DESC; 
```
![q1](/image/1.png)
</details>

#### 2. Logistics Team muốn tra lại lịch sử hiệu suất của việc xuất khẩu từ 1998 để biết quốc gia nào chưa hoàn thành tốt?
<details>
<summary>
Solution
</summary>

```sql
WITH avg_days
     AS (SELECT ship_country,
                Avg(Cast(Datediff(day, order_date, shipped_date) AS
                         DECIMAL(10, 2)))
                AS
                average_days_order_shipping,
                Count(*)
                AS
                   total_number_orders
         FROM   northwind_company..orders
         WHERE  Year(order_date) = 1998
         GROUP  BY ship_country)
SELECT *
FROM   avg_days
WHERE  average_days_order_shipping >= 5
       AND total_number_orders > 10;
```
![q2](/image/2.png)
</details>

#### 3. HR Team muốn biết thông tin nhân viên, tuổi của họ lúc gia nhập công ty và thông tin người quản lý của họ?
<details>
<summary>
Solution
</summary>

```sql
SELECT Concat(m.first_name, ' ', m.last_name)    AS employee_fullname,
       m.title                                   AS employee_title,
       Datediff(year, m.birth_date, m.hire_date) AS employee_age,
       Concat(e.first_name, ' ', e.last_name)    AS manager_fullname,
       e.title                                   AS manager_title
FROM   northwind_company..employees AS e
       INNER JOIN northwind_company..employees AS m
               ON e.employee_id = m.reports_to
ORDER  BY employee_age;
```
![q3](/image/3.png)
</details>

#### 4. Logistics Team muốn tra lại lịch sử từ 1997 - 1998 để biết tháng nào có hiệu suất tốt?
<details>
<summary>
Solution
</summary>

```sql
WITH freight
     AS (SELECT Concat(Year(order_date), '-', Month(order_date)) AS year_month,
                Count(*)                                         AS
                total_number_orders,
                Round(Sum(freight), 0)                           AS
                total_freight
         FROM   northwind_company..orders
         WHERE  order_date > '1997-01-01'
         GROUP  BY Concat(Year(order_date), '-', Month(order_date)))
SELECT *
FROM   freight
WHERE  total_number_orders > 35
ORDER  BY total_freight DESC;
```
![q4](/image/4.png)
</details>

#### 5. Pricing Team muốn biết sản phẩm có đơn giá tăng và tỉ lệ tăng không nằm trong khoảng 20% - 30%?
<details>
<summary>
Solution
</summary>

```sql
WITH cte_price
     AS (SELECT p.product_id,
                product_name,
                order_date,
                Lead(d.unit_price)
                  OVER (
                    partition BY product_name
                    ORDER BY order_date) AS current_price,
                Lag(d.unit_price)
                  OVER (
                    partition BY product_name
                    ORDER BY order_date) AS previous_price
         FROM   northwind_company..products AS p
                INNER JOIN northwind_company..order_details AS d
                        ON p.product_id = d.product_id
                INNER JOIN northwind_company..orders AS o
                        ON o.order_id = d.order_id)
SELECT c.product_name,
       c.current_price,
       c.previous_price,
       Round(100 * ( current_price - previous_price ) / previous_price, 2) AS
       percentage_increase
FROM   cte_price AS c
       INNER JOIN northwind_company..order_details AS d
               ON c.product_id = d.product_id
WHERE  c.current_price != c.previous_price
GROUP  BY c.product_name,
          c.current_price,
          c.previous_price
HAVING Count(DISTINCT order_id) > 10
       AND Round(100 * ( current_price - previous_price ) / previous_price, 2)
           NOT BETWEEN
           20 AND 30 
```
![](/image/5.png)
</details>

 #### 6. Pricing Team muốn chia danh mục sản phẩm (category) theo 3 mức giá và hiệu suất bán hàng của chúng?
<details>
<summary>
Solution
</summary>

```sql
SELECT category_name,
       CASE
         WHEN p.unit_price < 20 THEN '1.Below $20'
         WHEN p.unit_price >= 20
              AND p.unit_price <= 50 THEN '2. $20 - $50'
         WHEN p.unit_price > 50 THEN '3. Over $50'
       END                            AS price_range,
       Sum(d.unit_price * d.quantity) AS total_amount,
       Count(DISTINCT d.order_id)     AS total_number_orders
FROM   northwind_company..categories AS c
       INNER JOIN northwind_company..products AS p
               ON c.category_id = p.category_id
       INNER JOIN northwind_company..order_details AS d
               ON p.product_id = d.product_id
GROUP  BY category_name,
          CASE
            WHEN p.unit_price < 20 THEN '1.Below $20'
            WHEN p.unit_price >= 20
                 AND p.unit_price <= 50 THEN '2. $20 - $50'
            WHEN p.unit_price > 50 THEN '3. Over $50'
          END
ORDER  BY category_name,
          price_range;
```
![](/image/6.png)
</details>
  
 
#### 7. Logistics Team muốn biết tình trạng kho hàng của các nhà cung cấp trong khu vực đối với từng loại sản phẩm?
<details>
<summary>
Solution
</summary>

```sql
SELECT category_name,
       CASE
         WHEN s.country IN ( 'US', 'Brazil', 'Canada' ) THEN 'America'
         WHEN s.country IN ( 'Australia', 'Singapore', 'Japan' ) THEN
         'Asia-Pacific'
         ELSE 'Europe'
       END AS supplier_region,
       p.unit_in_stock,
       p.unit_on_order,
       p.reorder_level
FROM   northwind_company..suppliers AS s
       INNER JOIN northwind_company..products AS p
               ON s.supplier_id = p.supplier_id
       INNER JOIN northwind_company..categories AS c
               ON c.category_id = p.category_id
WHERE  s.region IS NOT NULL
ORDER  BY supplier_region,
          c.category_name,
          p.unit_price; 
```
![](/image/7.png)
</details>
  
  #### 8. Pricing Team muốn biết tình trạng đơn giá sản phẩm so với giá trung bình theo từng danh mục? 
<details>
<summary>
Solution
</summary>

```sql
WITH avg_price AS
(
           SELECT     c.category_name,
                      p.product_name,
                      p.unit_price,
                      Round(Avg(d.unit_price),2)    AS average_unit_price
           FROM       northwind_company..categories AS c
           INNER JOIN northwind_company..products   AS p
           ON         c.category_id = p.category_id
           INNER JOIN northwind_company..order_details AS d
           ON         d.product_id = p.product_id
           WHERE      p.discontinued = 0
           GROUP BY   c.category_name,
                      p.product_name,
                      p.unit_price )
SELECT   *,
         round(Percentile_cont(0.5) within GROUP (ORDER BY unit_price) OVER(partition BY product_name),2) AS median_unit_price,
         CASE
                  WHEN unit_price > average_unit_price THEN 'Over Average'
                  WHEN unit_price = average_unit_price THEN 'Equal Average'
                  WHEN unit_price < average_unit_price THEN 'Below Average'
         END AS average_unit_price_position,
         CASE
                  WHEN unit_price > percentile_cont(0.5) within GROUP (ORDER BY unit_price) OVER(partition BY product_name) THEN 'Over Average'
                  WHEN unit_price = percentile_cont(0.5) within GROUP (ORDER BY unit_price) OVER(partition BY product_name) THEN 'Equal Average'
                  WHEN unit_price < percentile_cont(0.5) within GROUP (ORDER BY unit_price) OVER(partition BY product_name) THEN 'Below Average'
         END AS median_unit_price_position
FROM     avg_price
ORDER BY category_name,
         product_name;
```
![](/image/8.png)
</details>
  
#### 9. Sales Team muốn một bảng đánh giá KPI hiệu suất nhân viên
<details>
<summary>
Solution
</summary>

```sql
WITH cte_kpi
     AS (SELECT Concat(first_name, ' ', last_name)
                AS
                   employee_full_name,
                title
                AS
                   employee_title,
                Round(Sum(d.unit_price * d.quantity), 2)
                AS
                   total_sale_amount_excluding_discount,
                Count(DISTINCT d.order_id)
                AS
                   total_number_orders,
                Count(d.order_id)
                AS
                   total_number_entries,
                Round(Sum(d.discount * ( d.quantity * d.unit_price )), 2)
                AS
                total_discount_amount,
                Round(Sum(( 1 - d.discount ) * ( d.quantity *
                d.unit_price )), 2) AS
                total_sale_amount_including_discount
         FROM   northwind_company..employees AS e
                INNER JOIN northwind_company..orders AS o
                        ON e.employee_id = o.employee_id
                INNER JOIN northwind_company..order_details AS d
                        ON d.order_id = o.order_id
         GROUP  BY Concat(first_name, ' ', last_name),
                   title)
SELECT employee_full_name,
       employee_title,
       total_sale_amount_excluding_discount,
       total_number_orders,
       total_number_entries,
       total_discount_amount,
       total_sale_amount_including_discount,
       Round(Sum(total_sale_amount_excluding_discount / total_number_entries), 2
       ) AS
       average_amount_per_entry,
       Round(Sum(total_sale_amount_excluding_discount / total_number_orders), 2)
       AS
       average_amount_per_entry,
       Round(Sum(100 * ( total_sale_amount_excluding_discount
                                   - total_sale_amount_including_discount ) /
                       total_sale_amount_excluding_discount), 2)
       AS
       total_discount_percentage
FROM   cte_kpi
GROUP  BY employee_full_name,
          employee_title,
          total_sale_amount_excluding_discount,
          total_number_orders,
          total_number_entries,
          total_discount_amount,
          total_sale_amount_including_discount
ORDER  BY total_sale_amount_including_discount DESC;
```
![](/image/9.png)
</details>

#### 10. Sales Team muốn một bảng đánh giá KPI hiệu suất nhân viên theo từng danh mục sản phẩm
<details>
<summary>
Solution
</summary>

```sql
WITH cte_kpi
     AS (SELECT category_name,
                Concat(first_name, ' ', last_name)
                AS
                   employee_full_name,
                Round(Sum(( 1 - d.discount ) * ( d.quantity *
                d.unit_price )), 2) AS
                total_sale_amount_including_discount
         FROM   northwind_company..employees AS e
                INNER JOIN northwind_company..orders AS o
                        ON e.employee_id = o.employee_id
                INNER JOIN northwind_company..order_details AS d
                        ON d.order_id = o.order_id
                INNER JOIN northwind_company..products AS p
                        ON p.product_id = d.product_id
                INNER JOIN northwind_company..categories AS c
                        ON c.category_id = p.category_id
         GROUP  BY category_name,
                   Concat(first_name, ' ', last_name))
SELECT category_name,
       employee_full_name,
       total_sale_amount_including_discount,
       Round(100 * Sum(total_sale_amount_including_discount) / Sum(
             total_sale_amount_including_discount)
                   OVER (
                     partition BY employee_full_name), 2) AS
       percentage_employee_sales,
       Round(100 * Sum(total_sale_amount_including_discount) / Sum(
             total_sale_amount_including_discount)
                   OVER (
                     partition BY category_name), 2)      AS
       percentage_category_sales
FROM   cte_kpi
GROUP  BY category_name,
          employee_full_name,
          total_sale_amount_including_discount
ORDER  BY category_name,
          total_sale_amount_including_discount DESC;
```
![](/image/10.png)
</details>
