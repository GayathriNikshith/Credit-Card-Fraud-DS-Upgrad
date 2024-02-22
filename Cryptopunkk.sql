SELECT 
    COUNT(*)
FROM
    pricedata;


SELECT 
    name, eth_price, usd_price, event_date
FROM
    pricedata
ORDER BY usd_price DESC
LIMIT 5;

SELECT 
    transaction_hash, 
    usd_price, 
    AVG(usd_price) OVER(ORDER BY event_date ROWS BETWEEN 49 PRECEDING AND CURRENT ROW) as usd_mv_avg
FROM
    pricedata;
    
SELECT 
    name, AVG(usd_price) as average_price
FROM
    pricedata
GROUP BY name
ORDER BY average_price DESC;

SELECT 
    DAYOFWEEK(event_date), COUNT(*), AVG(eth_price)
FROM
    pricedata
GROUP BY DAYOFWEEK(event_date)
ORDER BY COUNT(*);

SELECT 
    (CONCAT(name,
            ' was sold for $',
            ROUND(usd_price, -3),
            ' to ',
            seller_address,
            ' from ',
            buyer_address,
            ' on ',
            event_date)) as summary
FROM
    pricedata;
    
CREATE VIEW 1919_purchases AS
    SELECT 
        *
    FROM
        pricedata
    WHERE
        buyer_address = '0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685';
        
SELECT 
    ROUND(eth_price, -2) AS bucket,
    COUNT(*) AS count,
    RPAD('', COUNT(*), '*') AS bar
FROM
    pricedata
GROUP BY bucket
ORDER BY bucket;

SELECT 
    name, MAX(eth_price) AS price, 'Highest' AS status
FROM pricedata
GROUP BY name UNION 
SELECT 
    name, MIN(eth_price) AS price, 'Lowest' AS status
FROM pricedata
GROUP BY name
ORDER BY name;

SELECT 
    name,
    usd_price,
    sale_year,
    sale_month,
    sale_count,
    ranked_in_month
FROM (
    SELECT 
        name,
        MAX(usd_price) as usd_price,
        YEAR(event_date) AS sale_year,
        MONTH(event_date) AS sale_month,
        COUNT(*) AS sale_count,
        DENSE_RANK() OVER (PARTITION BY YEAR(event_date), MONTH(event_date) ORDER BY COUNT(*) DESC) as ranked_in_month
    FROM
        pricedata
    GROUP BY name, YEAR(event_date), MONTH(event_date)
) as dt
WHERE ranked_in_month = 1;


SELECT 
    YEAR(event_date) AS sale_year,
    MONTH(event_date) AS sale_month,
    ROUND(SUM(usd_price), -2) AS sum_of_sales_volume
FROM
    pricedata
GROUP BY YEAR(event_date), MONTH(event_date)
ORDER BY YEAR(event_date), MONTH(event_date);


SELECT 
    COUNT(*)
FROM
    pricedata
WHERE
    buyer_address = '0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685'
        OR seller_address = '0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685';
        

CREATE TEMPORARY TABLE avg_usd_price_per_day AS
SELECT 
    event_date, 
    usd_price, 
    AVG(usd_price) OVER (PARTITION BY DATE(event_date)) AS daily_avg
FROM
    pricedata;
    
    
SELECT 
    *, 
    AVG(usd_price) OVER (PARTITION BY DATE(event_date)) AS new_estimated_value
FROM
    avg_usd_price_per_day
WHERE
    usd_price > (0.9 * daily_avg);
