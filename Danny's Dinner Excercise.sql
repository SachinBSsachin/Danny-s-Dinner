show databases;

create database pizza_runner;

use pizza_runner;

create table sales (customer_id varchar(3),
order_date DATE,
product_id int(2)
);

select * from sales;

insert into sales (customer_id,order_date,product_id)values 
("A","2021-01-01",1),
("A","2021-01-01",2),
("A","2021-01-07",2),
("A","2021-01-10",3),
("A","2021-01-11",3),
("A","2021-01-11",3),
("B","2021-01-01",2),
("B","2021-01-02",2),
("B","2021-01-04",1),
("B","2021-01-11",1),
("B","2021-01-16",3),
("B","2021-02-01",3),
("C","2021-01-01",3),
("C","2021-01-01",3),
("C","2021-01-07",3);

select * from sales;


create table menu (product_id int(1),
product_name varchar(5),
price int(2)
);

select * from menu;
insert into menu (product_id,product_name,price)values 
(1,"sushi",10),
(2,"curry",15),
(3,"ramen",12);
select * from menu;


create table members (customer_id varchar(1),
join_date DATE
);

select * from members;
insert into members (customer_id,join_date)values 
("A","2021-01-07"),
("B","2021-01-09");
select * from members;

#Q.1 What is the total amount each customer spent at the restaurant?
select customer_id,sum(price) from sales s
inner join menu m
on s.product_id=m.product_id
group by customer_id;

#Q.2 How many days has each customer visited the restaurant?
select customer_id,count(order_date) as No_of_days from sales group by customer_id;


#Q.3 What was the first item from the menu purchased by each customer?
select s.customer_id,min(s.order_date) "Order Date",m.product_name from sales s
left join menu m
on s.product_id=m.product_id
group by s.customer_id,m.product_name;


#Q.4 What is the most purchased item on the menu and how many times was it purchased by all customers?
select m.product_name,count(*) as "times purchased",dense_rank() over(order by count(*) desc) as `rank` 
from sales s
left join menu m
on s.product_id = m.product_id
group by m.product_name limit 1;


#Q.5 Which item was the most popular for each customer?
with jt as (select s.customer_id,m.product_name,count(*) as "times purchased",dense_rank() over(partition by s.customer_id order by count(*) desc) as `rank` 
from sales s
left join menu m
on s.product_id = m.product_id
group by m.product_name,s.customer_id)
select * from jt where `rank` = 1;

#Q.6 Which item was purchased first by the customer after they became a member?
with jt3 as(select s.customer_id, s.product_id, s.order_date, m.join_date,
dense_rank() over(partition by s.customer_id order by s.order_date) as rnk
from sales s
inner join members m
on s.customer_id = m.customer_id
and s.order_date >= m.join_date)
select jt3.customer_id, jt3.order_date, menu.product_name,rnk
from jt3
inner join menu
on jt3.product_id = menu.product_id
where rnk = 1;

#Q.7 Which item was purchased just before the customer became a member?
with jt3 as(select s.customer_id, s.product_id, s.order_date, m.join_date,
dense_rank() over(partition by s.customer_id order by s.order_date) as rnk
from sales s
inner join members m
on s.customer_id = m.customer_id
and s.order_date < m.join_date)
select jt3.customer_id, jt3.order_date, menu.product_name,rnk
from jt3
inner join menu
on jt3.product_id = menu.product_id
order by 1;


#Q.8 What is the total items and amount spent for each member before they became a member?
with jt4 as (select s.customer_id,s.product_id from sales s
inner join members mb
on s.customer_id = mb.customer_id and 
s.order_date < mb.join_date)
select jt4.customer_id, sum(m.price), count(m.product_id) from jt4
inner join menu m
on jt4.product_id =m.product_id
group by jt4.customer_id; 

#Q.9 If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
with gt as( select s.customer_id as c_id,s.product_id as p_id,m.price,if(s.product_id=1,m.price*20,m.price*10) as f_points  from sales s
left join menu m
on s.product_id =m.product_id)
select gt.c_id, sum(gt.f_points) from gt group by gt.c_id;

#Q.10 In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi -  how many points do customer A and B have at the end of January?
with ft as(select *,date_add(members.join_date,interval 6 day) as Valid_date ,last_day('2021-01-01') as last_date from members)
select s.customer_id, s.order_date, s.product_id, ft.valid_date, ft.last_date, if (s.order_date<ft.last_date,case when(s.order_date <= ft.valid_date) then 20*m.price else 10*m.price end, 0) as points
from sales s
inner join ft
on s.customer_id = ft.customer_id
inner join menu m
on s.product_id=m.product_id








