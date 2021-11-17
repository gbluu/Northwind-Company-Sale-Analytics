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

<details>
<summary>
1. Product Team muốn biết những sản phẩm đang được offer với giá từ $20 - $50?
</summary>

```sql
SELECT product_name,
       unit_price
FROM   northwind_company..products
WHERE  unit_price BETWEEN 20 AND 50
       AND discontinued = 0
ORDER  BY unit_price DESC; 
```
|product_name                    |unit_price|
|--------------------------------|----------|
|Tarte au sucre                  |49.3      |
|Ipoh Coffee                     |46        |
|Schoggi Schokolade              |43.9      |
|Vegie-spread                    |43.9      |
|Northwoods Cranberry Sauce      |40        |
|Queso Manchego La Pastora       |38        |
|Gnocchi di nonna Alice          |38        |
|Gudbrandsdalsost                |36        |
|Mozzarella di Giovanni          |34.8      |
|Camembert Pierrot               |34        |
|Wimmers gute Semmelknödel       |33.25     |
|Mascarpone Fabioli              |32        |
|Gumbär Gummibärchen             |31.23     |
|Ikura                           |31        |
|Uncle Bob's Organic Dried Pears |30        |
|Sirop d'érable                  |28.5      |
|Gravad lax                      |26        |
|Nord-Ost Matjeshering           |25.89     |
|Grandma's Boysenberry Spread    |25        |
|Pâté chinois                    |24        |
|Tofu                            |23.25     |
|Chef Anton's Cajun Seasoning    |22        |
|Flotemysost                     |21.5      |
|Louisiana Fiery Hot Pepper Sauce|21.05     |
|Queso Cabrales                  |21        |
|Gustaf's Knäckebröd             |21        |
|Maxilaku                        |20        |

</details>

<details>
<summary>
2. Logistics Team muốn tra lại lịch sử hiệu suất của việc xuất khẩu từ 1998 để biết quốc gia nào chưa hoàn thành tốt?
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
       
|ship_country                    |average_days_order_shipping|total_number_orders|
|--------------------------------|---------------------------|-------------------|
|Austria                         |5.888888                   |11                 |
|Brazil                          |8.115384                   |28                 |
|France                          |9.428571                   |23                 |
|Germany                         |5.375000                   |34                 |
|Spain                           |7.833333                   |12                 |
|Sweden                          |13.285714                  |14                 |
|UK                              |6.250000                   |16                 |
|USA                             |7.888888                   |39                 |
|Venezuela                       |8.733333                   |18                 |

</details>

<details>
<summary>
3. HR Team muốn biết thông tin nhân viên, tuổi của họ lúc gia nhập công ty và thông tin người quản lý của họ?
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
|employee_fullname               |employee_title|employee_age|manager_fullname|manager_title        |
|--------------------------------|--------------|------------|----------------|---------------------|
|Anne Dodsworth                  |Sales Representative|28          |Steven Buchanan |Sales Manager        |
|Janet Leverling                 |Sales Representative|29          |Andrew Fuller   |Vice President, Sales|
|Michael Suyama                  |Sales Representative|30          |Steven Buchanan |Sales Manager        |
|Robert King                     |Sales Representative|34          |Steven Buchanan |Sales Manager        |
|Laura Callahan                  |Inside Sales Coordinator|36          |Andrew Fuller   |Vice President, Sales|
|Steven Buchanan                 |Sales Manager |38          |Andrew Fuller   |Vice President, Sales|
|Nancy Davolio                   |Sales Representative|44          |Andrew Fuller   |Vice President, Sales|
|Margaret Peacock                |Sales Representative|56          |Andrew Fuller   |Vice President, Sales|

