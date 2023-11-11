### warehouses:
SELECT *
FROM mintclassics.warehouses
LIMIT 5;

### products:
SELECT *
FROM mintclassics.products
LIMIT 5;

### distinct product code:
SELECT DISTINCT(productCode), productName
FROM mintclassics.products;
 ### products in more than 1 warehouse:
 SELECT productCode, COUNT(warehouseCode) AS numberOfWarehouses
 FROM mintclassics.products
 GROUP BY productCode
 HAVING numberOfWarehouses>1;
 
 SELECT w.warehouseCode, w.warehouseName, SUM(p.quantityInStock) AS instock
 FROM mintclassics.warehouses AS w
 INNER JOIN mintclassics.products AS p
 ON w.warehouseCode = p.warehouseCode
 GROUP BY  w.warehouseCode, w.warehouseName
 ORDER BY instock DESC;
 
WITH inventory_status AS (
    SELECT
          p.productCode
        , p.warehouseCode
        , p.quantityInStock
        , SUM(od.quantityOrdered) AS total_ordered_item
        , p.quantityInStock - SUM(od.quantityOrdered) AS stock_vs_orders
        , CASE 
            WHEN (p.quantityInStock - SUM(od.quantityOrdered)) > (2 * SUM(od.quantityOrdered)) THEN 'Overstocked'
            WHEN (p.quantityInStock - SUM(od.quantityOrdered)) < 500 THEN 'Understocked'
            ELSE 'Well-Stocked'
              END AS statuses
    FROM mintclassics.products p
    JOIN mintclassics.orderdetails od
        ON p.productCode = od.productCode
    JOIN mintclassics.orders o
        ON od.orderNumber = o.orderNumber
    WHERE
        o.status IN('Shipped', 'Resolved')
    GROUP BY 
          p.productCode
        , p.warehouseCode
    ORDER BY
          warehouseCode
        , stock_vs_orders DESC
)
SELECT
      productCode
    , productName
    , quantityInStock
    , warehouseCode
FROM mintclassics.products AS p
WHERE NOT EXISTS
      (
       SELECT 1
       FROM inventory_status 
       WHERE p.productCode = inventory_status.productCode
      );
      
WITH inventory_status AS (
    SELECT
          p.productCode
        , p.warehouseCode
        , p.quantityInStock
        , SUM(od.quantityOrdered) AS total_ordered_item
        , p.quantityInStock - SUM(od.quantityOrdered) AS stock_vs_orders
        , CASE 
            WHEN (p.quantityInStock - SUM(od.quantityOrdered)) > (2 * SUM(od.quantityOrdered)) THEN 'Overstocked'
            WHEN (p.quantityInStock - SUM(od.quantityOrdered)) < 500 THEN 'Understocked'
            ELSE 'Well-Stocked'
              END AS statuses
    FROM mintclassics.products p
    JOIN mintclassics.orderdetails od
        ON p.productCode = od.productCode
    JOIN mintclassics.orders o
        ON od.orderNumber = o.orderNumber
    WHERE
        o.status IN('Shipped', 'Resolved')
    GROUP BY 
          p.productCode
        , p.warehouseCode
    ORDER BY
          warehouseCode
        , stock_vs_orders DESC
)
SELECT
      productCode
    , quantityInStock
    , warehouseCode
FROM inventory_status
WHERE statuses = 'Overstocked'
ORDER BY warehouseCode;

WITH inventory_status AS (
    SELECT
          p.productCode
        , p.warehouseCode
        , p.quantityInStock
        , SUM(od.quantityOrdered) AS total_ordered_item
        , p.quantityInStock - SUM(od.quantityOrdered) AS stock_vs_orders
        , CASE 
            WHEN (p.quantityInStock - SUM(od.quantityOrdered)) > (2 * SUM(od.quantityOrdered)) THEN 'Overstocked'
            WHEN (p.quantityInStock - SUM(od.quantityOrdered)) < 500 THEN 'Understocked'
            ELSE 'Well-Stocked'
              END AS statuses
    FROM mintclassics.products p
    JOIN mintclassics.orderdetails od
        ON p.productCode = od.productCode
    JOIN mintclassics.orders o
        ON od.orderNumber = o.orderNumber
    WHERE
        o.status IN('Shipped', 'Resolved')
    GROUP BY 
          p.productCode
        , p.warehouseCode
    ORDER BY
          warehouseCode
        , stock_vs_orders DESC
)
SELECT productCode
    , quantityInStock
    , warehouseCode
FROM inventory_status
WHERE statuses = 'Understocked'
ORDER BY warehouseCode;
