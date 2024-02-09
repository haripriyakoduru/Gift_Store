-- DENORM table
create table denorm
(order_id int,
order_date datetime,
customer_name varchar(50),
phone int,
email varchar(100),
addres varchar(300),
product varchar(100),
price decimal(10,2),
category varchar(50),
quantity int,
discount decimal(10,2),
total_price decimal(10,2),
paid decimal(10,2),
balance decimal(10,2),
delivery_date date,
order_status varchar(50));

-- ORDERS table
create table orders
(order_id int primary key,
order_date datetime,
customer_name varchar(50),
discount decimal(10,2),
total_price decimal(10,2),
paid decimal(10,2),
balance decimal(10,2),
delivery_date date,
order_status varchar(50));

-- ORDER_ITEMS table
create table order_items
(order_id int foreign key references orders(order_id),
product varchar(100) foreign key references products(product_name),
price decimal(10,2),
quantity int);

-- PRODUCTS table
create table products
(product_name varchar(100) primary key,
price decimal(10,2),
category varchar(50));

-- CUSTOMERS table
create table customers(
customer_name varchar(100) primary key,
phone int,
email varchar(100),
addres varchar(300));

-- insert data into 'DENORM'
bulk insert denorm from 'C:\Users\user\Downloads\Sales 2ae0e3c439f6406ca810b618ea43dbbe_all.csv'
with(FIELDTERMINATOR = ',',  -- Specify the field delimiter
    ROWTERMINATOR = '\n',   -- Specify the row terminator
    FIRSTROW = 2,           -- Specify the starting row (1 if no header)
    TABLOCK               -- Use TABLOCK to improve performance
);


-- insert data into 'PRODUCTS'
bulk insert products from 'E:\GitHub Projects\JPrintCo\productss.csv'
with(FIELDTERMINATOR = ',',  -- Specify the field delimiter
    ROWTERMINATOR = '\n',   -- Specify the row terminator
    FIRSTROW = 2,           -- Specify the starting row (1 if no header)
    TABLOCK               -- Use TABLOCK to improve performance
);


-- insert data into 'CUSTOMERS'
bulk insert customers from 'E:\GitHub Projects\JPrintCo\customers.csv'
with(FIELDTERMINATOR = ',',  -- Specify the field delimiter
    ROWTERMINATOR = '\n',   -- Specify the row terminator
    FIRSTROW = 2,           -- Specify the starting row (1 if no header)
    TABLOCK               -- Use TABLOCK to improve performance
);


-- trigger when new data is entered
CREATE TRIGGER new_data
ON denorm
AFTER INSERT
AS
BEGIN
-- insert data from 'denorm' to 'orders'
insert into orders (order_id, order_date, customer_name, discount, total_price, paid, balance, delivery_date, order_status)
select order_id, min(order_date), min(customer_name), sum(discount), sum(total_price), sum(paid), sum(balance), min(delivery_date), min(order_status) from denorm
group by order_id;

-- insert data from 'denorm' to 'order_items'
insert into order_items (order_id, product, price, quantity)
select order_id, product, price, quantity from denorm;

-- -- insert data from 'denorm' to 'products'
insert into products (product_name, price, category)
select distinct product, price, category from denorm
where product not in (select product_name from products)
group by product;

-- insert data from 'denorm' to 'customers'
insert into customers (customer_name, phone, email, addres)
select DISTINCT customer_name, phone, email, addres from denorm
where customer_name not in (select customer_name from customers);

END;


select * from orders;
select * from order_items;
select * from products;
select * from customers;