</details>

 
<details>
<summary>
4. Logistics Team muốn tra lại lịch sử từ 1997 - 1998 để biết tháng nào có hiệu suất tốt?
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
|year_month                      |total_number_orders|total_freight|
|--------------------------------|-------------------|-------------|
|1998-4                          |74                 |6394         |
|1998-1                          |55                 |5463         |
|1998-3                          |73                 |5379         |
|1998-2                          |54                 |4273         |
|1997-10                         |38                 |3946         |
|1997-12                         |48                 |3758         |
|1997-9                          |37                 |3237         |

</details>

 
<details>
<summary>
5. Pricing Team muốn biết sản phẩm có đơn giá tăng và tỉ lệ tăng không nằm trong khoảng 20% - 30%?
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
|product_name                    |current_price|previous_price|percentage_increase|
|--------------------------------|-------------|--------------|-------------------|
|Singaporean Hokkien Fried Mee   |11.2         |9.8           |14.29              |
|Mozzarella di Giovanni          |27.8         |34.8          |-20.11             |

</details>

<details>
<summary>
6. Pricing Team muốn chia danh mục sản phẩm (category) theo 3 mức giá và hiệu suất bán hàng của chúng?
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
|category_name                   |price_range|total_amount|total_number_orders|
|--------------------------------|-----------|------------|-------------------|
|Beverages                       |1.Below $20|111463.549739838|317                |
|Beverages                       |2. $20 - $50|25079.1999206543|28                 |
|Beverages                       |3. Over $50|149984.200195313|24                 |
|Condiments                      |1.Below $20|28621.7001647949|85                 |
|Condiments                      |2. $20 - $50|85073.0499267578|121                |
|Confections                     |1.Below $20|57369.0002737045|197                |
|Confections                     |2. $20 - $50|96094.2993202209|106                |
|Confections                     |3. Over $50|23635.800201416|16                 |
|Dairy Products                  |1.Below $20|17886       |81                 |
|Dairy Products                  |2. $20 - $50|157148.499607086|204                |
|Dairy Products                  |3. Over $50|76296       |54                 |
|Grains/Cereals                  |1.Below $20|25364.1999950409|99                 |
|Grains/Cereals                  |2. $20 - $50|75362.6000175476|91                 |
|Meat/Poultry                    |1.Below $20|5120.99999237061|36                 |
|Meat/Poultry                    |2. $20 - $50|76504.4000473022|96                 |
|Meat/Poultry                    |3. Over $50|96563.4002532959|36                 |
|Produce                         |1.Below $20|2566        |13                 |
|Produce                         |2. $20 - $50|57960.0000915527|81                 |
|Produce                         |3. Over $50|44742.6001052856|39                 |
|Seafood                         |1.Below $20|69672.6498651505|217                |
|Seafood                         |2. $20 - $50|39962.9395179749|70                 |
|Seafood                         |3. Over $50|31987.5     |27                 |


</details>
  
 
 
<details>
<summary>
7. Logistics Team muốn biết tình trạng kho hàng của các nhà cung cấp trong khu vực đối với từng loại sản phẩm?
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
|category_name                   |supplier_region|unit_in_stock|unit_on_order|reorder_level|
|--------------------------------|---------------|-------------|-------------|-------------|
|Condiments                      |America        |113          |0            |25           |
|Confections                     |America        |17           |0            |0            |
|Meat/Poultry                    |America        |21           |0            |10           |
|Meat/Poultry                    |America        |115          |0            |20           |
|Beverages                       |Asia-Pacific   |15           |10           |30           |
|Condiments                      |Asia-Pacific   |24           |0            |5            |
|Confections                     |Asia-Pacific   |29           |0            |10           |
|Grains/Cereals                  |Asia-Pacific   |38           |0            |25           |
|Meat/Poultry                    |Asia-Pacific   |0            |0            |0            |
|Meat/Poultry                    |Asia-Pacific   |0            |0            |0            |
|Produce                         |Asia-Pacific   |20           |0            |10           |
|Seafood                         |Asia-Pacific   |42           |0            |0            |
|Beverages                       |Europe         |111          |0            |15           |
|Beverages                       |Europe         |52           |0            |10           |
|Beverages                       |Europe         |20           |0            |15           |
|Condiments                      |Europe         |4            |100          |20           |
|Condiments                      |Europe         |76           |0            |0            |
|Condiments                      |Europe         |0            |0            |0            |
|Condiments                      |Europe         |53           |0            |0            |
|Condiments                      |Europe         |120          |0            |25           |
|Condiments                      |Europe         |6            |0            |0            |
|Dairy Products                  |Europe         |22           |30           |30           |
|Dairy Products                  |Europe         |86           |0            |0            |
|Produce                         |Europe         |15           |0            |10           |
|Seafood                         |Europe         |85           |0            |10           |
|Seafood                         |Europe         |123          |0            |30           |

