# eniac_magist_collaboration

This is a Data analysis project using SQL and Tableau. The main goal is to recommend whether or not to sign a contract with the Magist company.
An Overview about the setting and the main business questions can be found further down.

The csv-files used can be found inside the data folder.

## Tech used in this project

- SQL / MySQL Workbench
- Tableau

## Overview and business questions

Eniac is an online marketplace specialized in Apple compatible accessories. 
It was founded 10 years ago in Spain and it has since grown and expanded to other neighbouring countries.

As part of Eniacs growth, the Data department was founded.
Data shows that Brazil has an eCommerce revenue similar to that of Spain and Italy: an already huge market with an even bigger potential to growth.

The problem, for Eniac, is the lack of knowledge of such market. 
The company doesn’t have ties with local providers, package delivery services or customer service agencies. 
Creating these ties and knowing the market would take a lot of time, while the board of directors has demanded the expansion to happen within the next year.

Here comes Magist. Magist is a Brazilian Software as a Service company that offers a centralised order management system to connect small and medium-sized stores with the biggest Brazilian marketplaces.
Magist is already a big player and allows small companies to benefit from its economies of scale: it has signed advantageous contracts with the marketplaces and with the Post Office, thus reducing the cost in fees and, most importantly, the bureaucracy involved to get things started.

Eniac sells through its own e-commerce store in Europe, with its own site and direct providers for all the steps of the supply chain. 
In Brazil, however, Eniac is considering signing a 3-year contract with Magist and operating through external marketplaces as an intermediate step, while it tests the market, creates brand awareness and explores the option of opening its own Brazilian marketplace.

There are two main concerns:

- Eniac’s catalog is 100% tech products, and heavily based on Apple-compatible accessories. It is not clear that the marketplaces Magist works with are a good place for these high-end tech products.
- Among Eniac’s efforts to have happy customers, fast deliveries are key. The delivery fees resulting from Magist’s deal with the public Post Office might be cheap, but at what cost? Are deliveries fast enough?


## Basic questions

- How many orders are in the dataset?
- Are orders actually delivered?
- Is Magist having user growth?
- How many products are there in the products table?
- What are the categories with the most products?
- How many of those products were present in actual transactions?
- What are the prices of the most expensive / cheapest products?
- What are the highest / lowest payment values?

## Questions aimed towards answering the business questions

### Questions in relation to the products:
- What categories of tech products does Magist have?
- How many products of these tech categories have been sold (within the time window of the database snapshot)? 
- What percentage does that represent from the overall number of products sold?
- What’s the average price of the products being sold?
- Are expensive tech products popular?

### In relation to the sellers:

- How many months of data are included in the magist database?
- How many sellers are there? How many Tech sellers are there? 
- What percentage of overall sellers are Tech sellers?
- What is the total amount earned by all sellers? 
- What is the total amount earned by all Tech sellers?
- What is the average monthly income of all sellers? 
- What is the average monthly income of Tech sellers?

### In relation to the delivery time:

- What’s the average time between the order being placed and the product being delivered?
- How many orders are delivered on time vs orders delivered with a delay?
- Is there any pattern for delayed orders, e.g. big products being delayed more often?