</details>
  
   
<details>
<summary>
8. Pricing Team muốn biết tình trạng đơn giá sản phẩm so với giá trung bình theo từng danh mục? 
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

|category_name                   |product_name|unit_price|average_unit_price|median_unit_price|average_unit_price_position|median_unit_price_position|
|--------------------------------|------------|----------|------------------|-----------------|---------------------------|--------------------------|
|Beverages                       |Chartreuse verte|18        |16.68             |18               |Over Average               |Equal Average             |
|Beverages                       |Côte de Blaye|263.5     |245.93            |263.5            |Over Average               |Equal Average             |
|Beverages                       |Ipoh Coffee |46        |43.04             |46               |Over Average               |Equal Average             |
|Beverages                       |Lakkalikööri|18        |16.98             |18               |Over Average               |Equal Average             |
|Beverages                       |Laughing Lumberjack Lager|14        |13.72             |14               |Over Average               |Equal Average             |
|Beverages                       |Outback Lager|15        |14.15             |15               |Over Average               |Equal Average             |
|Beverages                       |Rhönbräu Klosterbier|7.75      |7.38              |7.75             |Over Average               |Equal Average             |
|Beverages                       |Sasquatch Ale|14        |12.97             |14               |Over Average               |Equal Average             |
|Beverages                       |Steeleye Stout|18        |17                |18               |Over Average               |Equal Average             |
|Condiments                      |Aniseed Syrup|10        |9.5               |10               |Over Average               |Equal Average             |
|Condiments                      |Chef Anton's Cajun Seasoning|22        |20.68             |22               |Over Average               |Equal Average             |
|Condiments                      |Genen Shouyu|13        |14.47             |13               |Below Average              |Equal Average             |
|Condiments                      |Grandma's Boysenberry Spread|25        |24.17             |25               |Over Average               |Equal Average             |
|Condiments                      |Gula Malacca|19.45     |18.13             |19.45            |Over Average               |Equal Average             |
|Condiments                      |Louisiana Fiery Hot Pepper Sauce|21.05     |19.46             |21.05            |Over Average               |Equal Average             |
|Condiments                      |Louisiana Hot Spiced Okra|17        |15.3              |17               |Over Average               |Equal Average             |
|Condiments                      |Northwoods Cranberry Sauce|40        |38.77             |40               |Over Average               |Equal Average             |
|Condiments                      |Original Frankfurter grüne Soße|13        |12.11             |13               |Over Average               |Equal Average             |
|Condiments                      |Sirop d'érable|28.5      |27.79             |28.5             |Over Average               |Equal Average             |
|Condiments                      |Vegie-spread|43.9      |40.79             |43.9             |Over Average               |Equal Average             |
|Confections                     |Chocolade   |12.75     |11.9              |12.75            |Over Average               |Equal Average             |
|Confections                     |Gumbär Gummibärchen|31.23     |28.86             |31.23            |Over Average               |Equal Average             |
|Confections                     |Maxilaku    |20        |18.48             |20               |Over Average               |Equal Average             |
|Confections                     |NuNuCa Nuß-Nougat-Creme|14        |13.07             |14               |Over Average               |Equal Average             |
|Confections                     |Pavlova     |17.45     |16.38             |17.45            |Over Average               |Equal Average             |
|Confections                     |Schoggi Schokolade|43.9      |40.97             |43.9             |Over Average               |Equal Average             |
|Confections                     |Scottish Longbreads|12.5      |11.54             |12.5             |Over Average               |Equal Average             |
|Confections                     |Sir Rodney's Marmalade|81        |75.94             |81               |Over Average               |Equal Average             |
|Confections                     |Sir Rodney's Scones|10        |9.38              |10               |Over Average               |Equal Average             |
|Confections                     |Tarte au sucre|49.3      |46.41             |49.3             |Over Average               |Equal Average             |
|Confections                     |Teatime Chocolate Biscuits|9.2       |8.53              |9.2              |Over Average               |Equal Average             |
|Confections                     |Valkoinen suklaa|16.25     |14.95             |16.25            |Over Average               |Equal Average             |
|Confections                     |Zaanse koeken|9.5       |9.14              |9.5              |Over Average               |Equal Average             |
|Dairy Products                  |Camembert Pierrot|34        |32.13             |34               |Over Average               |Equal Average             |
|Dairy Products                  |Flotemysost |21.5      |19.76             |21.5             |Over Average               |Equal Average             |
|Dairy Products                  |Geitost     |2.5       |2.33              |2.5              |Over Average               |Equal Average             |
|Dairy Products                  |Gorgonzola Telino|12.5      |11.67             |12.5             |Over Average               |Equal Average             |
|Dairy Products                  |Gudbrandsdalsost|36        |33.45             |36               |Over Average               |Equal Average             |
|Dairy Products                  |Mascarpone Fabioli|32        |30.72             |32               |Over Average               |Equal Average             |
|Dairy Products                  |Mozzarella di Giovanni|34.8      |32.04             |34.8             |Over Average               |Equal Average             |
|Dairy Products                  |Queso Cabrales|21        |19.6              |21               |Over Average               |Equal Average             |
|Dairy Products                  |Queso Manchego La Pastora|38        |36.91             |38               |Over Average               |Equal Average             |
|Dairy Products                  |Raclette Courdavault|55        |51.13             |55               |Over Average               |Equal Average             |
|Grains/Cereals                  |Filo Mix    |7         |6.76              |7                |Over Average               |Equal Average             |
|Grains/Cereals                  |Gnocchi di nonna Alice|38        |35.42             |38               |Over Average               |Equal Average             |
|Grains/Cereals                  |Gustaf's Knäckebröd|21        |20.4              |21               |Over Average               |Equal Average             |
|Grains/Cereals                  |Ravioli Angelo|19.5      |18.14             |19.5             |Over Average               |Equal Average             |
|Grains/Cereals                  |Tunnbröd    |9         |8.37              |9                |Over Average               |Equal Average             |
|Grains/Cereals                  |Wimmers gute Semmelknödel|33.25     |31.03             |33.25            |Over Average               |Equal Average             |
|Meat/Poultry                    |Pâté chinois|24        |22.4              |24               |Over Average               |Equal Average             |
|Meat/Poultry                    |Tourtière   |7.45      |6.8               |7.45             |Over Average               |Equal Average             |
|Produce                         |Longlife Tofu|10        |8.77              |10               |Over Average               |Equal Average             |
|Produce                         |Manjimup Dried Apples|53        |50.55             |53               |Over Average               |Equal Average             |
|Produce                         |Tofu        |23.25     |21.35             |23.25            |Over Average               |Equal Average             |
|Produce                         |Uncle Bob's Organic Dried Pears|30        |29.17             |30               |Over Average               |Equal Average             |
|Seafood                         |Boston Crab Meat|18.4      |17.23             |18.4             |Over Average               |Equal Average             |
|Seafood                         |Carnarvon Tigers|62.5      |59.72             |62.5             |Over Average               |Equal Average             |
|Seafood                         |Escargots de Bourgogne|13.25     |12.66             |13.25            |Over Average               |Equal Average             |
|Seafood                         |Gravad lax  |26        |23.4              |26               |Over Average               |Equal Average             |
|Seafood                         |Ikura       |31        |29.68             |31               |Over Average               |Equal Average             |
|Seafood                         |Inlagd Sill |19        |17.9              |19               |Over Average               |Equal Average             |
|Seafood                         |Jack's New England Clam Chowder|9.65      |9.19              |9.65             |Over Average               |Equal Average             |
|Seafood                         |Konbu       |6         |5.76              |6                |Over Average               |Equal Average             |
|Seafood                         |Nord-Ost Matjeshering|25.89     |24.27             |25.89            |Over Average               |Equal Average             |
|Seafood                         |Röd Kaviar  |15        |14.36             |15               |Over Average               |Equal Average             |
|Seafood                         |Rogede sild |9.5       |9.23              |9.5              |Over Average               |Equal Average             |
|Seafood                         |Spegesild   |12        |11.11             |12               |Over Average               |Equal Average             |
                                                        
</details>
  
 
<details>
<summary>
9. Sales Team muốn một bảng đánh giá KPI hiệu suất nhân viên
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
|employee_full_name              |employee_title|total_sale_amount_excluding_discount|total_number_orders|total_number_entries|total_discount_amount|total_sale_amount_including_discount|average_amount_per_entry|average_amount_per_entry|total_discount_percentage|
|--------------------------------|--------------|------------------------------------|-------------------|--------------------|---------------------|------------------------------------|------------------------|------------------------|-------------------------|
|Margaret Peacock                |Sales Representative|250187.45                           |156                |420                 |17296.6              |232890.85                           |595.68                  |1603.77                 |6.91                     |
|Janet Leverling                 |Sales Representative|213051.3                            |127                |321                 |10238.46             |202812.84                           |663.71                  |1677.57                 |4.81                     |
|Nancy Davolio                   |Sales Representative|202143.71                           |123                |345                 |10036.11             |192107.6                            |585.92                  |1643.44                 |4.96                     |
|Andrew Fuller                   |Vice President, Sales|177749.26                           |96                 |241                 |11211.51             |166537.75                           |737.55                  |1851.55                 |6.31                     |
|Laura Callahan                  |Inside Sales Coordinator|133301.03                           |104                |260                 |6438.75              |126862.28                           |512.7                   |1281.74                 |4.83                     |
|Robert King                     |Sales Representative|141295.99                           |72                 |176                 |16727.76             |124568.24                           |802.82                  |1962.44                 |11.84                    |
|Anne Dodsworth                  |Sales Representative|82964                               |43                 |107                 |5655.93              |77308.07                            |775.36                  |1929.4                  |6.82                     |
|Michael Suyama                  |Sales Representative|78198.1                             |67                 |168                 |4284.97              |73913.13                            |465.46                  |1167.14                 |5.48                     |
|Steven Buchanan                 |Sales Manager |75567.75                            |42                 |117                 |6775.47              |68792.28                            |645.88                  |1799.23                 |8.97                     |

</details>

 
<details>
<summary>
10. Sales Team muốn một bảng đánh giá KPI hiệu suất nhân viên theo từng danh mục sản phẩm
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
|category_name                   |employee_full_name|total_sale_amount_including_discount|percentage_employee_sales|percentage_category_sales|
|--------------------------------|------------------|------------------------------------|-------------------------|-------------------------|
|Beverages                       |Margaret Peacock  |50308.21                            |21.6                     |18.78                    |
|Beverages                       |Nancy Davolio     |46599.35                            |24.26                    |17.4                     |
|Beverages                       |Janet Leverling   |44757.4                             |22.07                    |16.71                    |
|Beverages                       |Andrew Fuller     |40248.25                            |24.17                    |15.03                    |
|Beverages                       |Robert King       |27963.83                            |22.45                    |10.44                    |
|Beverages                       |Anne Dodsworth    |19642.56                            |25.41                    |7.33                     |
|Beverages                       |Laura Callahan    |17897.85                            |14.11                    |6.68                     |
|Beverages                       |Steven Buchanan   |11000.53                            |15.99                    |4.11                     |
|Beverages                       |Michael Suyama    |9450.2                              |12.79                    |3.53                     |
|Condiments                      |Margaret Peacock  |23314.87                            |10.01                    |21.99                    |
|Condiments                      |Andrew Fuller     |14850.67                            |8.92                     |14                       |
|Condiments                      |Laura Callahan    |14637.66                            |11.54                    |13.8                     |
|Condiments                      |Nancy Davolio     |13561.56                            |7.06                     |12.79                    |
|Condiments                      |Janet Leverling   |13381.64                            |6.6                      |12.62                    |
|Condiments                      |Anne Dodsworth    |10125.55                            |13.1                     |9.55                     |
|Condiments                      |Robert King       |8851.37                             |7.11                     |8.35                     |
|Condiments                      |Michael Suyama    |4648.47                             |6.29                     |4.38                     |
|Condiments                      |Steven Buchanan   |2675.3                              |3.89                     |2.52                     |
|Confections                     |Janet Leverling   |33622.4                             |16.58                    |20.09                    |
|Confections                     |Nancy Davolio     |28568.92                            |14.87                    |17.07                    |
|Confections                     |Margaret Peacock  |27768.72                            |11.92                    |16.59                    |
|Confections                     |Laura Callahan    |21699.91                            |17.11                    |12.97                    |
|Confections                     |Andrew Fuller     |21455.69                            |12.88                    |12.82                    |
|Confections                     |Robert King       |14518.99                            |11.66                    |8.68                     |
|Confections                     |Anne Dodsworth    |8053.16                             |10.42                    |4.81                     |
|Confections                     |Michael Suyama    |6859.63                             |9.28                     |4.1                      |
|Confections                     |Steven Buchanan   |4809.8                              |6.99                     |2.87                     |
|Dairy Products                  |Nancy Davolio     |36022.98                            |18.75                    |15.36                    |
|Dairy Products                  |Margaret Peacock  |33549.8                             |14.41                    |14.31                    |
|Dairy Products                  |Janet Leverling   |32320.83                            |15.94                    |13.78                    |
|Dairy Products                  |Robert King       |27621.86                            |22.17                    |11.78                    |
|Dairy Products                  |Andrew Fuller     |23812.55                            |14.3                     |10.15                    |
|Dairy Products                  |Steven Buchanan   |21937.62                            |31.89                    |9.35                     |
|Dairy Products                  |Laura Callahan    |21101.47                            |16.63                    |9                        |
|Dairy Products                  |Anne Dodsworth    |21101.13                            |27.29                    |9                        |
|Dairy Products                  |Michael Suyama    |17039.04                            |23.05                    |7.27                     |
|Grains/Cereals                  |Margaret Peacock  |22579.61                            |9.7                      |23.58                    |
|Grains/Cereals                  |Janet Leverling   |21235.01                            |10.47                    |22.18                    |
|Grains/Cereals                  |Andrew Fuller     |11172.95                            |6.71                     |11.67                    |
|Grains/Cereals                  |Laura Callahan    |11072.05                            |8.73                     |11.56                    |
|Grains/Cereals                  |Michael Suyama    |9410.7                              |12.73                    |9.83                     |
|Grains/Cereals                  |Nancy Davolio     |8465.9                              |4.41                     |8.84                     |
|Grains/Cereals                  |Robert King       |6535.5                              |5.25                     |6.83                     |
|Grains/Cereals                  |Steven Buchanan   |4027.56                             |5.85                     |4.21                     |
|Grains/Cereals                  |Anne Dodsworth    |1245.3                              |1.61                     |1.3                      |
|Meat/Poultry                    |Margaret Peacock  |30867.14                            |13.25                    |18.93                    |
|Meat/Poultry                    |Andrew Fuller     |29873.6                             |17.94                    |18.32                    |
|Meat/Poultry                    |Robert King       |21176.71                            |17                       |12.99                    |
|Meat/Poultry                    |Janet Leverling   |20502.62                            |10.11                    |12.58                    |
|Meat/Poultry                    |Laura Callahan    |16395.28                            |12.92                    |10.06                    |
|Meat/Poultry                    |Nancy Davolio     |15038.47                            |7.83                     |9.22                     |
|Meat/Poultry                    |Steven Buchanan   |11488.2                             |16.7                     |7.05                     |
|Meat/Poultry                    |Michael Suyama    |9003.69                             |12.18                    |5.52                     |
|Meat/Poultry                    |Anne Dodsworth    |8676.66                             |11.22                    |5.32                     |
|Produce                         |Nancy Davolio     |19706.25                            |10.26                    |19.71                    |
|Produce                         |Margaret Peacock  |17186.56                            |7.38                     |17.19                    |
|Produce                         |Laura Callahan    |12016.52                            |9.47                     |12.02                    |
|Produce                         |Janet Leverling   |11960.85                            |5.9                      |11.96                    |
|Produce                         |Michael Suyama    |11560.7                             |15.64                    |11.56                    |
|Produce                         |Robert King       |10753.38                            |8.63                     |10.76                    |
|Produce                         |Andrew Fuller     |9376.48                             |5.63                     |9.38                     |
|Produce                         |Steven Buchanan   |7109.02                             |10.33                    |7.11                     |
|Produce                         |Anne Dodsworth    |314.81                              |0.41                     |0.31                     |
|Seafood                         |Margaret Peacock  |27315.93                            |11.73                    |20.81                    |
|Seafood                         |Janet Leverling   |25032.09                            |12.34                    |19.07                    |
|Seafood                         |Nancy Davolio     |24144.15                            |12.57                    |18.39                    |
|Seafood                         |Andrew Fuller     |15747.57                            |9.46                     |12                       |
|Seafood                         |Laura Callahan    |12041.54                            |9.49                     |9.17                     |
|Seafood                         |Anne Dodsworth    |8148.9                              |10.54                    |6.21                     |
|Seafood                         |Robert King       |7146.58                             |5.74                     |5.44                     |
|Seafood                         |Michael Suyama    |5940.7                              |8.04                     |4.53                     |
|Seafood                         |Steven Buchanan   |5744.25                             |8.35                     |4.38                     |

</details>

## Data Visualization
       
<details>
  <summary>Sales Overview</summary>
<p align="center">
 <img src="/image/db2.png">
</p>
</details>
       
<details>
  <summary>Pricing Analysis</summary>
<p align="center">
 <img src="/image/db1.png">
</p>
</details>

<details>
  <summary>Logistic</summary>
<p align="center">
 <img src="/image/db3.png">
</p>
</details>
     
## Kết Luận
       
Sau khi trình bày những câu hỏi trên, có thể rút ra vài kết luận sau:
 - Về mặt Logistic, mặc dù làm khá tốt trong việc quản lý kho hàng đáp ứng được nhu cầu, nhưng vẫn cần tối ưu và cải thiện tốc độ vận chuyển.
 - Hầu như Beverage chiếm cao nhất trong tổng sales, cụ thể là phân khúc giá dưới $20. Tuy nhiên, Pricing team và Product team có thể điều chỉnh lại trong chiến dịch xúc tiến (Sale Promotion Strategy) bởi vì kế hoạch khuyến mãi hiện tại chưa có sự tác động mạnh mẽ đến khách hàng.
 - Đối với nhân viên thì chưa có một số liệu rõ ràng và cụ thể nào về hiệu suất bán hàng theo nhân khẩu học. 
